# Jenkins Pipeline Setup Guide

This guide covers setting up and running the Spring Boot application with Jenkins CI/CD pipeline.

## Quick Start

```bash
# Build the Jenkins Docker image
docker build -t jenkins-springboot -f Dockerfile.jenkins .

# Run Jenkins container
docker run -d \
  -p 9080:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  --name jenkins-demo \
  jenkins-springboot

# Wait for Jenkins to start (30-60 seconds)
sleep 30

# Get initial admin password
docker exec jenkins-demo cat /var/jenkins_home/secrets/initialAdminPassword
```

Access Jenkins at: **http://localhost:9080**

---

## Prerequisites

- Docker (with daemon running)
- Git
- Linux/macOS or Windows with Docker Desktop

## Setup Steps

### 1. Build and Start Jenkins

```bash
# Build Jenkins image with pre-installed tools
docker build -t jenkins-springboot -f Dockerfile.jenkins .

# Run Jenkins container with Docker socket mounted
docker run -d \
  -p 9080:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  --name jenkins-demo \
  jenkins-springboot
```

**Important**: The `-v /var/run/docker.sock:/var/run/docker.sock` flag allows Jenkins to access Docker on the host machine.

### 2. Complete Jenkins Setup Wizard

1. Open browser: **http://localhost:9080**
2. Copy initial admin password:
   ```bash
   docker exec jenkins-demo cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Paste password and click **Continue**
4. Select **Install suggested plugins** (wait ~5 minutes)
5. Create admin user or skip
6. Click **Start using Jenkins**

### 3. Create Pipeline Job

#### A. Click **New Item**
- Click **New Item** in top-left corner

#### B. Configure Job
- **Job name**: `springboot-demo-pipeline`
- **Job type**: Select **Pipeline**
- Click **OK**

#### C. Pipeline Configuration
Scroll to **Pipeline** section:

1. **Definition**: `Pipeline script from SCM`
2. **SCM**: `Git`
3. **Repository URL**: `https://github.com/vgunti1982/springboot-demo.git`
4. **Branch Specifier**: `*/master`
5. **Script Path**: `Jenkinsfile`

#### D. Save and Build
- Click **Save**
- Click **Build Now**
- Monitor build in **Build History** → **#1** → **Console Output**

---

## Expected Pipeline Stages

1. **Checkout** - Clones repository
2. **Build** - Compiles with Maven
3. **Test** - Runs unit tests
4. **Package** - Creates JAR artifact
5. **Build Docker Image** - Creates Docker image (when `DOCKER_BUILD=true`)

---

## Build Parameters

The pipeline supports optional parameters (visible when clicking **Build Now**):

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `DOCKER_BUILD` | Boolean | `true` | Build Docker image |
| `DEPLOY` | Boolean | `false` | Deploy to server |
| `DEPLOY_HOST` | String | `localhost` | Target deployment host |

To modify defaults, click **Configure** on the job, check **This project is parameterized**, and add/update parameters.

---

## Troubleshooting

### Jenkins Won't Start

```bash
# Check logs
docker logs jenkins-demo

# Verify port 9080 is free
lsof -i :9080

# Stop and remove container
docker stop jenkins-demo
docker rm jenkins-demo
```

### Build Fails: Maven Not Found

**Solution**: Maven is pre-installed in `Dockerfile.jenkins`. If issue persists:
1. Go to **Manage Jenkins** → **Tools**
2. Under **Maven**, verify `Maven-3.9` is listed
3. If missing, click **Add Maven** and select version from dropdown

### Build Fails: JDK Not Found

**Solution**: JDK 17 is pre-installed. If issue persists:
1. Go to **Manage Jenkins** → **Tools**
2. Under **JDK**, verify `JDK-17` is listed
3. If missing, click **Add JDK** and select Java 17

### Docker Build Stage Fails

**Error**: `permission denied while trying to connect to Docker daemon`

**Solution**: Jenkins user needs Docker access. This is configured in `Dockerfile.jenkins` via `usermod -aG docker jenkins`.

If issue persists:
```bash
# Restart container
docker restart jenkins-demo
```

### Git Checkout Fails

**Error**: `Repository not found` or `Permission denied`

**Solution**:
- Verify repository URL is correct
- Check network connectivity from container: `docker exec jenkins-demo curl -I https://github.com`
- If using private repos, configure SSH credentials in Jenkins

### Health Check Timeout

**Error**: Application takes too long to start

**Solution**: Increase timeout in `Jenkinsfile` health check stage or wait longer before health checks.

---

## Cleanup

```bash
# Stop Jenkins container
docker stop jenkins-demo

# Remove container
docker rm jenkins-demo

# Remove volume (WARNING: deletes Jenkins data)
docker volume rm jenkins_home

# Remove image
docker rmi jenkins-springboot
```

---

## Next Steps

1. ✅ Pipeline job created and working
2. 📦 JAR artifact available in Jenkins: **springboot-demo-pipeline** → **Artifacts**
3. 🐳 Docker image built: `springboot-demo:latest`
4. 🚀 Deploy image locally or to production server

See [../README.md](../README.md) for Spring Boot application details and local development.
