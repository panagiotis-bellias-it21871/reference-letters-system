pipeline {
    agent any

    stages {

        stage('Build-Checkout'){
            steps {
                // Get the code from the github repository
                git branch: 'main', url: 'https://github.com/panagiotis-bellias-it21871/reference-letters-system.git'
                sh 'cd ~/workspace/reference-letters-system'
                sh 'git submodule update --init --recursive'
            }
        }

        stage('Unit Testing') {
            steps {
                sh '''
                    cd ~/workspace/reference-letters-system/reference-letters-fastapi-server
                    python3 -m venv fvenv
                    source fvenv/bin/activate
                    pip install -r requirements.txt

                    cp ref_letters/.env.example ref_letters/.env
                    rm test.db || true
                    pytest
                   '''
            }
        }

        stage('Integration Testing') {
            steps {
                sh '''
                    echo "Integration testing awaits"
                   '''
            }
        }

        stage('Docker Deployment') {
            //environment {
                // DB_URL=credentials('docker-db-url')
                // DOCKER_PASSWORD=credentials('docker-push-secret')
                // DOCKER_USER=credentials('docker-user')
                // DOCKER_PREFIX=credentials('docker-prefix-image-fastapi')
            //}
            steps {
                sh '''
                    cd ~/workspace/reference-letters-system/ansible-reference-letter-code
                    ansible-playbook -l docker_group playbooks/install-docker.yml
                    ansible-playbook -l docker_group playbooks/fastapi-install.yml \
                    -e DATABASE_URL=$DB_URL
                   '''
                sh '''
                    cd ~/workspace/reference-letters-system/reference-letters-fastapi-server
                    HEAD_COMMIT=$(git rev-parse --short HEAD)
                    TAG=$HEAD_COMMIT-$BUILD_ID
                    docker build --rm -t $DOCKER_PREFIX:$TAG -t $DOCKER_PREFIX:latest -f nonroot.Dockerfile . 
                   '''
                sh '''
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USER --password-stdin
                    docker push $DOCKER_PREFIX --all-tags
                   '''
                   
            }
        }

        stage('Helm Deployment') {
            steps {
                sh '''
                    echo "Deployment with helm chart awaits"
                   '''
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                sh '''
                    echo "Deployment with kubernetes awaits"
                   '''
            }
        }
    }
}