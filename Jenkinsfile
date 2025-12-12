pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
    }
    
    environment {
        APP_NAME = 'springboot-demo'
        APP_PORT = '8081'
    }
    
    parameters {
        booleanParam(name: 'DOCKER_BUILD', defaultValue: true, description: 'Build Docker image')
        booleanParam(name: 'DEPLOY', defaultValue: false, description: 'Deploy to server')
        string(name: 'DEPLOY_HOST', defaultValue: 'localhost', description: 'Deployment server hostname/IP')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '=== Checking out code ==='
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo '=== Building application ==='
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                echo '=== Running tests ==='
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Package') {
            steps {
                echo '=== Packaging application ==='
                sh 'mvn package -DskipTests'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '=== Building Docker image ==='
                script {
                    sh '''
                        docker build -t ${APP_NAME}:${BUILD_NUMBER} .
                        docker tag ${APP_NAME}:${BUILD_NUMBER} ${APP_NAME}:latest
                        docker images | grep ${APP_NAME}
                    '''
                }
            }
        }
        
        stage('Run Docker Container') {
            steps {
                echo '=== Running Docker container ==='
                script {
                    sh '''
                        # Stop and remove existing container
                        docker stop ${APP_NAME} 2>/dev/null || true
                        docker rm ${APP_NAME} 2>/dev/null || true
                        
                        # Run new container
                        docker run -d -p 8080:8080 --name ${APP_NAME} ${APP_NAME}:latest
                        echo "Container started on port 8080"
                        
                        # Wait for app to start
                        sleep 5
                        
                        # Health check
                        echo "=== Health Check ==="
                        curl -s http://localhost:8080/health || echo "App not ready yet"
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo '=== Pipeline completed successfully ==='
            script {
                if (params.DEPLOY) {
                    echo "Application deployed to: http://${params.DEPLOY_HOST}:${APP_PORT}"
                } else {
                    echo "Build artifacts ready:"
                    echo "  JAR: target/demo-1.0.0.jar"
                    echo "  Docker: ${APP_NAME}:latest"
                    echo "  Build: ${BUILD_NUMBER}"
                }
            }
        }
        failure {
            echo '=== Pipeline failed ==='
        }
        always {
            echo '=== Build Complete ==='
            echo "Status: ${currentBuild.result}"
        }
    }
}
