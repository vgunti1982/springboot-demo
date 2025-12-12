#!/bin/bash

# Create Jenkins Pipeline Job via API with proper XML escaping
JENKINS_URL="http://localhost:9080"
JENKINS_USER="admin"
JENKINS_PASSWORD="518b2227824d4edea12513d95156f10b"
GITHUB_REPO="https://github.com/vgunti1982/springboot-demo.git"

echo "=== Creating Spring Boot Demo Pipeline Job ==="
echo ""

# Create a temporary file with the job configuration
cat > /tmp/job-config.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<org.jenkinsci.plugins.workflow.job.WorkflowJob plugin="workflow-job@1292.v0d7b_056c7e0d">
  <actions/>
  <description>Spring Boot Demo Application - CI/CD Pipeline</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.95">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@5.4.0">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>https://github.com/vgunti1982/springboot-demo.git</url>
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
</org.jenkinsci.plugins.workflow.job.WorkflowJob>
EOF

echo "Job configuration created..."
echo ""

# Try to create the job with retries
for attempt in {1..3}; do
    echo "Attempt $attempt: Creating job..."
    
    HTTP_CODE=$(curl -s -o /tmp/response.txt -w "%{http_code}" \
        -X POST "${JENKINS_URL}/createItem?name=springboot-demo-pipeline" \
        -u "${JENKINS_USER}:${JENKINS_PASSWORD}" \
        -H "Content-Type: application/xml" \
        -d @/tmp/job-config.xml)
    
    echo "Response Code: $HTTP_CODE"
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        echo "✓ Job created successfully!"
        break
    elif [ "$HTTP_CODE" = "400" ]; then
        echo "Response: $(cat /tmp/response.txt)"
        sleep 3
    else
        cat /tmp/response.txt
        sleep 3
    fi
done

echo ""
echo "=== Jenkins Access Information ==="
echo "Jenkins URL: ${JENKINS_URL}"
echo "Username: ${JENKINS_USER}"
echo "Password: ${JENKINS_PASSWORD}"
echo ""
echo "=== Job Information ==="
echo "Job Name: springboot-demo-pipeline"
echo "Job URL: ${JENKINS_URL}/job/springboot-demo-pipeline/"
echo "Repository: ${GITHUB_REPO}"
echo "Branch: master"
echo ""
echo "=== Next Steps ==="
echo "1. Open Jenkins: http://localhost:9080"
echo "2. Login with the credentials above"
echo "3. Click on 'springboot-demo-pipeline'"
echo "4. Click 'Build Now' to start the pipeline"
echo "5. Monitor the build progress in Console Output"
