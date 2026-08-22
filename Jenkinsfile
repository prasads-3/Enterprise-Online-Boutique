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

                withCredentials([
                    usernamePassword(
                        credentialsId: 'DockerHubJack',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin

                        make docker-push

                        docker logout
                    '''
                }
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
