# Spring Boot Demo Application

A simple, production-ready Spring Boot application demonstrating REST endpoints with automated testing, Docker containerization, and Jenkins CI/CD integration.

## Quick Start (Local Development)

```bash
# Build
mvn clean package

# Run
java -jar target/demo-1.0.0.jar

# Test endpoints
curl http://localhost:8081/
curl http://localhost:8081/health
```

Application runs on **http://localhost:8081**

---

## Features

- ✅ RESTful endpoints with health checks
- ✅ Comprehensive unit tests (JUnit 5, Spring Boot Test)
- ✅ Docker containerization with health monitoring
- ✅ Maven build automation (Java 17, Spring Boot 3.2)
- ✅ Jenkins CI/CD pipeline integration
- ✅ Production-ready error handling

## Endpoints

| Method | Path | Response | Purpose |
|--------|------|----------|---------|
| `GET` | `/` | `Hello World from Jenkins Pipeline!` | Main endpoint |
| `GET` | `/health` | `OK` | Health check |

## Prerequisites

- **Java**: 17 or higher
- **Maven**: 3.9 or higher
- **Docker**: For containerization (optional)

## Local Development

### 1. Build

```bash
mvn clean compile
```

This compiles source code and validates configuration.

### 2. Run Tests

```bash
mvn test
```

Executes JUnit test suite:
- `testHelloEndpoint()` - Verifies `/` endpoint returns correct message
- `testHealthEndpoint()` - Verifies `/health` endpoint returns `OK`

View test report: `target/surefire-reports/`

### 3. Package

```bash
mvn package
```

Creates executable JAR: `target/demo-1.0.0.jar`

### 4. Run Application

```bash
java -jar target/demo-1.0.0.jar
```

Application starts on port **8081** (configured in `src/main/resources/application.properties`).

### 5. Test Endpoints

```bash
# Main endpoint
curl http://localhost:8081/

# Health check
curl http://localhost:8081/health

# JSON format (verbose)
curl -i http://localhost:8081/health
```

---

## Docker

### Build Docker Image

```bash
# Build from Dockerfile
docker build -t springboot-demo .

# Verify image
docker images | grep springboot-demo
```

The `Dockerfile` uses:
- **Base**: `eclipse-temurin:17-jre-alpine` (lightweight, security-patched)
- **Port**: `8080` (container port)
- **Health Check**: Monitors `/health` endpoint every 30 seconds

### Run Docker Container

```bash
# Run container
docker run -d \
  -p 8080:8080 \
  --name springboot-app \
  springboot-demo

# Check logs
docker logs springboot-app

# Test endpoints
curl http://localhost:8080/
curl http://localhost:8080/health

# View running containers
docker ps | grep springboot

# Stop container
docker stop springboot-app

# Remove container
docker rm springboot-app
```

### Health Checks in Docker

The Dockerfile includes a health check that verifies the application is running:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
```

- **Interval**: 30 seconds between checks
- **Start Period**: 40 seconds before first check
- **Timeout**: 3 seconds per check
- **Retries**: 3 failed checks before marking unhealthy

View health status:
```bash
docker inspect springboot-app --format='{{.State.Health.Status}}'
```

---

## Project Structure

```
springboot-demo/
├── src/
│   ├── main/
│   │   ├── java/com/example/demo/
│   │   │   └── Application.java       # REST endpoints, main class
│   │   └── resources/
│   │       └── application.properties # Port, app name config
│   └── test/
│       └── java/com/example/demo/
│           └── ApplicationTest.java   # Unit tests
├── Dockerfile                          # App container definition
├── Dockerfile.jenkins                  # Jenkins container definition
├── Jenkinsfile                         # CI/CD pipeline configuration
├── pom.xml                            # Maven build configuration
├── README.md                          # This file
└── docs/
    └── README_JENKINS.md              # Jenkins setup guide
```

## Configuration

### Application Port

Default: **8081**

Modify in `src/main/resources/application.properties`:
```properties
server.port=8081
spring.application.name=springboot-demo
```

Then rebuild:
```bash
mvn clean package
java -jar target/demo-1.0.0.jar
```

---

## Build with Maven

### All-in-One: Build, Test, Package

```bash
mvn clean package
```

This runs in sequence:
1. `clean` - Removes previous build
2. `compile` - Builds source code
3. `test` - Runs unit tests
4. `package` - Creates JAR

### Skip Tests (Faster Build)

```bash
mvn clean package -DskipTests
```

Used in CI/CD pipelines for speed (tests run separately).

### View Maven Dependencies

```bash
mvn dependency:tree
```

Key dependencies (from `pom.xml`):
- `spring-boot-starter-web` - REST framework
- `spring-boot-starter-test` - Test utilities (JUnit 5, Mockito)

---

## Jenkins CI/CD Pipeline

The application integrates with Jenkins for automated builds. See [docs/README_JENKINS.md](docs/README_JENKINS.md) for:
- Setting up Jenkins with Docker
- Creating and running the pipeline
- Build parameters and artifacts
- Troubleshooting

Pipeline workflow:
```
Checkout → Build → Test → Package → Docker Image → ✅ Ready
```

---

## Troubleshooting

### Port Already in Use

**Error**: `Address already in use :8081`

```bash
# Find process using port 8081
lsof -i :8081

# Kill process (if safe)
kill -9 <PID>

# Or use different port
java -jar target/demo-1.0.0.jar --server.port=9000
```

### Maven Build Fails

**Error**: `Unrecognized option: --release: 17`

**Solution**: Upgrade Maven
```bash
# Check version
mvn --version

# Download Maven 3.9+
# https://maven.apache.org/download.cgi
```

**Error**: `OutOfMemoryException`

**Solution**: Increase heap memory
```bash
export MAVEN_OPTS="-Xmx512m"
mvn clean package
```

### Docker Build Fails

**Error**: `permission denied`

**Solution**: Ensure Docker daemon is running
```bash
docker ps  # Should work without errors
```

**Error**: `Dockerfile not found`

**Solution**: Run from repo root
```bash
cd /path/to/springboot-demo
docker build -t springboot-demo .
```

### Application Won't Start

**Error**: `Failed to start Tomcat`

Check logs for port conflicts or missing dependencies:
```bash
java -jar target/demo-1.0.0.jar 2>&1 | head -50
```

---

## Performance Tips

- **Skip tests during dev** (if repeatedly rebuilding):
  ```bash
  mvn package -DskipTests
  ```
- **Use Docker** for consistent environments across machines
- **Monitor health check logs** in production:
  ```bash
  docker logs --tail 20 springboot-app
  ```

---

## License

MIT

## Support

For Jenkins setup, see [docs/README_JENKINS.md](docs/README_JENKINS.md)  
For issues or contributions, open a GitHub issue or pull request.
