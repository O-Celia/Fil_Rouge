pipeline {
    agent any
    
    stages {

        stage('Clean Workspace') {
            steps {
                // This step deletes the entire workspace
                deleteDir()
            }
        }

        stage('Cloning the git') {
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
            steps {
                script {
                    withCredentials([azureServicePrincipal(credentialsId: 'ServicePrincipal')]) {
                        sh "az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID"

                        // Initialize Terraform
                        dir('terraform') {
                            sh 'terraform init'
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }

        stage('Set up Traefik ingress') {
            steps {
                script {
                    dir('terraform/helm') {
                        sh "az aks get-credentials -g project_celia -n cluster-project --overwrite-existing"
                        // Check if the Traefik release is already deployed
                        def isTraefikDeployed = sh(script: "helm list --namespace default -q | grep -w traefik", returnStatus: true) == 0

                        if (!isTraefikDeployed) {
                            // If the release is not deployed, install it
                            echo "Traefik is not installed. Installing Traefik."
                            sh('''
                                helm repo add traefik https://traefik.github.io/charts
                                helm repo update
                                helm install traefik traefik/traefik --version 25.0.0
                            ''')
                        } else {
                            // If Traefik is already installed, upgrade it with the new configuration
                            echo "Traefik is already installed. Upgrading Traefik."
                            sh('''
                                helm repo add traefik https://traefik.github.io/charts
                                helm repo update
                                helm upgrade traefik traefik/traefik --version 25.0.0
                            ''')
                        }
                    }
                }
            }
        }

        stage('Set up Wordpress with kubernetes/helm') {
            steps {
                script {
                    dir('terraform/helm') {
                        sh "az aks get-credentials -g project_celia -n cluster-project"
                        // Check if the Helm release is already deployed
                        def isDeployed = sh(script: "helm list --namespace default -q | grep -w myblog", returnStatus: true) == 0

                        if (isDeployed) {
                            // If the release is deployed, upgrade it
                            echo "Release 'myblog' exists. Upgrading chart."
                            sh 'helm upgrade myblog -f values.yaml oci://registry-1.docker.io/bitnamicharts/wordpress'
                        } else {
                            // If the release is not deployed, install it
                            echo "Release 'myblog' does not exist. Installing chart."
                            sh 'helm install myblog -f values.yaml oci://registry-1.docker.io/bitnamicharts/wordpress'
                        }

                        // Apply autoscaler, redirection of https and certmanager

                        sh "kubectl apply -f autoscaler.yaml"
                        sh "kubectl apply -f redirect.yaml"
                        sh "kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml"
                    }
                }
            }
        }

        stage('Update DNS Record') {
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
            steps {
                script {
                    withCredentials([string(credentialsId: 'mail', variable: 'CERTBOT_EMAIL')]) {
                        dir('terraform/helm') {
                            sh "az aks get-credentials -g project_celia -n cluster-project"
                            echo "Traefik is already installed. Upgrading Traefik."
                            // Update certmanager.yaml with the actual email
                            sh "sed -i 's/email: mymail/email: ${CERTBOT_EMAIL}/' certmanager.yaml"
                            // Update traefik with values.yaml
                            sh('''
                                helm repo add traefik https://traefik.github.io/charts
                                helm repo update
                                helm upgrade traefik traefik/traefik -f traefik-values.yaml --version 25.0.0
                            ''')
                        }
                    }
                }
            }
        }
    }
}
