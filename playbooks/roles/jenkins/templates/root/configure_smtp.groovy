import jenkins.model.Jenkins
import hudson.tasks.*
import hudson.util.*

smtp = Jenkins.instance.getExtensionList('hudson.tasks.Mailer$DescriptorImpl')[0]
smtp.smtpAuthUsername = '{{SmtpUsername}}';
smtp.smtpAuthPassword = new Secret('{{SmtpPassword}}')
smtp.replyToAddress = '{{JenkinsAdminEmail}}';
smtp.smtpHost = '{{SmtpHostname}}';
smtp.smtpPort = 465;
smtp.useSsl = true;
smtp.charset = 'UTF-8'
smtp.save();
println 'SMTP configured...'
