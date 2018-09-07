import jenkins.model.*
import hudson.model.ListView

def views = [:]
views['DEV_WAS85'] = '.*_DEV_WAS85'
views['PRE_WAS85'] = '.*_PRE_WAS85'
views['PRO_WAS85'] = '^((?!(_(DEV|PRE)_WAS85|DSL_)).)*$'
views['DSL'] = 'DSL_.*'

Jenkins jenkins = Jenkins.getInstance()

views.keySet().each { key ->
	jenkins.addView(new ListView(key))
	myView = hudson.model.Hudson.instance.getView(key)
	myView.setIncludeRegex(views.get(key))
	myView.setRecurse(false)
	jenkins.save()
}

