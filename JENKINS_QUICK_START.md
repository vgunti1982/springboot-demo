# Quick Jenkins Pipeline Creation - Step by Step

## Jenkins is Running! 🎉

Your Jenkins container is running at: **http://localhost:9080**

---

## Step 1: Open Jenkins

1. Open your web browser
2. Go to: **http://localhost:9080**
3. You will see the Jenkins setup page

---

## Step 2: Get the Admin Password

Run this command in your terminal:

```bash
docker exec jenkins-demo cat /var/jenkins_home/secrets/initialAdminPassword
```

Copy the password that appears.

---

## Step 3: Unlock Jenkins

1. Paste the password in the **"Administrator password"** field
2. Click **"Continue"**

---

## Step 4: Install Plugins

1. Click **"Install suggested plugins"** (this takes 5-10 minutes)
2. Wait for plugins to install
3. Jenkins will automatically reload

---

## Step 5: Create Admin User (Optional)

1. Create a new admin user OR
2. Click **"Skip and continue as admin"**
3. Click **"Start using Jenkins"**

---

## Step 6: Create the Pipeline Job

Now you're in Jenkins Dashboard!

### 6a. Click "New Item"

![Jenkins Dashboard](./docs/step1.png)

Look for **"New Item"** button in the top-left corner and click it.

---

### 6b. Enter Job Name

![New Item Form](./docs/step2.png)

- **Job name**: `springboot-demo-pipeline`
- **Job type**: Select **"Pipeline"** (it's in the middle, might need to scroll)
- Click **"OK"**

---

### 6c. Configure the Pipeline

![Configure Pipeline](./docs/step3.png)

You're now on the job configuration page. Scroll down to find the **"Pipeline"** section.

#### In the Pipeline section:

1. **Definition dropdown**: Select **"Pipeline script from SCM"**

2. **SCM dropdown**: Select **"Git"**

3. Fill in these fields:
   - **Repository URL**: 
     ```
     https://github.com/vgunti1982/springboot-demo.git
     ```
   - **Branch Specifier**: 
     ```
     */master
     ```
   - **Script Path**: 
     ```
     Jenkinsfile
     ```

All other fields can remain at their default values.

---

### 6d. Save Configuration

![Save Button](./docs/step4.png)

Click the **"Save"** button at the bottom of the page.

---

## Step 7: Build the Job

![Build Now Button](./docs/step5.png)

You'll be redirected to the job page. Click **"Build Now"** on the left side.

---

## Step 8: Monitor the Build

![Console Output](./docs/step6.png)

1. In **"Build History"**, you'll see **"#1"** appear
2. Click on **"#1"**
3. Click on **"Console Output"**
4. Watch the build progress live!

Expected output:
```
=== Checking out code ===
=== Building application ===
[INFO] Tests run: 2, Failures: 0
=== Packaging application ===
=== Building Docker image ===
Finished: SUCCESS
```

---

## Success! ✅

If you see **"Finished: SUCCESS"**, your pipeline worked!

### What was built:
- ✅ Spring Boot JAR: `demo-1.0.0.jar`
- ✅ Docker image: `springboot-demo:latest`
- ✅ Unit tests passed: 2/2

---

## If Something Goes Wrong

### Problem: Can't access Jenkins
```bash
# Check if container is running
docker ps | grep jenkins
```

### Problem: Jenkins says password is wrong
```bash
# Get the correct password
docker exec jenkins-demo cat /var/jenkins_home/secrets/initialAdminPassword
```

### Problem: Build fails
1. Click on the build number
2. Click "Console Output"
3. Look for error messages (usually in red)
4. Common errors:
   - **"mvn: command not found"** → Maven not configured
   - **"git: command not found"** → Git not installed
   - **"JDK not found"** → Java not configured

### Get help from logs:
```bash
# See all Jenkins logs
docker logs jenkins-demo | tail -50
```

---

## Quick Reference

| Item | Value |
|------|-------|
| Jenkins URL | http://localhost:9080 |
| Job Name | springboot-demo-pipeline |
| Repository | https://github.com/vgunti1982/springboot-demo.git |
| Branch | master |
| Build Script | Jenkinsfile |
| Expected Result | SUCCESS |

---

## Next Steps After Success

Once the build succeeds:

1. **View Artifacts**:
   - Click on build #1 → "Artifacts"
   - Download `demo-1.0.0.jar`

2. **Configure Deployment** (Optional):
   - Edit Jenkinsfile to add DEPLOY parameters
   - Create deployment server credentials
   - Set DEPLOY=true for auto-deployment

3. **Set Build Triggers** (Optional):
   - Configure GitHub webhook for auto-build on push
   - Or schedule periodic builds

---

## File Reference

All documentation is in your repository:
- `Jenkinsfile` - Build pipeline definition
- `JENKINS_COMPLETE_SETUP.md` - Detailed guide
- `JENKINS_DEPLOYMENT_GUIDE.md` - Deployment options
- `JENKINS_MANUAL_SETUP.md` - Manual setup guide

