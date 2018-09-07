import jenkins.model.*

def matchedJobs = Jenkins.instance.items.findAll { job ->
	job.name =~ /^afb.*/
}
	
matchedJobs.each { job ->
	println ('Deleting ' + job.name +'...')
	try {
		job.delete()
	} catch (Exception e) {
		println(e.getMessage())
	}
}