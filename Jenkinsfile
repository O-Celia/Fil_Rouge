pipeline {
    agent any
    
    stages {

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

                            // Check if the AKS cluster exists in the Terraform state
                            def aksExists = sh(script: "terraform state list azurerm_kubernetes_cluster.aks", returnStatus: true) == 0

                            if (aksExists) {
                                // If AKS exists, apply changes only to the AKS cluster
                                echo "AKS cluster exists. Applying changes to AKS only."
                                sh 'terraform apply -auto-approve -target=azurerm_kubernetes_cluster.aks'
                            } else {
                                // If AKS does not exist, apply changes to the entire infrastructure
                                echo "AKS cluster does not exist. Applying changes to the entire infrastructure."
                                sh 'terraform apply -auto-approve'
                            }
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
                                helm install traefik traefik/traefik
                            ''')
                        } else {
                            // If Traefik is already installed, upgrade it with the new configuration
                            echo "Traefik is already installed. Upgrading Traefik."
                            sh('''
                                helm repo add traefik https://traefik.github.io/charts
                                helm repo update
                                helm upgrade traefik traefik/traefik
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

                        sh "kubectl apply -f autoscaler.yaml"
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

        // stage('Cert-manager') {
        //     steps {
        //         script {
        //             dir('terraform/helm') {
        //                 sh "az aks get-credentials -g project_celia -n cluster-project"
        //                 // Check if the Traefik release is already deployed
        //                 def isCertManagerDeployed = sh(script: "helm list --namespace default -q | grep -w certmanager", returnStatus: true) == 0

        //                 if (!isCertManagerDeployed) {
        //                     // If the release is not deployed, install it
        //                     echo "CertManager is not installed. Installing CertManager."
        //                     sh('''
        //                         helm repo add jetstack https://charts.jetstack.io
        //                         helm repo update
        //                         helm install certmanager -f certmanager-values.yaml --namespace default --version v1.13.2 jetstack/cert-manager
        //                     ''')
        //                 } else {
        //                     // If CertManager is already installed, upgrade it with the new configuration
        //                     echo "CertManager is already installed. Upgrading CertManager."
        //                     sh "sed -i 's/installCRDs: true/installCRDs: false/' certmanager-values.yaml"
        //                     sh('''
        //                         helm repo update
        //                         helm upgrade certmanager -f certmanager-values.yaml --namespace default --version v1.13.2 jetstack/cert-manager
        //                     ''')
        //                 }
        //             }
        //         }
        //     }
        // }

        // stage('Add TLS') {
        //     steps {
        //         script {
        //             withCredentials([string(credentialsId: 'APIkey', variable: 'GANDI_API_KEY'),
        //                              string(credentialsId: 'mail', variable: 'CERTBOT_EMAIL')]) {
        //                 // Create a temporary credentials file for Certbot
        //                 sh 'echo "dns_gandi_api_key = ${GANDI_API_KEY}" > gandi.ini'
        //                 sh 'chmod 600 gandi.ini'
        //                 // Run Certbot
        //                 sh '''
        //                 certbot certonly --authenticator dns-gandi --dns-gandi-credentials gandi.ini -d myblog.cecicelia.site --non-interactive --agree-tos --email ${CERTBOT_EMAIL}
        //                 cp /etc/letsencrypt/live/myblog.cecicelia.site/fullchain.pem ./fullchain.pem
        //                 cp /etc/letsencrypt/live/myblog.cecicelia.site/privkey.pem ./privkey.pem
        //                 cat fullchain.pem privkey.pem > certificat.pem
        //                 openssl pkcs12 -export -out certificat.pfx -in certificat.pem
        //                 '''
        //             }
        //         }
        //     }
        // }

        stage('Add TLS to Traefik ingress') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'mail', variable: 'CERTBOT_EMAIL')]) {
                        dir('terraform/helm') {
                            sh "az aks get-credentials -g project_celia -n cluster-project"
                            echo "Traefik is already installed. Upgrading Traefik."
                            // Update tls-values.yaml with the actual email
                            sh "sed -i 's/email: mail/email: ${CERTBOT_EMAIL}/' tls-values.yaml"
                            // Update values.yaml with new annotations
                            sh '''
                                sh 'sed -i \'/kubernetes.io\\/ingress.class: "traefik"/a \\  traefik.ingress.kubernetes.io\\/router.tls: "true"\' values.yaml'
                                sh 'sed -i \'/traefik.ingress.kubernetes.io\\/router.tls: "true"/a \\  traefik.ingress.kubernetes.io\\/router.tls.certresolver: "letsencrypt"\' values.yaml'
                            '''
                            sh('''
                                helm repo add traefik https://traefik.github.io/charts
                                helm repo update
                                helm upgrade traefik -f tls-values.yaml traefik/traefik
                            ''')
                        }
                    }
                }
            }
        }
    }
}
