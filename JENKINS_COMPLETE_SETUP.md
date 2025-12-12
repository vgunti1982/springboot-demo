# Jenkins Pipeline Setup - Complete Guide

## Current Status

✅ Jenkins container is running on **http://localhost:9080**  
✅ Maven 3.9 is installed  
✅ JDK 17 is installed  
✅ Required plugins are installed  

❌ Job "springboot-demo-pipeline" needs to be created manually

---

## Option 1: Manual UI Setup (Recommended)

### 1. Open Jenkins

Go to: **http://localhost:9080**

### 2. Complete Setup Wizard

- Click **Unlock Jenkins**
- Get password from: `docker exec jenkins-demo cat /var/jenkins_home/secrets/initialAdminPassword`
- Click **Continue**
- Select **Install suggested plugins** (takes ~5 minutes)
- Create admin user or skip
- Click **Start using Jenkins**

### 3. Create Pipeline Job

#### A. Click "New Item"
![New Item Button](./docs/images/jenkins-new-item.png)
- Click top-left **"New Item"** button

#### B. Enter Job Details
![Create Job](./docs/images/jenkins-create-job.png)
- **Job name**: `springboot-demo-pipeline`
- **Job type**: Select **Pipeline** (scroll down if needed)
- Click **OK**

#### C. Configure Pipeline
![Configure Pipeline](./docs/images/jenkins-configure.png)

Scroll down to **Pipeline** section:

1. **Definition**: Select **"Pipeline script from SCM"**
2. **SCM**: Select **"Git"**
3. **Repository URL**: 
   ```
   https://github.com/vgunti1982/springboot-demo.git
   ```
4. **Branch Specifier**:
   ```
   */master
   ```
5. **Script Path**:
   ```
   Jenkinsfile
   ```

#### D. Save Configuration
![Save Button](./docs/images/jenkins-save.png)
- Click **Save** button

#### E. Build the Job
![Build Now](./docs/images/jenkins-build-now.png)
- Click **Build Now**
- Monitor build in **Build History** → **#1** → **Console Output**

---

## Option 2: Using Docker Compose (All-in-One)

If you want a fresh start with everything pre-configured:

```bash
# Clean up existing containers
docker stop jenkins-demo springboot-app 2>/dev/null || true
docker rm jenkins-demo springboot-app 2>/dev/null || true

# Start with docker-compose
docker-compose up -d

# Wait for Jenkins to be ready
sleep 30

# Check status
docker-compose ps
```

Then follow **Manual UI Setup** steps 1-3 above.

---

## Option 3: Command-Line Job Creation (Advanced)

If you prefer automated setup, use this approach:

```bash
# 1. Get Jenkins API token
TOKEN=$(curl -s -u admin:admin \
  http://localhost:9080/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken \
  -d "newTokenName=cli-token" | jq -r '.data.tokenValue')

# 2. Create job using XML
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/xml" \
  -d @job-config.xml \
  http://localhost:9080/createItem?name=springboot-demo-pipeline
```

---

## Expected Build Output

When you click "Build Now", you should see:

```
...
=== Checking out code ===
...
=== Building application ===
[INFO] Building springboot-demo
...
=== Running tests ===
[INFO] Tests run: 2, Failures: 0, Errors: 0
...
=== Packaging application ===
[INFO] Building jar: target/demo-1.0.0.jar
...
=== Building Docker image ===
Successfully tagged springboot-demo:latest
...
Finished: SUCCESS
```

---

## Troubleshooting

### Problem: Job doesn't appear in Jenkins

**Solution 1**: Refresh the page (F5)

**Solution 2**: Check Jenkins logs:
```bash
docker logs jenkins-demo
```

**Solution 3**: Verify Jenkins is accessible:
```bash
curl -s http://localhost:9080/api/json | jq .
```

### Problem: Build fails with "mvn: command not found"

**Solution**: 
1. Go to **Manage Jenkins** → **Tools**
2. Configure Maven manually:
   - Click **Add Maven**
   - Name: `Maven-3.9`
   - Version: `3.9.6` (or latest)
   - Click **Save**

### Problem: Build fails with "JDK not found"

**Solution**:
1. Go to **Manage Jenkins** → **Tools**
2. Configure JDK manually:
   - Click **Add JDK**
   - Name: `JDK-17`
   - Version: `17` (or latest)
   - Click **Save**

### Problem: "Git not found"

The Git plugin should be auto-installed. If not:
1. Go to **Manage Jenkins** → **Plugins**
2. Search for **Git plugin**
3. Install and restart Jenkins

---

## Useful Commands

### View Jenkins Logs
```bash
docker logs jenkins-demo -f
```

### Access Jenkins Container
```bash
docker exec -it jenkins-demo bash
```

### List Jenkins Jobs
```bash
docker exec jenkins-demo ls /var/jenkins_home/jobs/
```

### Restart Jenkins
```bash
docker restart jenkins-demo
```

### Check Docker Connection
```bash
docker exec jenkins-demo docker ps
```

---

## Jenkins Admin Credentials

- **Username**: admin
- **Password**: (Check Jenkins UI on first access, or reset in settings)

---

## File Locations (Inside Container)

| Item | Location |
|------|----------|
| Jenkins Home | `/var/jenkins_home/` |
| Job Configs | `/var/jenkins_home/jobs/` |
| Build Artifacts | `/var/jenkins_home/jobs/springboot-demo-pipeline/builds/` |
| Logs | `/var/jenkins_home/logs/` |
| Plugins | `/var/jenkins_home/plugins/` |

---

## Next Steps After Successful Build

1. ✅ Build runs successfully
2. ✅ All stages pass
3. ✅ Artifacts are generated:
   - `demo-1.0.0.jar` (executable Spring Boot JAR)
   - Docker image: `springboot-demo:latest`

4. **Optional**: Configure deployment:
   - Set `DEPLOY=true` parameter
   - Set `DEPLOY_HOST=<your-server>`
   - Update Jenkinsfile credentials

---

## Quick Links

- **Jenkins**: http://localhost:9080
- **Git Repo**: https://github.com/vgunti1982/springboot-demo
- **Jenkinsfile**: https://github.com/vgunti1982/springboot-demo/blob/master/Jenkinsfile
- **Spring Boot App**: http://localhost:8081 (after deployment)

---

## Support

If you still encounter issues:

1. Share Jenkins logs:
   ```bash
   docker logs jenkins-demo 2>&1 | head -100
   ```

2. Share build console output:
   - Click on the failed build → Console Output → Copy text

3. Check Jenkins System Information:
   - **Manage Jenkins** → **System Information**
   - Copy relevant sections

