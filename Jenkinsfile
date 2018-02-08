pipeline {
    agent any
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
    environment { 
        image_name = "asia.gcr.io/cms-container-fortest/golangweb:1.0"
        PATH="$PATH:/usr/lib/go-1.8/bin"
        GOPATH="$WORKSPACE"
    }
    stages {
        stage('Checkout') {
            steps {
                sh "mkdir -p $GOPATH/src/github.com/KongZ/golangweb"
                dir("$GOPATH/src/github.com/KongZ/golangweb") {
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
               sh "helm install --namespace golang --name web chart/golangweb"
            }
        }
    }
}