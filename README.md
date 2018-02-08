Getting Start with Docker
=========================

This project contains simple web server written in Golang. The code demonstrating several techniques to serve HTTP request/response and docker features.
* `GET /version` will return response body in JSON
* `GET /health` will return HTTP status *OK (200)* without body
* `GET /content` will return plain text response by read it from text file
* `GET /ready` will delay *OK (200)* response 10 seconds after server is started. If clients request to this endpoint before 10 seconds, the response *Service Unavailable (503)* will be return.
## Start Go web server
Before start with docker, try to build and run the web server on local machine so you will familiar with the server.

Compile project
```
go build
```

Run project from source code on local machine
```
PORT=8000 go run main.go
```
Or you can build an executable file and run from command line
```
go install
```
Then run a server from 

```
PORT=8000 $GOPATH/bin/web
```


## Build docker image
The docker image is built from `Dockerfile`. The `Dockerfile` is a text document that contains all the commands for assembling an image container

```
docker build . -t asia.gcr.io/personal-project/golangweb:1.0
```

Use `-t` to tag a docker image with name and version. The sample above will name the image with `asia.gcr.io/personal-project/golangweb` and version `1.0`

## Run docker image
Uses the following command to run the docker image.
* `-e` will set environment variables to a container
* `-p` will publish a container's port to the host from `{host}:{container}`
* `-v` will bind mount a volume from `{host}:{container}`

```
docker run -e PORT=8080 -p 8080:8080 -v /Users/Kong/go/src/golang/web/data:/data asia.gcr.io/personal-project/golangweb:1.0
```

## Remove container
After run the container, you can view running container from the command.

```
docker ps
```

And you can remove running container from
```
docker rm -f {container_id}
```

## Clean Images
Docker always left a lot of junks when build images, you can clean up all unused data using this command.

```
docker system prune
```

Getting Start with Kubernetes
=============================

## Create Kubernetes Cluster
This document will use Google Cloud for running Kubernetes Cluster. So I would recommend using GCloud console to create a Kubernetes Cluster.

https://cloud.google.com/kubernetes-engine/docs/quickstart

## Install gcloud
Since we are using Google Cloud, it is strongly recommend to use `gcloud` command to manage the GCloud. To install the `gcloud` on Mac use

```
curl https://sdk.cloud.google.com | bash
```
For Windows 
https://cloud.google.com/sdk/downloads

After install, you need to initialing `gcloud` command. Run

```
gcloud init
```

## Connect to Google Cloud
To connect and authenticate with Kubernetes uses this command

```
gcloud container clusters get-credentials {cluster_name} --zone {zone} --project {gcloud_project_id}
```

## Install kubctl
Kubernetes heavily uses `kubctl` command line to manage the cluster. To install the `kubctl` on Mac uses

```
brew install kubectl
```

For Windows
https://kubernetes.io/docs/tasks/tools/install-kubectl/

## Initialize kubectl
After install successfully, you can get cluster information from this command.

```
kubectl cluster-info
```

## Deploy Kubernetes Dashboard
The Google Cloud has a built-in dashboard container engine on console. But it is still early access with limited features. 

You can install Kubernetes dashboard application use this command

```
kubectl create -f kube-tools/kube-dashboard.yaml
```

Start a `kubectl` proxy to access Kubernetes application on localhost.
```
kubectl proxy
```

## Login Dashboard
Since Kubernetes version 1.7, the dashboard no longer has admin privileges granted by default. Kubernetes dashboard supports several type of authentication. The default is Bearer Token. You can find more information about dashboard authentication from  https://github.com/kubernetes/dashboard/wiki/Access-control

To get a Token for logging in to dashboard use this command to list all secret object in cluster.

```
kubectl -n kube-system get secret
```
It will display a list of secret as shown below
```
NAME                                     TYPE                                  DATA      AGE
attachdetach-controller-token-7xspz      kubernetes.io/service-account-token   3         22h
certificate-controller-token-d6b5j       kubernetes.io/service-account-token   3         22h
cloud-provider-token-z5tf7               kubernetes.io/service-account-token   3         22h
cronjob-controller-token-tkjsp           kubernetes.io/service-account-token   3         22h
daemon-set-controller-token-88lf4        kubernetes.io/service-account-token   3         22h
default-token-ctgqh                      kubernetes.io/service-account-token   3         22h
deployment-controller-token-lwttt        kubernetes.io/service-account-token   3         22h
kubernetes-dashboard-certs               Opaque                                0         22h
kubernetes-dashboard-key-holder          Opaque                                2         22h
kubernetes-dashboard-token-gh8mp         kubernetes.io/service-account-token   3         22h
```

And use this command to read a secret
```
kubectl -n kube-system describe secret kubernetes-dashboard-token-gh8mp
```

You can get a token with single command 
```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | awk '/^kubernetes-dashboard-token-/{print $1}') | awk '$1=="token:"{print $2}'
```

## Deploy Application
To deploy an application, you need to push a docker image to container registry. To push docker image to GCloud container registry uses

```
gcloud docker -- push asia.gcr.io/personal-project/golangweb:1.0
```
Kubernetes uses Deployment configuration to instruct Kubernetes on how to create and update instances.
The deployment configuration for this project can be found in directory `kubernetes`

Before deploy an application. It is strongly suggest to create namespace for each application. Namespaces provide a scope for names. Names of resources need to be unique within a namespace, but not across namespaces.

```
kubectl create namespace golang
```

And uses this command to deploy `golangweb` application.

```
kubectl --namespace golang create -f kubernetes/deployment.yaml
```

Once deployment is created, Kubernetes will create a Pod. A Pod is a group of one or more containers.

## Deploy Service
Pods are mortal. They are born and die. To keep your service alive when Pods are dead. You have to create a Kubernetes Service. A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called a micro-service. 

Uses this command to create a service for `golangweb` application.

```
kubectl --namespace golang create -f kubernetes/service.yaml
```

Kubernetes supports the following service type
* ClusterIP (default) - Exposes the Service on an internal IP in the cluster. This type makes the Service only reachable from within the cluster.
* NodePort - Exposes the Service on the same port of each selected Node in the cluster using NAT. Makes a Service accessible from outside the cluster using <NodeIP>:<NodePort>. Superset of ClusterIP.
* LoadBalancer - Creates an external load balancer in the current cloud (if supported) and assigns a fixed, external IP to the Service. Superset of NodePort.
* ExternalName - Exposes the Service using an arbitrary name (specified by externalName in the spec) by returning a CNAME record with the name. No proxy is used. This type requires v1.7 or higher of kube-dns.


## Update Application on Kubernetes
Sometime you may need to modify your deployment such as upgrade the application or change environment variables. To modify them you have to edit the deployment configuration and use `kubectl apply` command to update the deployment.

```
kubectl --namespace golang apply -f kubernetes/deployment.yaml
```
## Access to Pod
In most case, you can observe your application from Kubernetes dashboard and `kubctl log` command. But you can also access to the container using this command 

```
kubectl --namespace golang exec -it {pod_name} /bin/bash
```

Helm Chart
==========
Helm is a tool that streamlines installing and managing Kubernetes applications just like the `apt` or `yum` tools.

## Install helm

```
brew install kubernetes-helm

```
Once Helm is installed on your machine, you have to initialize the local CLI and also install Tiller into your Kubernetes cluster using this command
```
helm init
```

Since Kubernetes version 1.8, the RBAC is enabled by default on the cluster. So every applications which require to access Kubernetes API, need to grant the permission to the applications. So you need to grant they `kube-system` service account role to `tiller` admin

```
kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
```

## Example install application on Kubernetes using helm

```
kubectl create namespace mongodb
helm install --namespace mongodb --name mongodb --set mongodbRootPassword=secretpassword,mongodbUsername=my-user,mongodbPassword=my-password,mongodbDatabase=my-database stable/mongodb
```

## Write your own helm chart
The example of this project chart can be found on directory `chart/golangweb`

You can verify chart correctness by using
```
helm lint chart/golangweb
```

Try deploy this project chart
```
helm install --namespace golang --name webhelm chart/golangweb
```

## StatefulSets
Unlike a Deployment, a StatefulSet maintains a sticky identity for each of their Pods.
StatefulSets are valuable for applications that require one or more of the following.
* Stable, unique network identifiers.
* Stable, persistent storage.
* Ordered, graceful deployment and scaling.
* Ordered, graceful deletion and termination.
* Ordered, automated rolling updates.

Try deploy this project chart as StatefulSets
```
helm install --namespace golang --name webhelm chart/golangweb-stateful
```

After application is successfully run. Use the following command to get a Pod name
```
kubectl --namespace golang get pod
```
Then remote to the pod
```
kubectl --namespace golang exec -it webstateful-golangweb-stateful-0 /bin/sh
```
Create a new content for `GET /content` request
```
echo "This is statefulset" > /data/content.txt
```
Test the result. Then delete a running pod
```
kubectl --namespace golang delete pod webstateful-golangweb-stateful-0
```
Kubernetes will start a new pod immediately since our replica settings is `1`. Kubernetes always maintain the availability of the service.

Scale
=====
To scale up/down statefulsets or deploy you can use the commands
```
kubectl scale statefulsets <stateful-set-name> --replicas=<new-replicas>
kubectl scale deployment <deployment-name> --replicas=<new-replicas>
```

External DNS
============
ExternalDNS makes Kubernetes resources discoverable via public DNS servers https://github.com/kubernetes-incubator/external-dns

The simplest way to install External DNS on Kubernetes is using Helm.

```
kubectl create namespace external-dns
```
```
helm --namespace external-dns install --name external-dns stable/external-dns --set google.project="personal-project" --set provider=google --set txtOwnerId="5473CAF1-1074-4DA2-825C-7A23418FF98A" --set domainFilters=\{"yourdomain.com"\}
```

Note: if `external-dns` is not able to add a record set to cloud-dns, you may need to create a container cluster with `https://www.googleapis.com/auth/ndev.clouddns.readwrite` permission.
```
gcloud container clusters create clusterName --zone us-central1-a --project personal-project --num-nodes=1 --machine-type=g1-small --scopes="gke-default,https://www.googleapis.com/auth/ndev.clouddns.readwrite"
```

Getting Start with Jenkins
==========================
It is strongly recommend to use Jenkins pipeline to supports implementing and integrating continuous delivery. The definition of a Jenkins Pipeline is written into a text file (called a Jenkinsfile) which in turn can be committed to a project’s source control repository.

To setup a Jenkins for Google Kubernetes
1) Install `gcloud`
```
# Create an environment variable for the correct distribution
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

# Add the Cloud SDK distribution URI as a package source
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install google-cloud-sdk
```
```
gcloud init
```

2) Install `kubectl`
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

3) Install `helm`
```
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.8.0-linux-amd64.tar.gz
tar -zxvf helm-v2.8.0-linux-amd64.tgz
mv linux-amd64/helm /usr/local/bin/helm
```

4) Create Service Account
5) Copy key file to `/var/lib/jenkins/service-account.json`
6) Change file owner `chown jenkins:jenkins /var/lib/jenkins/service-account.json`
7) Change to jenkins user `su jenkins`
8) Add service account `gcloud auth activate-service-account --key-file=/var/lib/jenkins/service-account.json`
9) Authenticate container cluster `gcloud container clusters get-credentials {cluster_name} --zone {zone_name} --project {project_id}`
10) Initialize helm `helm init`
11) Generate ssh key `ssh-keygen -t rsa -b 4096 -o`
12) Add ssh key to GitHub