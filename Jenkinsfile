pipeline {
    agent any

    environment {
        IMAGE_NAME = "dockerhubusername/node-js-app"
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/username/sample-node-app.git'
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
            }
        }

        stage('Test') {
            steps {
                sh 'npm install'
                sh 'npm test'
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([
                  usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS')
                ]) {

                    sh '''
                    echo $PASS | docker login -u $USER --password-stdin
                    docker tag $IMAGE_NAME:$BUILD_NUMBER \
                    $IMAGE_NAME:latest

                    docker push $IMAGE_NAME:$BUILD_NUMBER
                    docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker stop sample-app || true
                docker rm sample-app || true

                docker run -d \
                --name sample-app \
                -p 80:3000 \
                $IMAGE_NAME:latest
                '''
            }
        }
    }
}
