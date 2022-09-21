# reference-letters-system
A web system about reference letter handling in the context of DIT HUA Thesis "Use of devops methodologies and tools in development and production environment of web applications"

<p align="left"> <img src="https://komarev.com/ghpvc/?username=panagiotis-bellias-it21871&label=Profile%20views&color=0e75b6&style=flat" alt="panagiotis-bellias-it21871" /> </p>

<h3 align="left">Languages and Tools:</h3>
<p align="left"> <a href="https://azure.microsoft.com/en-in/" target="_blank"> <img src="https://www.vectorlogo.zone/logos/microsoft_azure/microsoft_azure-icon.svg" alt="azure" width="40" height="40"/> </a> <a href="https://www.gnu.org/software/bash/" target="_blank"> <img src="https://www.vectorlogo.zone/logos/gnu_bash/gnu_bash-icon.svg" alt="bash" width="40" height="40"/> </a> <a href="https://getbootstrap.com" target="_blank"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/bootstrap/bootstrap-plain-wordmark.svg" alt="bootstrap" width="40" height="40"/> </a> <a href="https://www.w3schools.com/css/" target="_blank"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/css3/css3-original-wordmark.svg" alt="css3" width="40" height="40"/> </a>
<a href="https://www.docker.com/" target="_blank"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/docker/docker-original-wordmark.svg" alt="docker" width="40" height="40"/> </a>
<a href="https://git-scm.com/" target="_blank"> <img src="https://www.vectorlogo.zone/logos/git-scm/git-scm-icon.svg" alt="git" width="40" height="40"/> </a> <a href="https://www.w3.org/html/" target="_blank"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/html5/html5-original-wordmark.svg" alt="html5" width="40" height="40"/> </a> <a href="https://www.jenkins.io" target="_blank"> <img src="https://www.vectorlogo.zone/logos/jenkins/jenkins-icon.svg" alt="jenkins" width="40" height="40"/> </a> <a href="https://kubernetes.io" target="_blank"> <img src="https://www.vectorlogo.zone/logos/kubernetes/kubernetes-icon.svg" alt="kubernetes" width="40" height="40"/> </a> <a href="https://www.linux.org/" target="_blank"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/linux/linux-original.svg" alt="linux" width="40" height="40"/> </a> <a href="https://www.nginx.com" target="_blank"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/nginx/nginx-original.svg" alt="nginx" width="40" height="40"/> </a> <a href="https://www.postgresql.org" target="_blank"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/postgresql/postgresql-original-wordmark.svg" alt="postgresql" width="40" height="40"/> </a> <a href="https://www.python.org" target="_blank"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/python/python-original.svg" alt="python" width="40" height="40"/> </a>
</p>

<a name="contents"></a>
## Table Of Contents
1. [Table Of Contents](#contents)  
2. [Setup & Run Projects Locally (Installation)](#locally)  
3. [Deploy fastapi and vuejs projects to a VM (Virtual Machine)](#deployment)  
3.1. [CI/CD tool configuration (Jenkins Server)](#jenkins)  
3.1.1. [Step 1: Configure Shell](#conf_shell)  
3.1.2. [Step 2: Add webhooks to system repository](#webhooks)  
3.1.3. [Step 3: Add the credentials needed](#credentials)  
3.1.4. [Create Job](#job)  
3.1.4.1. [Build stage](#build)  
3.1.4.2. [Docker Deployment](#j-docker)  
3.1.4.3. [Kubernetes Deployment](#j-k8s)  
3.2. [Deployment with Docker and docker-compose using Ansible](#docker)  
3.3. [Deployment with Kubernetes using a piece of Ansible](#k8s)  
3.3.1. [Using Multiple Namespaces](#multiple-namespaces)   

<a name="locally"></a>
## Setup & Run Projects Locally (Installation)

### Clone repository with submodules
```bash
git clone --recurse-submodules https://github.com/panagiotis-bellias-it21871/reference-letters-system.git
cd reference-letters-system
```

For Python FastAPI project see [here](https://github.com/panagiotis-bellias-it21871/reference-letters-fastapi-server#run-project-locally-installation) and for JavaScript VueJS project see [here](https://github.com/panagiotis-bellias-it21871/reference-letters-vuejs-client#project-setup)

<a name="deployment"></a>
## Deploy fastapi and vuejs projects to a VM (Virtual Machine)

We are going to need 3 VMs. One for the jenkins server and one for each execution environment (docker and kubernetes)

* [Create VM in Azure Portal](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal)
* [SSH Access to VMs](https://help.skytap.com/connect-to-a-linux-vm-with-ssh.html)
* [SSH Automation](https://linuxize.com/post/using-the-ssh-config-file/)
* [Reserve Static IP in Azure](https://azure.microsoft.com/en-au/resources/videos/azure-friday-how-to-reserve-a-public-ip-range-in-azure-using-public-ip-prefix/)

<a name="jenkins"></a>
### CI/CD tool configuration (Jenkins Server)

* [Install Jenkins](https://www.jenkins.io/doc/book/installing/linux/)

Make sure service is running
```bash
sudo systemctl status jenkins
netstat -anlp | grep 8080 # needs package net-tools
```

http://PUBLIC-IP:8080/

<a name="conf_shell"></a>
#### Step 1: Configure Shell
Go to Dashboard / Manage Jenkins / Configure System / Shell / Shell Executable and type '/bin/bash'

<a name="webhooks"></a>
#### Step 2: Add webhooks to system repository
[Dublicate](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-on-github/duplicating-a-repository) repositories for easier configuration.

* [Add Webhooks - see until Step 4](https://www.blazemeter.com/blog/how-to-integrate-your-github-repository-to-your-jenkins-project)

<a name="credentials"></a>
#### Step 3: Add the credentials needed

* [Add SSH keys & SSH Agent plugin](https://plugins.jenkins.io/ssh-agent/) with id 'ssh-docker-vm' to access docker-vm
* [Add Secret Texts](https://www.jenkins.io/doc/book/using/using-credentials/) for every environmental variable we
need to define in our projects during deployment, like below

```nano
# ID                            What is the value?
app-db-user                     The backend database user
app-db-pass                     The password for the above user
app-db-name                     The database we have for the backend functionality
auth-secret                     The authentication secret that backend is using
mail-username                   Mail account's username
mail-password                   Mail account's app password
mail-from                       Mail account address
mail-port                       Mail account's server port (e.g. 587 for gmail)
mail-server                     Mail account's provider (e.g. smtp.gmail.com for gmail-google)
mail-from-name                  Mail account's name
base-endpoint-prefix            REST API's base prefix
rl-letters-endpoint             REST API's base endpoint for reference letters requests
auth-endpoint-prefix            REST API's prefix for authentication routes
auth-login-endpoint             REST API's signin endpoint
docker-db-url                   The database url where our postgres db is running using docker
docker-backend-url              The url where backend application is running in docker
docker-username                 The username we have in the container registry we use to push images
docker-push-secret              The secret we have in the container registry we use to push images
docker-container-registry       The container registry you use (e.g. ghcr.io for Github Container Registry). If you use DockerHub, create it with value 'https://index.docker.io/v1/'
docker-backend-prefix-image     The docker image name for the backend application
docker-frontend-prefix-image    The docker image name for the frontend application
k8s-db-url                      The database url where our postgres db is running using kubernetes
k8s-backend-url                 The url where backend application is running in kubernetes
```

<a name="job"></a>
#### Create Job
* [More for Ansible](https://github.com/panagiotis-bellias-it21871/ansible-reference-letter-code)
* [Create Pipeline project](https://www.jenkins.io/doc/pipeline/tour/hello-world/)
* [Add Webhooks to job - see until Step 9](https://www.blazemeter.com/blog/how-to-integrate-your-github-repository-to-your-jenkins-project)

In the job the pipeline will be the [fastapi.vue.Jenkinsfile](fastapi.vue.Jenkinsfile)

<a name="build"></a>
##### Build stage
Takes the code from the git repository and its submodules

## MANUALLY
<a name="ansible-prerequisites"></a>
##### Ansible Prerequisites stage
```bash
sudo su
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
ansible-galaxy collection install community.docker
```

<a name="j-docker"></a>
##### Docker Deployment
Ansible connects to the docker-vm through ssh and runs a playbook that it will define the sensitive parameters and 
will use docker-compose module to do docker-compose up the containers according to [docker-compose.yml](docker-compose.yml)

So, to deploy our app we need a docker image updated. So we build the images according to [nonroot.Dockerfile](https://github.com/panagiotis-bellias-it21871/reference-letters-fastapi-server/blob/main/nonroot.Dockerfile) and [Dockerfile](https://github.com/panagiotis-bellias-it21871/reference-letters-vuejs-client/blob/master/Dockerfile), we are logging in Github Container Registry (we will talk about it later) and push the image there to be public available.

<a name="j-k8s"></a>
##### Kubernetes Deployment
After we have [configure connection](https://github.com/panagiotis-bellias-it21871/reference-letters-system#connect-kubernetes-cluster-with-local-pc-orand-jenkins-server)
between jenkins user and our k8s cluster, we update secrets and configmaps using also some Ansible to populate ~/.env values and create all the needed entities such as persistent volume claims, deployments, cluster IPs, ingress,
services.

Secrets and ConfigMaps could be just prepared from earlier. This is applied to the https ingress, we will see
later in [SSL configuration](https://github.com/panagiotis-bellias-it21871/reference-letters-system#in-kubernetes-environment)

<a name="docker"></a>
### Deployment with Docker and docker-compose using Ansible
In order to be able to use Ansible for automation, there is the [ansible-reference-letter-project](https://github.com/panagiotis-bellias-it21871/ansible-reference-letter-code). There is installation and usage guide.

Now, In order to deploy our project in Docker environment, we use a playbook that uses an Ansible role to run the application
with docker-compose according to the [docker-compose.yml](docker-compose.yml). In that file, we have defined three
services, the postgres container with its volume in order to be able to store data, the fastapi container and the vuejs container for our
system taking environmental variables from local .env files (it's ready when we run the playbook from jenkins-server
where the sensitive values from environmental variables are parametric). The fastapi container is built according
to the [nonroot.Dockerfile](https://github.com/panagiotis-bellias-it21871/reference-letters-fastapi-server/blob/main/nonroot.Dockerfile) as a nonroot process for safety reasons.
The vuejs container is built according
to the [Dockerfile](https://github.com/panagiotis-bellias-it21871/reference-letters-vuejs-client/blob/master/Dockerfile).

For the HTTPS part we will talk about [later](https://github.com/panagiotis-bellias-it21871/reference-letters-system#in-docker-environment).

* [More Details](https://github.com/panagiotis-bellias-it21871/ansible-reference-letter-code#docker)

<a name="k8s"></a>
### Deployment with Kubernetes using a piece of Ansible

In order to deploy our project in Kubernetes cluster, we first need to connect to that VM so as to configure a better connection between local PC or jenkins server and deployment vm's:

* [Installing microk8s](https://ubuntu.com/tutorials/install-a-local-kubernetes-with-microk8s#2-deploying-microk8s)
* Do this trick to write less in terminal
```bash
echo "alias k='microk8s.kubectl' " >> ~/.profile
```
The permanent alias will be applied only if you reconnect to your VM.

#### Cluster Configuration & Enable Addons
```bash
sudo usermod -a -G microk8s <your-username>
sudo chown -f -R <your-username> ~/.kube
microk8s enable dns dashboard storage ingress
microk8s status
```

#### Connect Kubernetes Cluster with Local PC or/and Jenkins server
```bash
# VM's terminal
k config view --raw > kube-config
cat kube-config

# Local terminal
mkdir ~/.kube
scp <vm-name>:/home/<vm-username>/kube-config ~/.kube/config
```
Edit ~/.kube/config to replace the 127.0.0.1 with the VM's public ip and the certificate line in clusters section 
with the below line (not used this way in a real production environment)
```bash
insecure-skip-tls-verify: true
```

* Don't forget to add a firewall rule for the port specified in the ~/.kube/config file
With
```bash
kubectl get pods
```
you can ensure that the connection is established.

If you use CI/CD tool and mostly Jenkins do the following (for better deployment fork the repository to be able to 
change code where needed):
```bash
# Jenkins terminal
sudo su
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
su jenkins
cd

# Local terminal
scp ~/.kube/config <jenkins-vm-name>:/tmp/config

# Jenkins terminal
mkdir -p .kube
cp /tmp/config ~/.kube/
```
With
```bash
kubectl get pods
```
you can ensure that the connection is established.

### Kubernetes Entities

Either manually or via jenkins server using Jenkinsfile and secret texts the following will do the trick! The code is located in the k8s folder of each project, so every time we must change directory to be located in the correct application folder. The code is in the `.yaml` format.

* Don't forget to have the docker images in Github Container Registry because the deployment entities use them. You can follow the logic located in [fastapi.vue.Jenkinsfile](fastapi.vue.Jenkinsfile) in the 'Docker Deployment' stage. You must have docker installed in your local machine (or jenkins server)
* In projects' README.md files you will find information about the docker image each application is dockerized in.

```bash
# Secret (for the postgresql database)
kubectl create secret generic pg-users \
--from-literal=PGUSER=<put user name here> \
--from-literal=PGPASSWORD=<put password here> \
--from-literal=FAUSER=<put backend username here> \
--from-literal=FAPASSWORD=<put backend password here> \
--from-literal=FADBNAME=<put backend database name here>

# Config Map (for database initialization)
kubectl create configmap pg-init-script \
--from-literal=fastapi.sh=assets/init_db/fastapi.sh

## If you want keycloak service (for now it isn't integrated) run this instead
kubectl create configmap pg-init-script \
--from-literal=fastapi.sh=assets/init_db/fastapi.sh \
--from-literal=keycloak.sh=assets/init_db/keycloak.sh

!# ISSUE with database initialization for now

# Continue from here
cd reference-letters-fastapi-server

# Config Map (for .env variables)
cp ref_letters/.env.k8s.example ref_letters/.env
nano ref_letters/.env # change to the correct values
kubectl create configmap fastapi-config --from-env-file=ref_letters/.env

cd k8s
# Persistent Volume Claim
kubectl apply -f db/postgres-pvc.yaml
# Deployments
kubectl apply -f db/postgres-deployment.yaml
kubectl apply -f fastapi/fastapi-deployment.yaml
# Services (Cluster IPs)
kubectl apply -f db/postgres-clip.yaml
kubectl apply -f fastapi/fastapi-clip.yaml

cd ../..
cd reference-letters-vuejs-client

# Config Map (for .env variables)
cp .env.k8s.example .env
nano .env # change to the correct values
kubectl create configmap vuejs-config --from-env-file=.env

cd k8s
# Deployments
kubectl apply -f vuejs/vuejs-deployment.yaml
# Services (Cluster IPs)
kubectl apply -f vuejs/vuejs-clip.yaml
# Ingress (For just HTTP - Edit file changing host to your own dns name)
kubectl apply -f vuejs/vuejs-ingress.yaml
```

To change to the correct values the .env file we use some Ansible running [this playbook](https://github.com/panagiotis-bellias-it21871/ansible-reference-letter-code/blob/main/playbooks/populate-k8s-dotenv.yml). This is also used by Jenkins server and Jenkinsfile. See more [here](https://github.com/panagiotis-bellias-it21871/ansible-reference-letter-code#k8s).
*