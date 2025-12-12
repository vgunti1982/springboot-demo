# Jenkins Deployment Guide - Distributed Setup

## Overview

The updated Jenkinsfile supports Jenkins running on a **different server** from your application. It includes:
- ✅ Maven build and testing
- ✅ Docker image creation
- ✅ Remote deployment via SSH
- ✅ Remote health checks
- ✅ Artifact archiving

---

## Setup Steps

### 1. Configure Jenkins Credentials

Navigate to **Manage Jenkins → Credentials → System → Global credentials**

Add the following credentials:

#### A. SSH Key for Deployment Server
- **Kind**: SSH Username with private key
- **ID**: `deploy-server-ssh`
- **Username**: `appuser` (or your deployment user)
- **Private Key**: Paste your SSH private key
- **Passphrase**: If key is encrypted

#### B. Deployment Server Host (Optional)
- **Kind**: Secret text
- **ID**: `deploy-server-host`
- **Secret**: `app.example.com` or IP address

#### C. Docker Registry (Optional)
- **Kind**: Secret text  
- **ID**: `docker-registry`
- **Secret**: `registry.example.com` or `docker.io`

### 2. Prepare Deployment Server

On your **application server**, prepare the deployment directory:

```bash
# Create application directory
sudo mkdir -p /opt/springboot
sudo chown appuser:appuser /opt/springboot
cd /opt/springboot

# Create a startup script (optional)
cat > start-app.sh << 'EOF'
#!/bin/bash
pkill -f "demo-1.0.0.jar" || true
sleep 3
nohup java -jar demo-1.0.0.jar > app.log 2>&1 &
sleep 5
ps aux | grep "[j]ava -jar demo-1.0.0.jar"
EOF

chmod +x start-app.sh
```

### 3. Verify SSH Connectivity

From Jenkins server, test SSH connectivity to deployment server:

```bash
# Test connection
ssh -o StrictHostKeyChecking=no appuser@app.example.com "echo 'Connection successful'"

# Test file transfer
scp /path/to/demo-1.0.0.jar appuser@app.example.com:/opt/springboot/
```

### 4. Create Jenkins Pipeline Job

1. Go to **New Item**
2. Enter Job Name: `springboot-deploy-pipeline`
3. Select: **Pipeline**
4. Click **OK**

### 5. Configure Pipeline Job

#### General Settings
- **Description**: Spring Boot multistage pipeline with remote deployment
- **Discard old builds**: Keep last 10 builds

#### Build Triggers (Optional)
- **Poll SCM**: `H/5 * * * *` (every 5 minutes)
- **GitHub webhook**: If using GitHub

#### Pipeline Configuration
- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: `https://github.com/your-username/springboot-demo.git`
- **Branch**: `*/master` or `*/main`
- **Script Path**: `Jenkinsfile`

### 6. Update Jenkinsfile Parameters (if needed)

Edit the Jenkinsfile environment section:

```groovy
environment {
    APP_NAME = 'springboot-demo'
    APP_PORT = '8081'
    DEPLOY_HOST = 'app.example.com'  // Your server
    DEPLOY_USER = 'appuser'          // Your deployment user
}
```

---

## Running the Pipeline

### Option 1: Build Only (No Deployment)

```bash
Click "Build Now"
```

This will:
1. ✅ Checkout code
2. ✅ Build with Maven
3. ✅ Run unit tests
4. ✅ Package JAR
5. ✅ Build Docker image
6. ✅ Archive artifacts

**Output**: JAR and Docker image ready for deployment

### Option 2: Build + Deploy

1. Click **Build with Parameters**
2. Set parameters:
   - **DOCKER_BUILD**: ✓ (enabled)
   - **DEPLOY**: ✓ (enabled)
   - **DEPLOY_HOST**: `app.example.com` (your server)
3. Click **Build**

This will:
1. ✅ All build steps
2. ✅ Copy JAR to deployment server via SCP
3. ✅ SSH into server and start application
4. ✅ Verify health check
5. ✅ Run smoke tests

---

## Pipeline Stages Explained

### Build Stages (Run on Jenkins)

| Stage | Purpose | Notes |
|-------|---------|-------|
| **Checkout** | Clone repository | Uses Jenkins credentials |
| **Build** | Compile code | Requires Maven 3.9 + JDK 17 |
| **Test** | Run unit tests | Results archived as JUnit XML |
| **Package** | Create executable JAR | 32.4 MB fat JAR with Spring Boot |
| **Build Docker Image** | Create Docker container | Conditional: `DOCKER_BUILD` parameter |

### Deployment Stages (Run on App Server)

| Stage | Purpose | Requirements |
|-------|---------|--------------|
| **Deploy to Server** | Copy JAR and start app | SSH access, `/opt/springboot` directory |
| **Health Check - Remote** | Verify app is running | Port 8081 accessible |
| **Smoke Test - Remote** | Test application | Endpoint responds with "Hello World" |

---

## Deployment Scenarios

### Scenario 1: CI/CD Pipeline (Auto Deploy)

```groovy
// Set in Jenkinsfile
parameters {
    string(name: 'DEPLOY_HOST', defaultValue: 'app-prod.example.com')
    booleanParam(name: 'AUTO_DEPLOY', defaultValue: true)
}
```

### Scenario 2: Build Only (Manual Deploy Later)

```bash
# Build generates artifacts
# Manually deploy JAR or Docker image later
# Or use another tool (Kubernetes, etc.)
```

### Scenario 3: Docker Container Deployment

```bash
# Build Docker image
# Push to registry
# Deploy on target server with docker-compose or Kubernetes
```

---

## Troubleshooting

### SSH Connection Failed

**Error**: `Permission denied (publickey)`

**Solution**:
```bash
# 1. Verify SSH key is configured in Jenkins credentials
# 2. Test SSH from Jenkins server
ssh -i /path/to/key appuser@app.example.com

# 3. Check if SSH key is added to deployment server
cat ~/.ssh/authorized_keys | grep "jenkins"

# 4. Add Jenkins SSH key to deployment server
ssh-copy-id -i ~/.ssh/id_rsa appuser@app.example.com
```

### Health Check Timeout

**Error**: `Health check failed after 60 seconds`

**Solution**:
```bash
# 1. Check if app server has Java installed
ssh appuser@app.example.com "java -version"

# 2. Check if port 8081 is open
ssh appuser@app.example.com "netstat -an | grep 8081"

# 3. Check application logs on server
ssh appuser@app.example.com "tail -50 /opt/springboot/app.log"

# 4. Increase health check timeout in Jenkinsfile
# Change: for i in {1..30} to for i in {1..60}
```

### Smoke Test Failed

**Error**: `Smoke test FAILED - Expected 'Hello World'`

**Solution**:
```bash
# Check app is running on server
ssh appuser@app.example.com "ps aux | grep java"

# Test endpoint directly
curl http://app.example.com:8081/
```

### Docker Build Failed

**Error**: `docker: permission denied`

**Solution**:
```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Or use docker context
export DOCKER_HOST=unix:///run/docker.sock
```

---

## Security Best Practices

### 1. SSH Keys
- ✅ Use SSH key authentication (not passwords)
- ✅ Store keys in Jenkins credentials vault
- ✅ Rotate keys periodically

### 2. Credentials
- ✅ Never hardcode credentials in Jenkinsfile
- ✅ Use Jenkins credentials plugin
- ✅ Enable credential masking in logs

### 3. Network
- ✅ Use SSH (port 22) instead of HTTP for file transfer
- ✅ Restrict SSH access by IP if possible
- ✅ Use VPN for Jenkins-to-Server communication

### 4. Firewall
- ✅ Port 22 (SSH) open from Jenkins to App Server
- ✅ Port 8081 (App) restricted to internal network
- ✅ Use security groups/firewalls appropriately

---

## Performance Optimization

### Build Caching
```bash
# Maven caches dependencies in ~/.m2/
# Jenkins workspaces preserve cache between builds
```

### Parallel Testing
```groovy
// Enable in pom.xml for faster tests
<parallel>4</parallel>  // 4 threads
```

### Docker Layer Caching
```bash
# Dockerfile uses multi-stage build
# Each layer is cached, accelerating subsequent builds
```

---

## Monitoring & Notifications

### Email Notifications
Configure in **Post** section:

```groovy
post {
    failure {
        emailext(
            subject: 'Pipeline Failed: ${BUILD_NUMBER}',
            body: 'Check ${BUILD_URL}/console for details',
            to: 'team@example.com'
        )
    }
}
```

### Slack Notifications
```groovy
post {
    always {
        slackSend(
            color: currentBuild.result == 'SUCCESS' ? 'good' : 'danger',
            message: "${APP_NAME} - Build #${BUILD_NUMBER} ${currentBuild.result}"
        )
    }
}
```

---

## Quick Reference

### Build Only
```bash
Click "Build Now"
```

### Build + Deploy
```bash
Click "Build with Parameters"
- DEPLOY_HOST: app.example.com
- DEPLOY: checked
- DOCKER_BUILD: checked
Click "Build"
```

### Check Deployment Status
```bash
# SSH to app server
ssh appuser@app.example.com

# Check if app is running
ps aux | grep "[j]ava -jar demo"

# Check logs
tail -100 /opt/springboot/app.log

# Test endpoint
curl http://localhost:8081/health
```

### Stop Application
```bash
# On app server
pkill -f "demo-1.0.0.jar"
```

### View Artifacts
```bash
# Jenkins job artifacts
Jenkins > Job > Build #X > Artifacts
```

---

## Files Reference

| File | Purpose |
|------|---------|
| `Jenkinsfile` | Pipeline definition (updated for remote deployment) |
| `pom.xml` | Maven configuration |
| `Dockerfile` | Docker image definition |
| `src/main/java/.../Application.java` | Spring Boot application |
| `/opt/springboot/app.log` | Application logs (on app server) |

---

## Next Steps

1. ✅ Configure Jenkins credentials (SSH key)
2. ✅ Prepare application server
3. ✅ Create Jenkins pipeline job
4. ✅ Test with "Build Now" first
5. ✅ Test with "Build with Parameters" for deployment
6. ✅ Set up notifications
7. ✅ Configure webhooks for auto-trigger

---

## Support

For issues or questions:
1. Check [JENKINS_SETUP.md](docs/JENKINS_SETUP.md) for basic setup
2. Review [DOCKER_TEST_REPORT.md](DOCKER_TEST_REPORT.md) for testing results
3. Check Jenkins console output for detailed error messages
4. Review application logs on deployment server

