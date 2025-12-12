#!/bin/bash

# Jenkins Configuration Script
set -e

JENKINS_URL="http://localhost:9080"
JENKINS_USER="admin"
JENKINS_PASSWORD="518b2227824d4edea12513d95156f10b"
JENKINS_TOKEN=""
GITHUB_REPO="https://github.com/vgunti1982/springboot-demo.git"

echo "=== Waiting for Jenkins to be ready ==="
for i in {1..60}; do
    if curl -s -f "${JENKINS_URL}/api/json" > /dev/null 2>&1; then
        echo "✓ Jenkins is ready!"
        break
    fi
    echo "Attempt $i: Waiting for Jenkins..."
    sleep 2
done

echo ""
echo "=== Jenkins Information ==="
echo "URL: ${JENKINS_URL}"
echo "Initial Admin Password: ${JENKINS_PASSWORD}"
echo "Username: ${JENKINS_USER}"
echo ""

# Get CSRF token
echo "=== Getting CSRF Token ==="
CRUMB=$(curl -s "${JENKINS_URL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)" \
  -u "${JENKINS_USER}:${JENKINS_PASSWORD}")
echo "CSRF Token obtained: ${CRUMB}"

echo ""
echo "=== Creating Pipeline Job ==="

# Create Job Configuration
JOB_CONFIG='<?xml version="1.0" encoding="UTF-8"?>
<org.jenkinsci.plugins.workflow.job.WorkflowJob plugin="workflow-job@1292.v0d7b_056c7e0d">
  <actions/>
  <description>Spring Boot Demo Pipeline - Build and Test</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers/>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.95">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@5.4.0">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>'${GITHUB_REPO}'</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/master</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="empty-list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>false</lightweight>
  </definition>
  <disabled>false</disabled>
</org.jenkinsci.plugins.workflow.job.WorkflowJob>'

# Create the job
curl -s -X POST "${JENKINS_URL}/createItem?name=springboot-demo-pipeline" \
  -H "${CRUMB}" \
  -u "${JENKINS_USER}:${JENKINS_PASSWORD}" \
  -H "Content-Type: application/xml" \
  -d "${JOB_CONFIG}"

echo ""
echo "=== Job Creation Complete ==="
echo "Pipeline URL: ${JENKINS_URL}/job/springboot-demo-pipeline/"
echo ""
echo "Next steps:"
echo "1. Open Jenkins: ${JENKINS_URL}"
echo "2. Login with:"
echo "   Username: ${JENKINS_USER}"
echo "   Password: ${JENKINS_PASSWORD}"
echo "3. Click on 'springboot-demo-pipeline'"
echo "4. Click 'Build Now' to start the pipeline"
