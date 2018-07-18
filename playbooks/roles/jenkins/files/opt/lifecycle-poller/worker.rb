#!/usr/bin/env ruby
#------------------------------------------------------------------------------
#
# FILE: worker.rb
#
# DESCRIPTION: This file is meant to be run as a background deamon. Its main job
#   is to remove all nodes in Jenkins that have been scaled in by the AutoScaling 
#   Group.
#
# FROM: https://github.com/widdix/aws-cf-templates/blob/master/jenkins/jenkins2-ha.yaml
#
#------------------------------------------------------------------------------
require 'net/http'
require 'aws-sdk'
require 'json'
require 'uri'
require 'yaml'
require 'syslog/logger'

$log = Syslog::Logger.new 'poller'
$conf = YAML::load_file(__dir__ + '/poller.conf')
Aws.config.update(region: $conf['region'])
$log.info 'poller started'

$jenkins_cli = '/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar'

#------------------------------------------------------------------------------
# 
# FUNCTION: takeAgentTemporarilyOffline
#
# DESCRIPTION: This will take the given agent temporarily off
#
#------------------------------------------------------------------------------
def takeAgentTemporarilyOffline(agent)
  # sterr is forwarded to sdout to get the information in ruby
  out=`java -jar #{$jenkins_cli} -s http://localhost:8080 -auth 'admin:#{$conf['masterAdminPassword']}' offline-node #{agent} -m 'scale down' 2>&1`
  if $?.exitstatus == 0
    $log.info "agent #{agent} is marked as offline"
    return true
  else
    if out.include? "ERROR: No such agent"
      $log.info "agent #{agent} could not be marked as offline, it already is deleted: #{out}"
      return true
    else
      $log.error "agent #{agent} could not be marked as offline: #{out}"
      return false
    end
  end
end

#------------------------------------------------------------------------------
# 
# FUNCTION: deleteAgent
#
# DESCRIPTION: This will delete the given agent
#
#------------------------------------------------------------------------------
def deleteAgent(agent)
  # sterr is forwarded to sdout to get the information in ruby
  out=`java -jar #{$jenkins_cli} -s http://localhost:8080 -auth 'admin:#{$conf['masterAdminPassword']}' delete-node #{agent} 2>&1`
  if $?.exitstatus == 0
    $log.info "agent #{agent} is deleted"
    return true
  else
    if out.include? "ERROR: No such node"
      $log.info "agent #{agent} could not be deleted, it already is deleted: #{out}"
      return true
    else
      $log.error "agent #{agent} could not be deleted: #{out}"
      return false
    end
  end
end

#------------------------------------------------------------------------------
# 
# FUNCTION: isAgentIdle
#
# DESCRIPTION: This method returns whether the given agent is idle 
#
#------------------------------------------------------------------------------

def isAgentIdle(agent)
  url = URI.parse("http://localhost:8080/computer/#{agent}/api/xml")
  req = Net::HTTP::Get.new(url.to_s)
  req.basic_auth('admin', $conf['masterAdminPassword'])
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  if res.code == '200'
    if res.body.include? '<idle>true</idle>'
      return true
    elsif res.body.include? '<idle>false</idle>'
      return false
    else
      $log.error "unexpected body: #{res.body}"
      return false
    end
  elsif res.code == '404'
    return true
  else
    $log.error "unexpected response code: #{res.code}"
    return false
  end
end
def awaitAgentIdle(agent)
  endTime = Time.now.to_i + $conf['maxWaitInSeconds']
  while Time.now.to_i < endTime do
    if isAgentIdle agent
      $log.info "agent #{agent} is idle"
      return true
    end
    sleep 5 # seconds
  end
  $log.error "agent #{agent} is not idle, but wait time elapsed"
  return false
end
def completeLifecycleAction(token, hook, asg)
  begin
    autoscaling = Aws::AutoScaling::Client.new()
    autoscaling.complete_lifecycle_action(
      lifecycle_hook_name: hook,
      auto_scaling_group_name: asg,
      lifecycle_action_token: token,
      lifecycle_action_result: 'CONTINUE'
    )
    $log.info "Lifecycle action completed"
    return true
  rescue Exception => e
    if e.code == 'ValidationError'
      $log.info "Lifecycle action failed validation: #{e.inspect}"
      return true
    else
      raise e
    end
  end
end

#------------------------------------------------------------------------------
# 
# FUNCTION: awaitFile
#
# DESCRIPTION: wait for the given file to be present. This ensures that 
#   jenkins is up and running.
#
#------------------------------------------------------------------------------
def awaitFile(file)
  endTime = Time.now.to_i + $conf['maxWaitInSeconds']
  while Time.now.to_i < endTime do
    if File.exist? file
      $log.info "file #{file} exists"
      return true
    end
    sleep 5 # seconds
  end
  $log.error "file #{file} is not available, but wait time elapsed"
  return false
end

#------------------------------------------------------------------------------
# 
# FUNCTION: pollSQS
#
# DESCRIPTION: This is the main loop of the daemon. It listens to Autoscaling 
#   events (terminating in this case), and remove the corresponding agent
#   from the Jenkins list of available agents.
#
#------------------------------------------------------------------------------
def pollSQS()
  poller = Aws::SQS::QueuePoller.new($conf['queueUrl'])
  poller.poll do |msg|
    begin
      body = JSON.parse(msg.body)
      $log.debug "message #{body}"
      if body['Event'] == 'autoscaling:TEST_NOTIFICATION'
        $log.info 'received test notification'
      else
        if body['LifecycleTransition'] == 'autoscaling:EC2_INSTANCE_TERMINATING'
          $log.info "lifecycle transition for agent #{body['EC2InstanceId']}"
          takeAgentTemporarilyOffline body['EC2InstanceId']
          awaitAgentIdle body['EC2InstanceId']
          deleteAgent body['EC2InstanceId']
          completeLifecycleAction body['LifecycleActionToken'], body['LifecycleHookName'], body['AutoScalingGroupName']
        else
          $log.error "received unsupported lifecycle transition: #{body['LifecycleTransition']}"
        end
      end
    rescue Exception => e
      $log.error "message failed: #{e.inspect} #{msg.inspect}"
      raise e
    end
  end
end
awaitFile($jenkins_cli)
pollSQS