# Jenkinsfile Updates - Remote Server Deployment

## Summary of Changes

The Jenkinsfile has been **updated to support Jenkins running on a different server** from the application deployment server.

---

## Key Changes

### 1. Added Environment Variables & Parameters

**New Parameters**:
```groovy
parameters {
    booleanParam(name: 'DOCKER_BUILD', defaultValue: true, description: 'Build Docker image')
    booleanParam(name: 'DEPLOY', defaultValue: false, description: 'Deploy to server')
    string(name: 'DEPLOY_HOST', defaultValue: 'localhost', description: 'Deployment server hostname/IP')
}
```

**New Environment Variables**:
- `APP_PORT`: Application port (8081)
- `DEPLOY_SERVER`: Deployment server hostname
- `DEPLOY_USER`: SSH user for deployment
- `DOCKER_REGISTRY`: Optional Docker registry

### 2. Removed Local Application Execution

**Removed Stages**:
- ❌ "Run Application" (was trying to run on Jenkins server)
- ❌ "Health Check" (was checking localhost)
- ❌ "Smoke Test" (was checking localhost)

**Reason**: Jenkins and app server are on different machines

### 3. Added Docker Support

**New Stage**: "Build Docker Image"
```groovy
stage('Build Docker Image') {
    when {
        expression { params.DOCKER_BUILD == true }
    }
    steps {
        // Builds docker image and tags with build number
    }
}
```

### 4. Added Remote Deployment

**New Stage**: "Deploy to Server"
- Copies JAR to deployment server via SCP
- SSH into server and starts application
- Automatically manages process (stops old, starts new)

**New Stage**: "Health Check - Remote"
- Tests app on remote server
- Retries up to 30 times with 2-second intervals
- Validates `/health` endpoint returns "OK"

**New Stage**: "Smoke Test - Remote"
- Tests main endpoint on remote server
- Verifies response contains "Hello World"
- Runs only when DEPLOY is enabled

### 5. Conditional Execution

```groovy
when {
    expression { params.DEPLOY == true }
}
```

Deployment stages only run when DEPLOY parameter is selected

### 6. Updated Post Actions

**Success Post**:
- Shows deployment URL if deployed
- Shows artifact locations if build-only

**Always Post**:
- Reports build summary
- Workspace and build number

---

## Workflow Comparison

### Before (Local Deployment)

```
Jenkins Server (Build + Run)
  ↓
  ├── Checkout code
  ├── Build with Maven
  ├── Test
  ├── Package JAR
  ├── Run application locally
  ├── Health check localhost:8081
  └── Smoke test localhost:8081
```

### After (Remote Deployment)

```
Jenkins Server (Build Only)          App Server (Run)
  ↓
  ├── Checkout code
  ├── Build with Maven
  ├── Test
  ├── Package JAR
  ├── Build Docker image
  │
  ├── (Optional) Deploy to Server → ├── Receive JAR via SCP
  │                                 ├── Stop old app
  │                                 ├── Start new app
  │                                 ├── Health check (8081)
  │                                 └── Smoke test (8081)
  └── Archive artifacts
```

---

## Usage Guide

### Option 1: Build Only (No Deployment)

Perfect for:
- Testing Jenkins pipeline
- Building artifacts for manual deployment
- Generating Docker images

**Steps**:
1. Click **"Build Now"** button
2. Monitor build progress
3. Download artifacts from build page

**Time**: ~2-3 minutes

### Option 2: Build + Deploy to Remote Server

Perfect for:
- Automated deployment to production
- Continuous delivery pipeline
- Testing on isolated app server

**Steps**:
1. Click **"Build with Parameters"** button
2. Set parameters:
   - ✓ DOCKER_BUILD (enabled)
   - ✓ DEPLOY (enabled)  
   - DEPLOY_HOST: `app.example.com`
3. Click **"Build"** button
4. Monitor deployment progress

**Time**: ~3-5 minutes

---

## Required Setup

### Prerequisites

1. **Jenkins Server**
   - Maven 3.9 configured (named `Maven-3.9`)
   - JDK 17 configured (named `JDK-17`)
   - Git plugin installed
   - Pipeline plugin installed

2. **Application Server** (target for deployment)
   - `/opt/springboot` directory created
   - SSH access enabled
   - Java installed (for running JAR)
   - Port 8081 open for application

3. **Jenkins Credentials**
   - SSH key for deployment user
   - Stored in Jenkins credentials vault

### Configuration Steps

1. **Add SSH Credential**
   - Jenkins → Manage Credentials → Global
   - Add: SSH Username with private key
   - Use in Jenkinsfile deployment stages

2. **Prepare App Server**
   ```bash
   mkdir -p /opt/springboot
   chmod 755 /opt/springboot
   ```

3. **Update Jenkinsfile (Optional)**
   - Customize `DEPLOY_HOST` default value
   - Update `APP_PORT` if different
   - Change SSH user if different

---

## Pipeline Parameters Explained

| Parameter | Type | Default | Purpose |
|-----------|------|---------|---------|
| **DOCKER_BUILD** | Boolean | true | Build Docker image after packaging |
| **DEPLOY** | Boolean | false | Deploy to remote server (requires DEPLOY_HOST) |
| **DEPLOY_HOST** | String | localhost | Hostname/IP of deployment server |

---

## Deployment Flow Details

### Stage 1: Checkout
- Pulls code from repository

### Stage 2-4: Build, Test, Package
- Builds JAR with Maven
- Runs unit tests
- Creates executable JAR

### Stage 5: Build Docker Image
- Creates Docker image
- Tags with build number and latest

### Stage 6: Deploy to Server (Conditional)

Steps:
```bash
1. scp target/demo-1.0.0.jar user@host:/opt/springboot/
2. ssh user@host
   - pkill -f "demo-1.0.0.jar"  # Stop old app
   - nohup java -jar demo-1.0.0.jar &  # Start new app
   - sleep 10  # Wait for startup
3. Verify process running
```

### Stage 7: Health Check (Conditional)

```bash
retry 30 times, 2 second interval:
  curl http://deployment-host:8081/health
  if response = "OK": PASS
  else: retry
```

### Stage 8: Smoke Test (Conditional)

```bash
curl http://deployment-host:8081/
if response contains "Hello World": PASS
else: FAIL
```

---

## Error Handling

### SSH Connection Failed
- **Cause**: SSH key not configured or wrong user
- **Solution**: Verify Jenkins SSH credentials and server SSH config

### Health Check Timeout
- **Cause**: App not starting or port not accessible
- **Solution**: Check app server logs, verify port 8081 is open

### SCP Permission Denied
- **Cause**: User doesn't have write permission to `/opt/springboot`
- **Solution**: Update directory permissions or user access

### Smoke Test Failed
- **Cause**: App not responding or endpoint changed
- **Solution**: SSH to server and test endpoint manually

---

## Logs & Debugging

### Jenkins Console Output
View at: Jenkins UI → Job → Build #X → Console Output

Shows:
- Build stages
- Compilation output
- Test results
- Deployment commands
- Remote server responses

### Application Logs (On Remote Server)
```bash
ssh user@host
tail -100 /opt/springboot/app.log
```

### Docker Build Output
```
Jenkins Console → Stage "Build Docker Image"
Shows: docker build command output
```

---

## Next Steps

1. ✅ Add SSH credentials to Jenkins
2. ✅ Prepare application server
3. ✅ Test build-only pipeline first
4. ✅ Test deployment pipeline
5. ✅ Set up notifications (email/Slack)
6. ✅ Configure webhooks for auto-trigger

---

## Files Modified

| File | Changes |
|------|---------|
| **Jenkinsfile** | Added parameters, Docker stage, remote deployment stages, conditional execution |
| **New: JENKINS_DEPLOYMENT_GUIDE.md** | Comprehensive setup and deployment guide |

---

## Backward Compatibility

⚠️ **Breaking Change**: Local execution removed

If you still need local testing:
- Add parameter to control behavior
- Keep both local and remote stages with conditions

Example:
```groovy
stage('Run Locally (For Testing)') {
    when {
        expression { params.RUN_LOCAL == true }
    }
    steps {
        // Local execution code
    }
}
```

---

## Support & Documentation

- **Setup Guide**: See [JENKINS_SETUP.md](docs/JENKINS_SETUP.md)
- **Deployment Guide**: See [JENKINS_DEPLOYMENT_GUIDE.md](JENKINS_DEPLOYMENT_GUIDE.md)
- **Test Report**: See [DOCKER_TEST_REPORT.md](DOCKER_TEST_REPORT.md)

