pipeline {
    agent any

    triggers {
        cron('0 8 * * *') // Déclenche à 8h00 chaque jour
    }

    stages {

        // stage('Clean Workspace') {
        //     when {
        //         not {
        //             triggeredBy 'TimerTrigger'
        //         }
        //     }
        //     steps {
        //         // This step deletes the entire workspace
        //         deleteDir()
        //     }
        // }

        stage('Cloning the git') {
            when {
                not {
                    triggeredBy 'TimerTrigger'
                }
            }
            steps {
                script {
                    // Define the repository URL and the target directory
                    def repoUrl = 'https://github.com/Simplon-CeliaOuedraogo/Fil_Rouge.git'
                    // Check if the current directory is a Git repository
                    if (!fileExists('.git')) {
                        // Not a Git repository, so clone the repo
                        sh "git clone ${repoUrl} ."
                    } else {
                        // Current directory is a Git repository, so pull the latest changes
                        sh('''
                            git checkout main
                            git pull
                        ''')
                    }
                }
            }
        }
        
        stage('Set up infrastructure with terraform') {
            when {
                not {
                    triggeredBy 'TimerTrigger'
                }
            }
            steps {
                script {
                    withCredentials([azureServicePrincipal(credentialsId: 'ServicePrincipal')]) {
                        sh "az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID"

                        // Initialize Terraform
                        dir('terraform') {
                            sh 'terraform init'
                            sh 'terraform apply -auto-approve'
                            // Retrieve Terraform outputs
                            env.STORAGE_ACCOUNT = sh(script: "terraform output -raw storage_account_name", returnStdout: true).trim()
                            env.STORAGE_KEY = sh(script: "terraform output -raw storage_account_key", returnStdout: true).trim()
                            env.CONTAINER_NAME = sh(script: "terraform output -raw container_name", returnStdout: true).trim()
                        }
                    }
                }
            }
        }

        stage('Set up Traefik ingress') {
            when {
                not {
                    triggeredBy 'TimerTrigger'
                }
            }
            steps {
                script {
                    dir('terraform/helm') {
                        sh "az aks get-credentials -g project_celia -n cluster-project --overwrite-existing"
                        sh('''
                             helm repo add traefik https://traefik.github.io/charts
                             helm repo update
                             helm upgrade --install traefik traefik/traefik --version 25.0.0
                        ''')
                    }
                }
            }
        }

        stage('Set up Wordpress with kubernetes/helm') {
            when {
                not {
                    triggeredBy 'TimerTrigger'
                }
            }
            steps {
                script {
                    withCredentials([string(credentialsId: 'passwordMariadb', variable: 'MARIADB_PWD'),
                                     string(credentialsId: 'mail', variable: 'CERTBOT_EMAIL'),
                                     string(credentialsId: 'usernameMariadb', variable: 'MARIADB_USR')]) {
                        dir('terraform/helm') {
                            sh "az aks get-credentials -g project_celia -n cluster-project"
                            // sh "helm repo add groundhog2k https://groundhog2k.github.io/helm-charts/"
                            sh ""
                            // Update values-wordpress.yaml with the actual email
                            // sh "sed -i 's/password: mypassword/password: ${MARIADB_PWD}/' values-wordpress.yaml"
                            // sh "sed -i 's/rootPassword: rootpassword/rootPassword: ${MARIADB_PWD}/' values-wordpress.yaml"
                            // sh "sed -i 's/user: myusername/user: ${MARIADB_USR}/' values-wordpress.yaml"
                            // sh 'helm upgrade --install myblog -f values-wordpress.yaml groundhog2k/wordpress'
                            sh "sed -i 's/wordpressPassword: mypassword/wordpressPassword: ${MARIADB_PWD}/' values.yaml"
                            sh "sed -i 's/wordpressUsername: username/wordpressUsername: ${MARIADB_USR}/' values.yaml"
                            sh "sed -i 's/wordpressEmail: email/wordpressEmail: ${CERTBOT_EMAIL}/' values.yaml"
                            sh "sed -i 's/auth.rootPassword: rootpassword/auth.rootPassword: ${MARIADB_PWD}/' values.yaml"
                            sh "sed -i 's/username: myusername/username: ${MARIADB_USR}/' values.yaml"
                            sh 'helm upgrade --install myblog -f values.yaml oci://registry-1.docker.io/bitnamicharts/wordpress'

                            // Apply autoscaler, redirection of https, password of grafana and certmanager
                            sh "kubectl apply -f autoscaler.yaml"
                            sh "kubectl apply -f redirect.yaml"
                            sh "kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml"
                            sh "kubectl apply -f configmapDashboardMine.yml"
                        }
                    }
                }
            }
        }

        stage('Update DNS Record') {
            when {
                not {
                    triggeredBy 'TimerTrigger'
                }
            }
            steps {
                script {
                    sh "az aks get-credentials -g project_celia -n cluster-project"
                    // Get the IP address of Traefik
                    def traefikIP = sh(script: "kubectl get svc traefik -n default --template=\"{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}\"", returnStdout: true).trim()

                    // Use Gandi API key from Jenkins credentials
                    withCredentials([string(credentialsId: 'APIkey', variable: 'GANDI_API_KEY')]) {
                        // Update the DNS record on Gandi
                        sh "curl -X PUT -H 'Content-Type: application/json' -H 'Authorization: Apikey ${GANDI_API_KEY}' -d '{\"rrset_values\": [\"${traefikIP}\"]}' 'https://api.gandi.net/v5/livedns/domains/cecicelia.site/records/myblog/A'"
                    }
                }
            }
        }

        stage('Add TLS to Traefik ingress') {
            when {
                not {
                    triggeredBy 'TimerTrigger'
                }
            }
            steps {
                script {
                    withCredentials([string(credentialsId: 'mail', variable: 'CERTBOT_EMAIL')]) {
                        dir('terraform/helm') {
                            sh "az aks get-credentials -g project_celia -n cluster-project"
                            echo "Traefik is already installed. Upgrading Traefik."

                            // Extended check for cert-manager-webhook readiness
                            echo "Checking cert-manager-webhook readiness..."
                            int attempts = 0
                            boolean webhookReady = false
                            while (!webhookReady && attempts < 10) {
                                // Check if the pod is ready
                                if (sh(script: "kubectl get pods -n cert-manager -l app=webhook -o jsonpath='{.items[*].status.conditions[?(@.type==\"Ready\")].status}'", returnStatus: true) == 0) {
                                    // Delay of 2min for the TLS certificates
                                    sleep(120)
                                    // Perform a test request or additional check to confirm the webhook is operational
                                    webhookReady = true
                                    echo "cert-manager-webhook is ready."
                                } else {
                                    attempts++
                                    echo "Waiting for cert-manager-webhook to be ready, attempt ${attempts}..."
                                    sleep(120)
                                }
                            }
                            if (!webhookReady) {
                                error("cert-manager-webhook is not ready, aborting deployment.")
                            }

                            // Update certmanager.yaml with the actual email
                            sh "sed -i 's/email: mymail/email: ${CERTBOT_EMAIL}/' certmanager.yaml"
                            sh "kubectl apply -f certmanager.yaml"

                            // // Update traefik with values.yaml
                            // sh('''
                            //     helm repo add traefik https://traefik.github.io/charts
                            //     helm repo update
                            //     helm upgrade traefik traefik/traefik -f traefik-values.yaml --version 25.0.0
                            // ''')
                        }
                    }
                }
            }
        }

        stage('Set up Prometheus, Grafana with Helm') {
            when {
                not {
                    triggeredBy 'TimerTrigger'
                }
            }
            steps {
                script {
                    withCredentials([string(credentialsId: 'passwordGrafana', variable: 'GRAFANA_PWD')]) {
                        dir('terraform/helm') {
                            sh "az aks get-credentials -g project_celia -n cluster-project"
                            sh"sed -i 's/adminPassword: mypassword/adminPassword: ${GRAFANA_PWD}/' prom-graf-values.yaml"
                            sh('''
                                helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                                helm repo update
                                helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -f prom-graf-values.yaml
                            ''')
                        }  
                    }
                }
            }
        }

        stage('SonarCloud analysis') {
            when {
                not {
                    triggeredBy 'TimerTrigger'
                }
            }
            steps {
                withCredentials([string(credentialsId: 'sonarcloud', variable: 'SONAR_TOKEN'),
                                 string(credentialsId: 'sonarGithub', variable: 'SONAR_ORGANIZATION_KEY'),
                                 string(credentialsId: 'projectKey', variable: 'SONAR_PROJECT')]) {
                    script {
                        withSonarQubeEnv('sonarcloud') {
                            sh '/usr/bin/sonar-scanner \
                                -Dsonar.projectKey=$SONAR_PROJECT \
                                -Dsonar.organization=$SONAR_ORGANIZATION_KEY \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=https://sonarcloud.io \
                                -Dsonar.login=$SONAR_TOKEN'
                        }
                    }
                }
            }
        }

stage('Run WPScan') {
            when {
                anyOf {
                    triggeredBy 'TimerTrigger'
                    // triggeredBy 'SCMTrigger'
                    triggeredBy 'UserIdCause'
                }
            }
            steps {
                script {
                    withCredentials([string(credentialsId: 'wordpressBlog', variable: 'WORDPRESS_DNS'),
                                     string(credentialsId: 'wpsScanToken', variable: 'WPS_TOKEN')]) {
                        // Set environment variables for the credentials
                        sh "az aks get-credentials -g project_celia -n cluster-project"
                        sh "wpscan --url $WORDPRESS_DNS --api-token $WPS_TOKEN --ignore-main-redirect --verbose > wpscan_results.txt"
                        // Upload the file to Azure Storage Container
                        sh "az storage blob upload --account-name ${env.STORAGE_ACCOUNT} --account-key ${env.STORAGE_KEY} --container-name ${env.CONTAINER_NAME} --name wpscan_results.txt --file wpscan_results.txt --auth-mode key --overwrite true"
                    }
                }
            }
        }

        stage('Test de charge') {
            when {
                not {
                    triggeredBy 'TimerTrigger'
                }
            }
            steps {
                script {
                    withCredentials([string(credentialsId: 'wordpressBlog', variable: 'WORDPRESS_DNS')]) {
                        sh('''seq 250 | parallel --max-args 0 "curl -k $WORDPRESS_DNS"
                        ''')
                    }
                }
            }
        }
    }
}
