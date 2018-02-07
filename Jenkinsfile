pipeline {
    agent any
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
    environment { 
        image_name = "asia.gcr.io/personal-project/golangweb:1.0.${BUILD_NUMBER}"
        PATH="$PATH:/usr/lib/go-1.9/bin"
        GOPATH="$WORKSPACE"
    }
    stages {
        stage('Checkout') {
            steps {
                sh "mkdir -p $GOPATH/src/github.com/KongZ/golangweb"
                dir("$GOPATH/src/github.com/KongZ/") {
                    git url: 'git@github.com:KongZ/golangweb.git', credentialsId: 'github', branch: 'master'
                }
            }
        }
        stage('Build') {
            steps {
                dir("$GOPATH/src/github.com/KongZ/golangweb") {
                    sh "go get ./..."
                    sh "go build"
                }
            }
        }
        stage('Test') {
            steps {
                dir("$GOPATH/src/github.com/KongZ/golangweb") {
                    sh "go test"
                }
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