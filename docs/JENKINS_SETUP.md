# Jenkins Configuration Guide

## Prerequisites

- Jenkins installed and running
- Docker installed on Jenkins agent/master
- Git plugin installed
- Pipeline plugin installed

## Step-by-Step Setup

### 1. Install Required Plugins

Navigate to: **Manage Jenkins → Plugins → Available**

Install:
- Pipeline
- Git
- Maven Integration
- JUnit
- Docker Pipeline (optional)

### 2. Configure Global Tools

Navigate to: **Manage Jenkins → Tools**

#### Maven Configuration
- Click "Add Maven"
- Name: `Maven-3.9`
- Install automatically: Yes
- Version: 3.9.6 (or latest)

#### JDK Configuration
- Click "Add JDK"
- Name: `JDK-17`
- Install automatically: Yes
- Version: Java 17 (LTS)

### 3. Create Pipeline Job

1. **Create New Item**
   - Click "New Item"
   - Enter name: `springboot-pipeline`
   - Select: "Pipeline"
   - Click "OK"

2. **Configure General Settings**
   - Description: "Spring Boot multistage pipeline demo"
   - Discard old builds: Keep last 10 builds

3. **Configure Build Triggers** (Optional)
   - Poll SCM: `H/5 * * * *` (every 5 minutes)
   - OR setup webhook for GitHub/GitLab

4. **Configure Pipeline**
   - Definition: "Pipeline script from SCM"
   - SCM: "Git"
   - Repository URL: `https://github.com/your-username/springboot-demo.git`
   - Credentials: Add if private repo
   - Branch Specifier: `*/main`
   - Script Path: `Jenkinsfile`

5. **Save Configuration**

### 4. Verify Docker Access

Ensure Jenkins can execute Docker commands:

```bash
# On Jenkins server/agent
docker --version
docker ps

# Add jenkins user to docker group (if needed)
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### 5. First Build

1. Click "Build Now"
2. Monitor "Console Output"
3. Verify all stages pass
4. Access application: `http://localhost:8080`

## Webhook Configuration (GitHub)

1. **GitHub Repository Settings**
   - Go to: Settings → Webhooks → Add webhook
   - Payload URL: `http://your-jenkins-url/github-webhook/`
   - Content type: `application/json`
   - Events: "Just the push event"
   - Active: Yes

2. **Jenkins Job Configuration**
   - Build Triggers: Check "GitHub hook trigger for GITScm polling"

## Environment Variables (Optional)

Add in **Pipeline → Environment Variables**:

```groovy
DOCKER_REGISTRY = 'registry.example.com'
KUBECONFIG = credentials('kubeconfig-id')
SONAR_TOKEN = credentials('sonar-token')
```

## Credentials Management

Navigate to: **Manage Jenkins → Credentials**

Add credentials for:
- Git repository access
- Docker registry
- Kubernetes cluster
- Slack webhook (notifications)

## Pipeline Visualization

Install "Blue Ocean" plugin for better pipeline visualization:

```bash
# Access Blue Ocean UI
http://your-jenkins-url/blue/organizations/jenkins/springboot-pipeline/
```

## Troubleshooting

### Permission Denied (Docker)
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Maven Not Found
- Verify Maven is configured in Global Tools
- Check tool name matches Jenkinsfile: `Maven-3.9`

### Git Checkout Fails
- Verify repository URL is correct
- Add credentials if private repository
- Check network connectivity from Jenkins

### Build Fails with "JDK not found"
- Verify JDK 17 is configured in Global Tools
- Check tool name matches Jenkinsfile: `JDK-17`

## Security Best Practices

1. Enable CSRF protection
2. Use credentials for sensitive data
3. Limit job execution to specific agents
4. Enable build timeout
5. Configure workspace cleanup

## Performance Optimization

1. Use agent labels for distributed builds
2. Enable parallel stage execution
3. Cache Maven dependencies
4. Use Docker layer caching
5. Configure build retention policy

## Monitoring

- Configure build notifications (Slack, email)
- Set up build metrics dashboard
- Monitor disk space on Jenkins master/agents
- Track build duration trends

## Backup Strategy

Backup these Jenkins directories:
- `/var/lib/jenkins/jobs/` - Job configurations
- `/var/lib/jenkins/credentials/` - Credentials
- `/var/lib/jenkins/plugins/` - Installed plugins
