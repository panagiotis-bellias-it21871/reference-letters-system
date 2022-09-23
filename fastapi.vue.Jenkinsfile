pipeline {

    agent any

    environment {
        APP_DB_USER=credentials('app-db-user')
        APP_DB_PASS=credentials('app-db-pass')
        APP_DB_NAME=credentials('app-db-name')
        BACKEND_AUTH_SECRET=credentials('auth-secret')
        MAIL_USERNAME=credentials('mail-username')
        MAIL_PASSWORD=credentials('mail-password')
        MAIL_FROM=credentials('mail-from')
        MAIL_PORT=credentials('mail-port')
        MAIL_SERVER=credentials('mail-server')
        MAIL_FROM_NAME=credentials('mail-from-name')
        BASE_ENDPOINT_PREFIX=credentials('base-endpoint-prefix')
        RL_LETTERS_ENDPOINT=credentials('rl-letters-endpoint')
        AUTH_ENDPOINT_PREFIX=credentials('auth-endpoint-prefix')
        AUTH_LOGIN_ENDPOINT=credentials('auth-login-endpoint')
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

        stage('Docker Deployment') {

            environment {
                DB_URL=credentials('docker-db-url') 
                VUE_APP_BACKEND_URL=credentials('docker-backend-url')

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
                    echo $DOCKER_PASSWORD | docker login $DOCKER_SERVER -u $DOCKER_USER --password-stdin
                    docker push $DOCKER_BACKEND_PREFIX --all-tags
                    cd ~/workspace/reference-letters-system/reference-letters-vuejs-client
                    docker build --rm -t $DOCKER_FRONTEND_PREFIX:latest -t $DOCKER_FRONTEND_PREFIX:$TAG .
                    docker push $DOCKER_FRONTEND_PREFIX --all-tags

                    echo 'Installing grype...'
                    cd && mkdir .grype || true
                    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b ~/.grype
                    echo 'export PATH="$HOME/.grype:$PATH"' >> ~/.bashrc
                    source ~/.bashrc

                    echo 'Security scanning...'

                    grype $DOCKER_BACKEND_PREFIX > backend_image_grype_logs.txt
                    grype $DOCKER_FRONTEND_PREFIX > frontend_image_grype_logs.txt
                    cat backend_image_grype_logs.txt | grep 'Critical' | true
                    cat frontend_image_grype_logs.txt | grep 'Critical' | true
                '''

                sshagent (credentials: ['ssh-docker-vm']) {
                    sh '''
                        cd ~/workspace/reference-letters-system/ansible-reference-letter-code
                        ansible-playbook -l docker_group playbooks/reference-letters-system-docker-install.yml \
                        -e BACKEND_DIR='reference-letters-fastapi-server' \
                        -e FRONTEND_DIR='reference-letters-vuejs-client' \
                        -e DATABASE_URL=$DB_URL \
                        -e VUE_APP_BACKEND_URL=$VUE_APP_BACKEND_URL \
                        -e SECRET=$BACKEND_AUTH_SECRET \
                        -e MAIL_USERNAME=$MAIL_USERNAME \
                        -e MAIL_PASSWORD=$MAIL_PASSWORD \
                        -e MAIL_FROM=$MAIL_FROM \
                        -e MAIL_PORT=$MAIL_PORT \
                        -e MAIL_SERVER=$MAIL_SERVER \
                        -e MAIL_FROM_NAME=$MAIL_FROM_NAME \
                        -e BASE_ENDPOINT_PREFIX=$BASE_ENDPOINT_PREFIX \
                        -e RL_LETTERS_ENDPOINT=$RL_LETTERS_ENDPOINT \
                        -e AUTH_ENDPOINT_PREFIX=$AUTH_ENDPOINT_PREFIX \
                        -e AUTH_LOGIN_ENDPOINT=$AUTH_LOGIN_ENDPOINT
                    ''' 
                }
            }
        }

        stage('Kubernetes Deployment') {

            environment {
                DB_URL=credentials('k8s-db-url') 
                VUE_APP_BACKEND_URL=credentials('k8s-backend-url')
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

                    cd ~/workspace/reference-letters-system/ansible-reference-letter-code
                    ansible-playbook playbooks/populate-k8s-dotenv.yml \
                    -e BACKEND_DIR='reference-letters-fastapi-server' \
                    -e FRONTEND_DIR='reference-letters-vuejs-client' \
                    -e DATABASE_URL=$DB_URL \
                    -e VUE_APP_BACKEND_URL=$VUE_APP_BACKEND_URL \
                    -e SECRET=$BACKEND_AUTH_SECRET \
                    -e MAIL_USERNAME=$MAIL_USERNAME \
                    -e MAIL_PASSWORD=$MAIL_PASSWORD \
                    -e MAIL_FROM=$MAIL_FROM \
                    -e MAIL_PORT=$MAIL_PORT \
                    -e MAIL_SERVER=$MAIL_SERVER \
                    -e MAIL_FROM_NAME=$MAIL_FROM_NAME \
                    -e BASE_ENDPOINT_PREFIX=$BASE_ENDPOINT_PREFIX \
                    -e RL_LETTERS_ENDPOINT=$RL_LETTERS_ENDPOINT \
                    -e AUTH_ENDPOINT_PREFIX=$AUTH_ENDPOINT_PREFIX \
                    -e AUTH_LOGIN_ENDPOINT=$AUTH_LOGIN_ENDPOINT

                    cd ~/workspace/reference-letters-system/reference-letters-fastapi-server
                    kubectl create configmap fastapi-config \
                    --from-env-file=ref_letters/.env \
                    --dry-run -o yaml | kubectl apply -f -

                    kubectl create secret docker-registry regcred --docker-server=$DOCKER_SERVER --docker-username=$DOCKER_USER --docker-password=$DOCKER_PASSWORD

                    cd k8s
                    kubectl apply -f db/postgres-pvc.yaml
                    kubectl apply -f db/postgres-deployment.yaml
                    kubectl apply -f db/postgres-clip.yaml
                    
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
    }
}