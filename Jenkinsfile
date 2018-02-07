pipeline {
    agent any
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
    environment { 
        image_name = "asia.gcr.io/personal-project/golangweb:1.0.${BUILD_NUMBER}"
    }
    stages {
        stage('Build') {
            steps {
               sh "go get ./..."
               sh "go build"
            }
        }
        stage('Test') {
            steps {
               sh "go test"
            }
        }
        stage('Package') {
            steps {
               sh "docker build . -t ${image_name}"
            }
        }
        stage('Deploy') {
            steps {
               sh "gcloud docker -- push ${image_name}"
               sh "helm install --namespace golang --name ${BUILD_NUMBER} chart/golangweb"
            }
        }
    }
}