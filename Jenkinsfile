pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Validate') {
            steps {
                echo 'Running project validation...'
                sh 'make verify'
            }
        }

        stage('Security Scan') {
            steps {
                echo 'Running Trivy security scan...'
                sh 'make scan || true'
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker images...'
                sh 'make docker-build'
            }
        }

        stage('Docker Push') {
            steps {
                echo 'Pushing Docker images...'
                sh 'make docker-push'
            }
        }
    }

    post {
        success {
            echo '✅ Enterprise Online Boutique CI Pipeline completed successfully!'
        }

        failure {
            echo '❌ Enterprise Online Boutique CI Pipeline failed!'
        }
    }
}
