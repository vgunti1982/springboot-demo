# SpringBoot Jenkins Multistage Pipeline Demo

A simple Spring Boot application demonstrating Jenkins multistage pipeline integration with Docker containerization.

## Features

- RESTful web service with two endpoints
- JUnit tests
- Maven build automation
- Docker containerization
- Jenkins multistage pipeline
- Automated health checks and smoke tests

## Endpoints

- `GET /` - Returns "Hello World from Jenkins Pipeline!"
- `GET /health` - Returns "OK" (health check endpoint)

## Prerequisites

- Java 17+
- Maven 3.9+
- Docker
- Jenkins with:
  - Maven plugin
  - JDK 17 configured
  - Docker available on Jenkins agent

## Local Development

### Build and Run

```bash
# Build
mvn clean package

# Run
java -jar target/demo-1.0.0.jar

# Test endpoints
curl http://localhost:8080/
curl http://localhost:8080/health
```

### Run Tests

```bash
mvn test
```

### Docker Build and Run

```bash
# Build image
docker build -t springboot-demo .

# Run container
docker run -d -p 8080:8080 --name springboot-demo springboot-demo

# Check logs
docker logs springboot-demo

# Stop container
docker stop springboot-demo
docker rm springboot-demo
```

## Jenkins Setup

### 1. Configure Tools (Manage Jenkins → Tools)

**Maven Installation:**
- Name: `Maven-3.9`
- Version: 3.9.x or higher

**JDK Installation:**
- Name: `JDK-17`
- Version: Java 17

### 2. Create Pipeline Job

1. New Item → Pipeline
2. Enter name: `springboot-pipeline`
3. Configure:
   - **Pipeline Definition:** Pipeline script from SCM
   - **SCM:** Git
   - **Repository URL:** `<your-git-repo-url>`
   - **Branch Specifier:** `*/main`
   - **Script Path:** `Jenkinsfile`
4. Save

### 3. Run Pipeline

- Click "Build Now"
- Monitor Console Output
- Access application at `http://localhost:8080`

## Pipeline Stages

1. **Checkout** - Clone repository
2. **Build** - Compile Java source code
3. **Test** - Execute JUnit tests
4. **Package** - Create JAR artifact
5. **Build Docker Image** - Containerize application
6. **Run Container** - Deploy container locally
7. **Health Check** - Verify `/health` endpoint
8. **Smoke Test** - Verify application response

## Project Structure

```
springboot-demo/
├── src/
│   ├── main/
│   │   └── java/
│   │       └── com/
│   │           └── example/
│   │               └── demo/
│   │                   └── Application.java
│   └── test/
│       └── java/
│           └── com/
│               └── example/
│                   └── demo/
│                       └── ApplicationTest.java
├── Dockerfile
├── Jenkinsfile
├── pom.xml
└── README.md
```

## Troubleshooting

### Port Already in Use
```bash
docker stop springboot-demo
docker rm springboot-demo
```

### Maven Build Fails
- Verify JDK 17 is installed
- Check internet connectivity for dependency download

### Docker Image Build Fails
- Ensure Docker daemon is running
- Verify Docker is accessible from Jenkins

### Pipeline Fails at Health Check
- Increase sleep duration in Jenkinsfile
- Check container logs: `docker logs springboot-demo`

## Enhancement Ideas

- Add SonarQube code analysis stage
- Implement deployment to Kubernetes
- Add performance testing stage
- Configure webhook triggers
- Implement blue-green deployment
- Add Slack/email notifications

## License

MIT
