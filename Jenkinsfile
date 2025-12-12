pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
    }
    
    environment {
        APP_NAME = 'springboot-demo'
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
        
        stage('Run Application') {
            steps {
                echo '=== Starting application ==='
                script {
                    // Kill existing process if running
                    sh '''
                        pkill -f "demo-1.0.0.jar" || true
                        sleep 3
                    '''
                    
                    // Verify JAR exists
                    sh 'ls -lh target/demo-1.0.0.jar'
                    
                    // Start application in background
                    sh '''
                        nohup java -jar target/demo-1.0.0.jar > app.log 2>&1 &
                        APP_PID=$!
                        echo $APP_PID > app.pid
                        echo "Started app with PID: $APP_PID"
                        sleep 15
                    '''
                    
                    // Verify process is running
                    sh 'ps aux | grep demo-1.0.0.jar | grep -v grep'
                    
                    // Show initial logs
                    sh 'head -20 app.log'
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo '=== Performing health check ==='
                script {
                    // Check if app is running
                    sh 'ps aux | grep demo-1.0.0.jar || true'
                    sh 'cat app.log || true'
                    
                    // Try health check with retries
                    retry(3) {
                        sleep 5
                        sh 'curl -f http://localhost:8081/health'
                    }
                }
            }
        }
        
        stage('Smoke Test') {
            steps {
                echo '=== Running smoke tests ==='
                script {
                    def response = sh(script: 'curl -s http://localhost:8081/', returnStdout: true).trim()
                    echo "Response received: ${response}"
                    
                    if (!response.contains('Hello World')) {
                        sh 'cat app.log'
                        error("Smoke test failed! Expected 'Hello World', got: ${response}")
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo '=== Pipeline completed successfully ==='
            echo "Application running at: http://localhost:8081"
            echo "View logs: cat app.log"
        }
        failure {
            echo '=== Pipeline failed ==='
            script {
                sh 'pkill -f "demo-1.0.0.jar" || true'
            }
        }
        always {
            echo '=== Cleaning workspace ==='
            // Keep app running, only clean build artifacts
            sh 'rm -f app.pid'
        }
    }
}
