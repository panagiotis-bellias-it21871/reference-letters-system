pipeline {

    agent any

    environment {
        APP_DB_USER=credentials('app-psql-user')
        APP_DB_PASS=credentials('app-psql-pass')
        APP_DB_NAME=credentials('app-psql-db')
        AUTH_DB_USER=credentials('auth-psql-user')
        AUTH_DB_PASS=credentials('auth-psql-pass')
        AUTH_DB_NAME=credentials('auth-psql-db')
    }

    stages {

        stage('Build'){
            steps {
                // Get the code from the github repository and its submodules
                git branch: 'main', url: 'https://github.com/panagiotis-bellias-it21871/reference-letters-system.git'
                sh 'cd ~/workspace/reference-letters-system'
                sh 'git submodule update --init --recursive'
            }
        }

        stage('Unit Testing') {
            steps {
                sh '''
                    echo "BACK END"
                    cd ~/workspace/reference-letters-system/reference-letters-fastapi-server
                    virtualenv fvenv -p python3
                    source fvenv/bin/activate
                    pip install -r requirements.txt

                    cp ref_letters/.env.example ref_letters/.env
                    rm test.db || true
                    
                   '''
                    // pytest
                sh '''
                    echo 'FRONT END'
                    cd ~/workspace/reference-letters-system/reference-letters-vuejs-client
                    npm install --force

                    cp .env.example .env
                    echo $PWD
                    echo "Here we have to run unit tests about frontend"
                   '''
            }
        }

        stage('Integration Testing') {
            steps {
                sh '''
                    echo "Here we have to run integration tests"
                   '''
            }
        }

        stage('Docker Deployment') {

            environment {
                DB_URL=credentials('docker-db-url')
                KC_SERVER_URL=credentials('docker-keycloak-server-url')
                KC_CLIENT_ID=credentials('docker-keycloak-client-id')
                KC_REALM=credentials('docker-keycloak-realm')
                KC_CLIENT_SECRET=credentials('docker-keycloak-client-secret')
                VUE_APP_BACKEND_URL=credentials('docker-vue-backend-url')
                VUE_APP_KEYCLOAK_URL=credentials('docker-keycloak-server-url')

                DOCKER_USER=credentials('docker-username')
                DOCKER_PASSWORD=credentials('docker-push-secret')
                DOCKER_SERVER=credentials('docker-container-registry')
                DOCKER_BACKEND_PREFIX=credentials('docker-backend-prefix-image')
                DOCKER_FRONTEND_PREFIX=credentials('docker-frontend-prefix-image')
            }

            steps {
                sh '''
                    HEAD_COMMIT=$(git rev-parse --short HEAD)
                    TAG=$HEAD_COMMIT-$BUILD_ID
                    echo 'Building the images...'
                    cd ~/workspace/reference-letters-system/reference-letters-fastapi-server
                    docker build --rm -t $DOCKER_BACKEND_PREFIX -t $DOCKER_BACKEND_PREFIX:$TAG -f nonroot.Dockerfile .
                    cd ~/workspace/reference-letters-system/reference-letters-vuejs-client
                    docker build --rm -t $DOCKER_FRONTEND_PREFIX:latest -t $DOCKER_FRONTEND_PREFIX:$TAG .
                    
                    echo 'Add also push commands to help grype do its work!'

                    echo 'Installing grype...'
                    cd && mkdir .grype || true
                    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b ~/.grype
                    echo 'export PATH="$HOME/.grype:$PATH"' >> ~/.bashrc
                    source ~/.bashrc

                    echo 'Security scanning...'
                    grype $DOCKER_BACKEND_PREFIX > backend_image_grype_logs.txt
                    grype $DOCKER_FRONTEND_PREFIX > frontend_image_grype_logs.txt
                    cat grype backend_image_grype_logs.txt | grep 'Critical'
                    cat grype frontend_image_grype_logs.txt | grep 'Critical'
                '''
                sshagent (credentials: ['ssh-docker-vm']) {
                    sh '''
                        cd ~/workspace/reference-letters-system/ansible-reference-letter-code
                        ansible-playbook playbooks/reference-letters-system-install.yml \
                        -e BACKEND_DIR='reference-letters-fastapi-server' \
                        -e FRONTEND_DIR='reference-letters-vuejs-client' \
                        -e DATABASE_URL=$DB_URL \
                        -e KC_SERVER_URL=$KC_SERVER_URL \
                        -e KC_CLIENT_ID=$KC_CLIENT_ID \
                        -e KC_REALM=$KC_REALM \
                        -e KC_CLIENT_SECRET=$KC_CLIENT_SECRET \
                        -e VUE_APP_BACKEND_URL=$VUE_APP_BACKEND_URL \
                        -e VUE_APP_KEYCLOAK_URL=$VUE_APP_KEYCLOAK_URL
                    '''
                }
                sh '''
                    echo $DOCKER_PASSWORD | docker login $DOCKER_SERVER -u $DOCKER_USER --password-stdin

                    cd ~/workspace/reference-letters-system/reference-letters-fastapi-server
                    docker push $DOCKER_BACKEND_PREFIX --all-tags

                    cd ~/workspace/reference-letters-system/reference-letters-vuejs-client
                    docker push $DOCKER_FRONTEND_PREFIX --all-tags
                   '''
            }
        }

        /*
        stage('Kubernetes Deployment') {

            environment {
                DB_URL=credentials('k8s-db-url')
                KC_SERVER_URL=credentials('k8s-keycloak-server-url')
                KC_CLIENT_ID=credentials('k8s-keycloak-client-id')
                KC_REALM=credentials('k8s-keycloak-realm')
                KC_CLIENT_SECRET=credentials('k8s-keycloak-client-secret')
                VUE_APP_BACKEND_URL=credentials('k8s-vue-backend-url')
                VUE_APP_KEYCLOAK_URL=credentials('k8s-keycloak-server-url')
            }

            steps {
                sh '''
                    echo "Here we have to deploy the system using Kubernetes"
                    
                    kubectl config use-context microk8s

                    kubectl create secret generic app-pg-user \
                    --from-literal=PGUSER=$APP_DB_USER \
                    --from-literal=PGPASSWORD=$APP_DB_PASS \
                    --from-literal=PGDATABASE=$APP_DB_NAME --dry-run -o yaml \
                    | kubectl apply -f -

                    kubectl create secret generic auth-pg-user \
                    --from-literal=PGUSER=$AUTH_DB_USER \
                    --from-literal=PGPASSWORD=$AUTH_DB_PASS \
                    --from-literal=PGDATABASE=$AUTH_DB_NAME --dry-run -o yaml \
                    | kubectl apply -f -

                    cd ~/workspace/reference-letters-system/ansible-reference-letter-code
                    ansible-playbook playbooks/populate-k8s-dotenv.yml \
                    -e BACKEND_DIR='reference-letters-fastapi-server' \
                    -e FRONTEND_DIR='reference-letters-vuejs-client' \
                    -e DATABASE_URL=$DB_URL \
                    -e KC_SERVER_URL=$KC_SERVER_URL \
                    -e KC_CLIENT_ID=$KC_CLIENT_ID \
                    -e KC_REALM=$KC_REALM \
                    -e KC_CLIENT_SECRET=$KC_CLIENT_SECRET \
                    -e VUE_APP_BACKEND_URL=$VUE_APP_BACKEND_URL \
                    -e VUE_APP_KEYCLOAK_URL=$VUE_APP_KEYCLOAK_URL

                    cd ~/workspace/reference-letters-system/reference-letters-fastapi-server
                    kubectl create configmap fastapi-config \
                    --from-env-file=ref_letters/.env \
                    --dry-run -o yaml | kubectl apply -f -

                    cd k8s
                    kubectl apply -f db/postgres-pvc.yaml
                    kubectl apply -f db/postgres-deployment.yaml
                    kubectl apply -f db/postgres-clip.yaml
                    kubectl apply -f auth/keycloak-pvc.yaml
                    kubectl apply -f auth/keycloak-deployment.yaml
                    kubectl apply -f auth/keycloak-clip.yaml
                    kubectl apply -f fastapi/fastapi-deployment.yaml
                    kubectl apply -f fastapi/fastapi-clip.yaml

                    cd ~/workspace/reference-letters-system/reference-letters-vuejs-client
                    kubectl create configmap vuejs-config \
                    --from-env-file=.env \
                    --dry-run -o yaml | kubectl apply -f -

                    cd k8s
                    kubectl apply -f vuejs/vuejs-deployment.yaml
                    kubectl apply -f vuejs/vuejs-clip.yaml
                    kubectl apply -f vuejs/vuejs-ingress.yaml

                    kubectl apply -f vuejs/vuejs-https-ingress.yaml

                   '''
            }
        }

        stage('Helm Deployment') {
            steps {
                sh '''
                    echo "Here we have to deploy the system using Helm Charts"
                   '''
            }
        }*/
    }
}