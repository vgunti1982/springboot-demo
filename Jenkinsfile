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
                        sleep 2
                    '''
                    
                    // Start application in background
                    sh '''
                        nohup java -jar target/demo-1.0.0.jar > app.log 2>&1 &
                        echo $! > app.pid
                        sleep 10
                    '''
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo '=== Performing health check ==='
                script {
                    sh 'curl -f http://localhost:8080/health || exit 1'
                }
            }
        }
        
        stage('Smoke Test') {
            steps {
                echo '=== Running smoke tests ==='
                script {
                    def response = sh(script: 'curl -s http://localhost:8080/', returnStdout: true).trim()
                    if (!response.contains('Hello World')) {
                        error('Smoke test failed!')
                    }
                    echo "Response: ${response}"
                }
            }
        }
    }
    
    post {
        success {
            echo '=== Pipeline completed successfully ==='
            echo "Application running at: http://localhost:8080"
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
