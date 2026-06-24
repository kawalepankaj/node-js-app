pipeline {
    agent any

    parameters {
        string(name: 'IMAGE_TAG', defaultValue: '', description: 'Optional Docker image tag. Defaults to BUILD_NUMBER if blank.')
    }

    environment {
        IMAGE_NAME = "kawalepankaj/node-js-app"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                sh 'npm ci'
                sh 'npm test -- --reporter=tap > test-results.tap'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'test-results.tap', allowEmptyArchive: true
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    env.IMAGE_TAG = params.IMAGE_TAG?.trim() ?: env.BUILD_NUMBER
                }
                sh 'docker build --pull -t "$IMAGE_NAME:$IMAGE_TAG" .'
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'USER',
                        passwordVariable: 'PASS'
                    )
                ]) {
                    sh '''
                    echo "$PASS" | docker login -u "$USER" --password-stdin
                    docker tag "$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAME:latest"
                    docker push "$IMAGE_NAME:$IMAGE_TAG"
                    docker push "$IMAGE_NAME:latest"
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                set -e
                command -v envsubst >/dev/null
                export IMAGE_TAG="$IMAGE_TAG"
                envsubst '${IMAGE_TAG}' < deployment.yaml | kubectl apply -f -
                kubectl apply -f configmap.yaml
                kubectl apply -f service.yaml
                kubectl rollout status deployment/node-js-app --timeout=120s
                '''
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
