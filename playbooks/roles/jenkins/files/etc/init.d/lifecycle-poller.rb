#!/usr/bin/env ruby
# chkconfig:    - 80 20
APP_NAME = 'lifecycle-poller'
APP_PATH = '/opt/lifecycle-poller/daemon.rb'
case ARGV.first
    when 'start'
        puts "Starting #{APP_NAME}..."
        system(APP_PATH, 'start')
        exit($?.exitstatus)
    when 'stop'
        system(APP_PATH, 'stop')
        exit($?.exitstatus)
    when 'restart'
        system(APP_PATH, 'restart')
        exit($?.exitstatus)
    when 'status'
        system(APP_PATH, 'status')
        exit($?.exitstatus)
end
unless %w{start stop restart status}.include? ARGV.first
    puts "Usage: #{APP_NAME} {start|stop|restart|status}"
    exit(1)
end