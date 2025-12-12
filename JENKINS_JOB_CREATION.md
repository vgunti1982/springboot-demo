# Jenkins Pipeline Job Creation - Your Admin Password is Set!

## Great! Jenkins Security is Active 🔒

Your Jenkins admin password has been set to: **Change@123**

---

## Current Status

✅ Jenkins is running on **http://localhost:9080**
✅ Admin password is configured
⏳ Job "springboot-demo-pipeline" needs to be created

---

## Method 1: Create Job via Jenkins UI (Easiest)

### 1. Open Jenkins

Go to: **http://localhost:9080**

### 2. Login

- **Username**: `admin`
- **Password**: `Change@123`

### 3. Create New Job

1. Click **"New Item"** (top-left)
2. **Job name**: `springboot-demo-pipeline`
3. **Job type**: Select **"Pipeline"**
4. Click **"OK"**

### 4. Configure Pipeline

Scroll to **Pipeline** section:

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

### 5. Save and Build

1. Click **"Save"**
2. Click **"Build Now"**
3. Monitor in **Build History** → **#1** → **Console Output**

---

## Method 2: Create Job via Jenkins Script Console

### 1. Open Jenkins Script Console

1. Login to Jenkins
2. Go to: **Manage Jenkins** → **Script Console**
3. Paste this Groovy script:

```groovy
import jenkins.model.Jenkins
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.GitSCM
import hudson.plugins.git.BranchSpec
import hudson.plugins.git.UserRemoteConfig

def jenkins = Jenkins.getInstance()
def jobName = "springboot-demo-pipeline"

// Check if job exists
if (jenkins.getItem(jobName) != null) {
    println("Job already exists!")
    return
}

// Create job
def job = new WorkflowJob(jenkins, jobName)
job.setDescription("Spring Boot Demo Application - CI/CD Pipeline")

// Configure Git
def userRemoteConfig = new UserRemoteConfig("https://github.com/vgunti1982/springboot-demo.git", null, null, null)
def gitScm = new GitSCM(
    [userRemoteConfig],
    [new BranchSpec("*/master")],
    false,
    [],
    null,
    null,
    []
)

// Configure Pipeline
def definition = new CpsScmFlowDefinition(gitScm, "Jenkinsfile")
job.setDefinition(definition)

// Save
jenkins.add(job, jobName)
jenkins.save()

println("Job created: " + jobName)
```

4. Click **"Run"**
5. You should see: **"Job created: springboot-demo-pipeline"**

---

## Method 3: Command-Line Creation

Once you can access Jenkins via authenticated API (might need to wait for Jenkins to fully initialize):

```bash
curl -X POST \
  -H "Content-Type: application/xml" \
  -d @job-config.xml \
  -u admin:Change@123 \
  http://localhost:9080/createItem?name=springboot-demo-pipeline
```

---

## Quick Test

To verify Jenkins is responding with your credentials:

```bash
curl -u admin:Change@123 http://localhost:9080/api/json | head -20
```

Should return JSON with Jenkins version info.

---

## What Happens Next

Once the job is created:

1. **Build the Job**:
   - Click **"Build Now"**
   
2. **Expected Pipeline Stages**:
   ```
   ✓ Checkout - Clone repo from GitHub
   ✓ Build - Compile code with Maven
   ✓ Test - Run unit tests
   ✓ Package - Create JAR file
   ✓ Build Docker Image - Create container
   ✓ Success! 
   ```

3. **View Results**:
   - Click build number (#1)
   - Click **"Console Output"**
   - Watch the build progress

---

## Expected Build Time

⏱️ **First build**: ~3-5 minutes
- Downloading Maven dependencies
- Compiling code
- Running tests
- Creating Docker image

⏱️ **Subsequent builds**: ~1-2 minutes (cached)

---

## Build Artifacts

After successful build:

1. Go to job page
2. Click on build #1
3. **Artifacts** section shows:
   - `demo-1.0.0.jar` - Download the application JAR

---

## Troubleshooting

### Issue: "Job already exists"

The job might have been created. Check:
1. Jenkins dashboard
2. Look for "springboot-demo-pipeline" in the list
3. If it exists but shows error, delete and recreate

### Issue: Build fails with Git error

Ensure:
- Jenkins has internet access to GitHub
- Repository URL is exactly: `https://github.com/vgunti1982/springboot-demo.git`
- Branch is: `*/master`

### Issue: Build fails with Maven error

Ensure:
1. Go to **Manage Jenkins** → **Tools**
2. Scroll to **Maven**
3. Verify Maven 3.9 is configured
4. If not, add it (Auto-install option)

### Issue: Build fails with JDK error

Ensure:
1. Go to **Manage Jenkins** → **Tools**
2. Scroll to **JDK**
3. Verify JDK-17 is configured
4. If not, add it (Auto-install option)

---

## Credentials Reminder

- **Jenkins URL**: http://localhost:9080
- **Username**: `admin`
- **Password**: `Change@123`

---

## Next Steps

1. ✅ Open http://localhost:9080 in browser
2. ✅ Login with admin / Change@123
3. ✅ Create the pipeline job (Method 1, 2, or 3 above)
4. ✅ Click "Build Now"
5. ✅ Monitor the build
6. ✅ Celebrate when it finishes! 🎉

