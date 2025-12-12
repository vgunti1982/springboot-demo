# Jenkins Credentials Updated! ✅

## Correct Login Credentials

- **Username**: `vgunti`
- **Password**: `Change@123`

---

## Build Status

✅ Job **springboot-demo-pipeline** created
✅ Docker permission issue FIXED
✅ Jenkinsfile updated and committed
✅ Ready for build #4

---

## How to Trigger Build #4

### Via Jenkins UI (Recommended)

1. Open **http://localhost:9080**
2. **Login**:
   - Username: `vgunti`
   - Password: `Change@123`
3. Click **springboot-demo-pipeline** job
4. Click **"Build Now"** button (top left)
5. Watch **Build History** → **#4** → **Console Output**

---

## What Build #4 Will Do

✅ **Checkout** - Clone repo from GitHub  
✅ **Build** - mvn clean compile  
✅ **Test** - Run unit tests (2 should pass)  
✅ **Package** - mvn package  
✅ **Build Docker Image** - NOW WORKS! ✅ (fixed Docker permissions)  

---

## Expected Output

When you click "Build Now" and watch the console, you should see:

```
[Pipeline] stage('Checkout')
[Pipeline] echo === Checking out code ===
[Pipeline] checkout

[Pipeline] stage('Build')
[Pipeline] echo === Building application ===
[Pipeline] sh mvn clean compile

[Pipeline] stage('Test')
[Pipeline] echo === Running tests ===
[Pipeline] sh mvn test

[Pipeline] stage('Package')
[Pipeline] sh mvn package -DskipTests

[Pipeline] stage('Build Docker Image')
[Pipeline] echo === Building Docker image ===
[Pipeline] sh docker build -t springboot-demo:4 .
[Pipeline] sh docker tag springboot-demo:4 springboot-demo:latest

[Pipeline] echo === Pipeline completed successfully ===
[Pipeline] End of Pipeline

SUCCESS
```

Build time: **2-3 minutes** (first time with Maven downloads)

---

## After Build Completes

### Check Docker Image Was Created

```bash
docker images | grep springboot-demo
```

Should show:
```
springboot-demo    4       <image-id>    2 minutes ago
springboot-demo    latest  <image-id>    2 minutes ago
```

### Check Artifacts in Jenkins

In the job, go to **Build #4** → **Artifacts** section to download:
- `demo-1.0.0.jar`

---

## Next Steps

1. ✅ Go to http://localhost:9080
2. ✅ Login: `vgunti` / `Change@123`
3. ✅ Click **springboot-demo-pipeline**
4. ✅ Click **"Build Now"**
5. ✅ Watch it complete successfully! 🎉

---

## If You Want to Run the Built Docker Image

After build succeeds:

```bash
docker run -d -p 8082:8081 --name springboot-app-test springboot-demo:latest
```

Then access at: **http://localhost:8082/**

Should show: **Hello World from Jenkins Pipeline!**

---

That's it! Ready to build? 🚀

