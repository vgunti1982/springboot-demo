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
            when {
                expression { params.DOCKER_BUILD == true }
            }
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
        
        stage('Deploy to Server') {
            when {
                expression { params.DEPLOY == true }
            }
            steps {
                echo '=== Deploying application to ${params.DEPLOY_HOST} ==='
                script {
                    sh '''
                        # Copy JAR to deployment server
                        scp -o StrictHostKeyChecking=no target/demo-1.0.0.jar ${DEPLOY_USER}@${params.DEPLOY_HOST}:/opt/springboot/
                        
                        # Restart application on deployment server
                        ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${params.DEPLOY_HOST} << 'EOF'
                            echo "Stopping existing application..."
                            pkill -f "demo-1.0.0.jar" || true
                            sleep 3
                            
                            echo "Starting new application..."
                            cd /opt/springboot
                            nohup java -jar demo-1.0.0.jar > app.log 2>&1 &
                            sleep 10
                            
                            # Verify process is running
                            if ps aux | grep -q "[j]ava -jar demo-1.0.0.jar"; then
                                echo "Application started successfully"
                                ps aux | grep "[j]ava -jar demo-1.0.0.jar"
                            else
                                echo "Application failed to start"
                                tail -20 app.log
                                exit 1
                            fi
                        EOF
                    '''
                }
            }
        }
        
        stage('Health Check - Remote') {
            when {
                expression { params.DEPLOY == true }
            }
            steps {
                echo '=== Performing remote health check ==='
                script {
                    sh '''
                        echo "Waiting for application to be ready..."
                        for i in {1..30}; do
                            if curl -s http://${params.DEPLOY_HOST}:${APP_PORT}/health | grep -q "OK"; then
                                echo "Health check passed!"
                                exit 0
                            fi
                            echo "Attempt $i: Waiting for application..."
                            sleep 2
                        done
                        
                        echo "Health check failed after 60 seconds"
                        exit 1
                    '''
                }
            }
        }
        
        stage('Smoke Test - Remote') {
            when {
                expression { params.DEPLOY == true }
            }
            steps {
                echo '=== Running remote smoke tests ==='
                script {
                    sh '''
                        echo "Testing main endpoint..."
                        response=$(curl -s http://${params.DEPLOY_HOST}:${APP_PORT}/)
                        echo "Response: $response"
                        
                        if echo "$response" | grep -q "Hello World"; then
                            echo "✓ Smoke test PASSED"
                        else
                            echo "✗ Smoke test FAILED"
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        stage('Unit Tests Only') {
            when {
                expression { params.DEPLOY == false }
            }
            steps {
                echo '=== Jenkins on different server - deployment skipped ==='
                sh 'echo "JAR built and available at: target/demo-1.0.0.jar"'
                sh 'echo "Docker image ready: ${APP_NAME}:latest"'
                sh 'echo "Use DEPLOY parameter to deploy to remote server"'
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
