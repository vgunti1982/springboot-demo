# Manual Jenkins Pipeline Setup Guide

## Jenkins Access Information

- **URL**: http://localhost:9080
- **Initial Admin Password**: Check the Jenkins container logs or Jenkins UI will display it on first access

## Step-by-Step: Create Pipeline Job Manually

### Step 1: Access Jenkins UI

1. Open your browser and go to: **http://localhost:9080**
2. You'll see the Jenkins setup page with "Unlock Jenkins"
3. Copy the initial admin password from the UI or run:
   ```bash
   docker exec jenkins-demo cat /var/jenkins_home/secrets/initialAdminPassword
   ```

### Step 2: Complete Initial Setup

1. Paste the admin password
2. Click **Continue**
3. Select **Install suggested plugins** (wait for installation)
4. Create your first admin user (or skip to use default admin)
5. Click **Start using Jenkins**

### Step 3: Create New Pipeline Job

1. Click **New Item** (top left)
2. Enter job name: **springboot-demo-pipeline**
3. Select **Pipeline** (scroll down if needed)
4. Click **OK**

### Step 4: Configure Pipeline Settings

#### General Tab
- **Description**: Spring Boot Demo Application - CI/CD Pipeline
- Leave other options as default

#### Pipeline Tab

In the **Pipeline** section, you'll see a dropdown for **Definition**:

1. Select: **Pipeline script from SCM**
2. Select **SCM**: Git
3. Enter the following details:

   | Field | Value |
   |-------|-------|
   | **Repository URL** | https://github.com/vgunti1982/springboot-demo.git |
   | **Branch Specifier** | `*/master` |
   | **Script Path** | Jenkinsfile |

4. Leave other options as default

### Step 5: Save and Build

1. Click **Save** button
2. Click **Build Now** (top left)
3. Monitor the build in **Build History** → **#1** → **Console Output**

---

## Expected Pipeline Stages

The pipeline will execute these stages:

1. ✅ **Checkout** - Clone the repository
2. ✅ **Build** - Compile with Maven
3. ✅ **Test** - Run unit tests
4. ✅ **Package** - Create JAR file
5. ✅ **Build Docker Image** - Create Docker container (BUILD_DOCKER_BUILD=true)
6. ✅ **Unit Tests Only** - Summary message

---

## If Build Fails

### Common Issues:

**Error: Maven not found**
- The Maven plugin should be pre-installed in the Docker image
- Go to **Manage Jenkins** → **Tools** → **Maven** and ensure `Maven-3.9` is configured

**Error: JDK not found**
- Go to **Manage Jenkins** → **Tools** → **JDK** and ensure `JDK-17` is configured

**Error: Git checkout fails**
- Ensure the repository URL is correct
- Check network connectivity from Jenkins container to GitHub

### View Detailed Logs

Click on the failed build number → **Console Output** to see detailed error messages.

---

## Jenkins Configuration (if needed)

### Configure Maven Tool

1. Go to **Manage Jenkins** → **Tools**
2. Scroll to **Maven**
3. Click **Add Maven**
4. Name: `Maven-3.9`
5. Version: Select from dropdown
6. Click **Save**

### Configure JDK Tool

1. Go to **Manage Jenkins** → **Tools**
2. Scroll to **JDK**
3. Click **Add JDK**
4. Name: `JDK-17`
5. Version: Select from dropdown
6. Click **Save**

---

## Accessing Build Artifacts

After successful build:

1. Go to job page: **springboot-demo-pipeline**
2. Click on the build number (e.g., **#1**)
3. Click **Artifacts** to download:
   - `demo-1.0.0.jar` - Executable Spring Boot JAR
   - Docker image will be built locally in Jenkins container

---

## Build Parameters (Optional)

To use build parameters in future builds:

1. Click **Configure** on the job page
2. Check **This project is parameterized**
3. Click **Add Parameter**
4. Select **Boolean Parameter**
5. Add these parameters:
   - **DOCKER_BUILD** (default: true)
   - **DEPLOY** (default: false)
   - **DEPLOY_HOST** (default: localhost)

Then when you click **Build Now**, you'll see **Build with Parameters** button.

---

## Troubleshooting Checklist

- [ ] Jenkins is running on port 9080
- [ ] Jenkins UI is accessible at http://localhost:9080
- [ ] Logged in with admin credentials
- [ ] Created "springboot-demo-pipeline" job
- [ ] Job type is "Pipeline"
- [ ] Repository URL is correct: https://github.com/vgunti1982/springboot-demo.git
- [ ] Branch is set to `*/master`
- [ ] Script Path is set to `Jenkinsfile`
- [ ] Maven and JDK tools are configured
- [ ] Clicked "Save" after configuration

---

## Quick Commands

### Check Jenkins Logs
```bash
docker logs jenkins-demo -f
```

### Access Jenkins Container Shell
```bash
docker exec -it jenkins-demo bash
```

### Restart Jenkins
```bash
docker restart jenkins-demo
```

### Check Jenkins Home Directory
```bash
docker exec jenkins-demo ls -la /var/jenkins_home/jobs/
```

---

## Screenshots/Next Steps

After creating the job:
1. You should see **springboot-demo-pipeline** in the Jenkins dashboard
2. Click on it to view job details
3. Click **Build Now** to trigger the first build
4. Monitor progress in **Build History**

If you still don't see the job, please share:
1. Screenshot of Jenkins dashboard
2. Output of: `docker logs jenkins-demo | grep -i "error\|warning" | head -20`

