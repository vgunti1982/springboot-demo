#!/bin/bash

# Direct Job Creation using Jenkins Groovy Script

JENKINS_URL="http://localhost:9080"
JENKINS_USER="admin"
JENKINS_PASS="admin"  # Default if not changed

echo "=== Creating Job via Groovy Script ==="
echo ""

# First, let's try to get the CSRF token for creating jobs
echo "Step 1: Getting authentication token..."

# Create a Groovy script to create the job
GROOVY_SCRIPT='
import jenkins.model.Jenkins
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.GitSCM
import hudson.plugins.git.GitRepository
import hudson.plugins.git.BranchSpec
import hudson.plugins.git.UserRemoteConfig

def createJob() {
    def jenkins = Jenkins.getInstance()
    def jobName = "springboot-demo-pipeline"
    
    // Check if job already exists
    if (jenkins.getItem(jobName) != null) {
        println("Job already exists: " + jobName)
        return
    }
    
    // Create new Pipeline Job
    def job = new WorkflowJob(jenkins, jobName)
    
    // Configure Git SCM
    def userRemoteConfig = new UserRemoteConfig("https://github.com/vgunti1982/springboot-demo.git", null, null, null)
    def gitScm = new GitSCM(
        [userRemoteConfig],  // User remote configs
        [new BranchSpec("*/master")],  // Branches
        false,  // doGenerateSubmoduleConfigurations
        [],  // submoduleCfg
        null,  // browser
        null,  // gitTool
        []  // extensions
    )
    
    // Create the pipeline definition
    def cpsScmFlowDef = new CpsScmFlowDefinition(gitScm, "Jenkinsfile")
    job.setDefinition(cpsScmFlowDef)
    
    // Set description
    job.setDescription("Spring Boot Demo Application - CI/CD Pipeline")
    
    // Save the job
    jenkins.add(job, jobName)
    jenkins.save()
    
    println("Job created successfully: " + jobName)
}

createJob()
'

# Run the Groovy script via Script Console
echo "Step 2: Sending Groovy script to Jenkins..."

# First, try to submit the script
curl -s -X POST "${JENKINS_URL}/scriptText" \
  -u "${JENKINS_USER}:${JENKINS_PASS}" \
  -d "script=${GROOVY_SCRIPT}" \
  -o /tmp/groovy_response.txt

echo "Response:"
cat /tmp/groovy_response.txt

echo ""
echo "=== Job Creation Result ==="
echo "Job Name: springboot-demo-pipeline"
echo "Repository: https://github.com/vgunti1982/springboot-demo.git"
echo ""
echo "To verify, visit: ${JENKINS_URL}/job/springboot-demo-pipeline/"
