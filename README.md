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
3.1.4.2. [Unit Testing stage](#unit-test)  
3.1.4.3. [Integration Testing stage](#integration-test)  
3.1.4.4. [Ansible Prerequisites stage](#ansible-prerequisites-stage)
3.1.4.4. [Docker Deployment](#j-docker)  
3.1.4.5. [Kubernetes Deployment](#j-k8s)  
3.2. [Deployment with Docker and docker-compose using Ansible](#docker)

...

<a name="locally"></a>
## Setup & Run Projects Locally (Installation)

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
app-psql-user                   The backend database user
app-psql-pass                   The password for the above user
app-psql-db                     The database we have for the backend functionality
auth-psql-user                  The keycloak database user
auth-psql-pass                  The password for the above user
auth-psql-db                    The database we have users' credentials for the system
docker-db-url                   The database url where our postgres db is running using docker
docker-keycloak-server-url      The url where keycloak is running using docker
docker-keycloak-client-id       The client id we need to connect with keycloak in docker
docker-keycloak-realm           The realm we connect with keycloak in docker  
docker-keycloak-client-secret   The client secret we use for authentication with keycloak in docker
docker-vue-backend-url          The url where backend application is running in docker
docker-username                 The username we have in the container registry we use to push images
docker-push-secret              The secret we have in the container registry we use to push images
docker-backend-prefix-image     The docker image name for the backend application
docker-frontend-prefix-image    The docker image name for the frontend application
k8s-db-url                      The database url where our postgres db is running using kubernetes
k8s-keycloak-server-url         The url where keycloak is running using kubernetes
k8s-keycloak-client-id          The client id we need to connect with keycloak in kubernetes  
k8s-keycloak-realm              The realm we connect with keycloak in kubernetes  
k8s-keycloak-client-secret      The client secret we use for authentication with keycloak in kubernetes 
k8s-vue-backend-url             The url where backend application is running in kubernetes
```

<a name="jobs"></a>
#### Create Jobs
* [Create Freestyle project for Ansible code](https://www.guru99.com/create-builds-jenkins-freestyle-project.html)
* [More for Ansible](https://github.com/panagiotis-bellias-it21871/ansible-reference-letter-code)
* [Create Pipeline project](https://www.jenkins.io/doc/pipeline/tour/hello-world/)
* [Add Webhooks to job - see until Step 9](https://www.blazemeter.com/blog/how-to-integrate-your-github-repository-to-your-jenkins-project)

In the job the pipeline will be the [fastapi.vue.Jenkinsfile](fastapi.vue.Jenkinsfile)

<a name="build"></a>
##### Build stage
Takes the code from the git repository and its submodules

<a name="unit-test"></a>
##### Unit Testing stage
For the backend application activates a virtual environment, installs the requirements, copies the .env.example to use it as .env with some
demo values for testing and uses pytest so the application can be tested before goes on production.
For the frontend application installs the requirements, executes the tests so the application can be tested before goes on production.

NOTE: connect to your jenkins vm and do the below line so the test stage can run
```bash
<username>@<vm-name>:~$ sudo apt-get install libpcap-dev libpq-dev
```

<a name="integration-test"></a>
##### Integration Testing stage
...

<a name="ansible-prerequisites"></a>
##### Ansible Prerequisites stage
...

<a name="j-docker"></a>
##### Docker Deployment
Ansible connects to the docker-vm through ssh and runs a playbook that it will define the sensitive parameters and 
will use docker-compose module to do docker-compose up the containers according to [docker-compose.yml](docker-compose.yml)

So, to deploy our app we need a docker image updated. So we build the images according to [nonroot.Dockerfile](https://github.com/panagiotis-bellias-it21871/reference-letters-fastapi-server/blob/main/nonroot.Dockerfile) and [Dockerfile](https://github.com/panagiotis-bellias-it21871/reference-letters-vuejs-client/blob/master/Dockerfile), we are logging in Github Container Registry* and push the image there to be public available.

