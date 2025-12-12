pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
    }
    
    environment {
        APP_NAME = 'springboot-demo'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
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
                    sh "docker build -t ${APP_NAME}:${BUILD_NUMBER} ."
                    sh "docker tag ${APP_NAME}:${BUILD_NUMBER} ${APP_NAME}:latest"
                }
            }
        }
        
        stage('Run Container') {
            steps {
                echo '=== Starting container ==='
                script {
                    sh "docker stop ${APP_NAME} || true"
                    sh "docker rm ${APP_NAME} || true"
                    sh "docker run -d --name ${APP_NAME} -p 8080:8080 ${APP_NAME}:latest"
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo '=== Performing health check ==='
                script {
                    sleep 10
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
        }
        failure {
            echo '=== Pipeline failed ==='
            sh "docker stop ${APP_NAME} || true"
            sh "docker rm ${APP_NAME} || true"
        }
        always {
            cleanWs()
        }
    }
}
