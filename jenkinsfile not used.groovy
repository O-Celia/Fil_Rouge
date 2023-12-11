        // stage('Deploy Secret') {
        //     steps {
        //         script {
        //             dir('terraform/helm') {
        //                 // Retrieve the base64-encoded TLS certificate from Jenkins credentials
        //                 withCredentials([string(credentialsId: 'tls-ca-cert', variable: 'TLS_CERT')]) {
        //                     // Replace placeholder in the YAML file with the actual base64-encoded TLS certificate
        //                     sh "sed -i 's/tls-secret/${TLS_CERT}/' tls-ca-cert-secret.yml"

        //                     // Apply the YAML file using kubectl
        //                     sh 'kubectl apply -f tls-ca-cert-secret.yml'
        //                 }
        //             }
        //         }
        //     }
        // }
        
        // stage('Deploy Secret') {
        //     steps {
        //         script {
        //             dir('terraform/helm') {
        //                 // Retrieve the base64-encoded SSL certificate from Jenkins credentials
        //                 withCredentials([string(credentialsId: 'mysql-ssl', variable: 'SSL_CERT')]) {
        //                     // Replace placeholder in the YAML file with the actual base64-encoded SSL certificate
        //                     sh "sed -i 's/ssl-secret/${SSL_CERT}/' secret-cert-ssl.yml"

        //                     // Apply the YAML file using kubectl
        //                     sh 'kubectl apply -f secret-cert-ssl.yml'
        //                     sh 'cat secret-cert-ssl.yml'
        //                 }
        //             }
        //         }
        //     }
        // }

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

        // stage('Add TLS to Traefik ingress') {
        //     steps {
        //         script {
        //             withCredentials([string(credentialsId: 'mail', variable: 'CERTBOT_EMAIL')]) {
        //                 dir('terraform/helm') {
        //                     sh "az aks get-credentials -g project_celia -n cluster-project"
        //                     echo "Traefik is already installed. Upgrading Traefik."
        //                     // Update tls-values.yaml with the actual email
        //                     sh "sed -i 's/email: mail/email: ${CERTBOT_EMAIL}/' tls-values.yaml"
        //                     // Update values.yaml with new annotations
        //                     // Check if the TLS annotation exists and add it if it doesn't
        //                     sh '''
        //                         if ! grep -q "traefik.ingress.kubernetes.io/router.tls: \"true\"" values.yaml; then
        //                             sed -i '/kubernetes.io\\/ingress.class: "traefik"/a \\    traefik.ingress.kubernetes.io/router.tls: "true"' values.yaml
        //                         fi
        //                     '''
        //                     sh '''
        //                         if ! grep -q "traefik.ingress.kubernetes.io/router.tls.certresolver: \"letsencrypt\"" values.yaml; then
        //                             sed -i '/traefik.ingress.kubernetes.io\\/router.tls: "true"/a \\    traefik.ingress.kubernetes.io/router.tls.certresolver: "letsencrypt"' values.yaml
        //                         fi
        //                     '''
        //                     sh('''
        //                         helm repo add traefik https://traefik.github.io/charts
        //                         helm repo update
        //                         helm upgrade traefik -f tls-values.yaml traefik/traefik
        //                         helm upgrade myblog -f values.yaml oci://registry-1.docker.io/bitnamicharts/wordpress
        //                     ''')
        //                 }
        //             }
        //         }
        //     }
        // }

        // stage('Run WPScan') {
        //     steps {
        //         script {
        //             withCredentials([string(credentialsId: 'wordpressBlog', variable: 'WORDPRESS_DNS'),
        //                              string(credentialsId: 'wpsScanToken', variable: 'WPS_TOKEN')]) {
        //                 sh "wpscan --url ${WORDPRESS_DNS} --api-token ${WPS_TOKEN} --ignore-main-redirect > wpscan_results.txt"
        //             }
        //         }
        //     }
        // }

                                // // Check if the Traefik release is already deployed
                        // def isTraefikDeployed = sh(script: "helm list --namespace default -q | grep -w traefik", returnStatus: true) == 0

                        // if (!isTraefikDeployed) {
                        //     // If the release is not deployed, install it
                        //     echo "Traefik is not installed. Installing Traefik."
                        //     sh('''
                        //         helm repo add traefik https://traefik.github.io/charts
                        //         helm repo update
                        //         helm install traefik traefik/traefik --version 25.0.0
                        //     ''')
                        // } else {
                        //     // If Traefik is already installed, upgrade it with the new configuration
                        //     echo "Traefik is already installed. Upgrading Traefik."
                        //     sh('''
                        //         helm repo add traefik https://traefik.github.io/charts
                        //         helm repo update
                        //         helm upgrade traefik traefik/traefik --version 25.0.0
                        //     ''')
                        // }


                                                // // Check if the Helm release is already deployed
                        // def isDeployed = sh(script: "helm list --namespace default -q | grep -w myblog", returnStatus: true) == 0

                        // if (isDeployed) {
                        //     // If the release is deployed, upgrade it
                        //     echo "Release 'myblog' exists. Upgrading chart."
                        //     sh 'helm upgrade myblog -f values.yaml oci://registry-1.docker.io/bitnamicharts/wordpress'
                        // } else {
                        //     // If the release is not deployed, install it
                        //     echo "Release 'myblog' does not exist. Installing chart."
                        //     sh 'helm install myblog -f values.yaml oci://registry-1.docker.io/bitnamicharts/wordpress'
                        // }

                                                // // Check if the Prometheus Helm release is already deployed
                        // def isPrometheusDeployed = sh(script: "helm list --namespace default -q | grep -w prometheus", returnStatus: true) == 0

                        // if (isPrometheusDeployed) {
                        //     // If the release is deployed, upgrade it
                        //     echo "Release 'Prometheus' exists. Upgrading chart."
                        //     sh('''
                        //     helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                        //     helm repo update
                        //     helm upgrade prometheus prometheus-community/kube-prometheus-stack
                        //     ''')
                        // } else {
                        //     // If the release is not deployed, install it
                        //     echo "Release 'Prometheus' does not exist. Installing chart."
                        //     sh('''
                        //     helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                        //     helm repo update
                        //     helm install prometheus prometheus-community/kube-prometheus-stack
                        //     ''')
                        // }

                         // // Check if the Grafana Helm release is already deployed
                        // def isGrafanaDeployed = sh(script: "helm list --namespace default -q | grep -w grafana", returnStatus: true) == 0

                        // if (isGrafanaDeployed) {
                        //     // If the release is deployed, upgrade it
                        //     echo "Release 'Grafana' exists. Upgrading chart."
                        //     sh('''
                        //     helm repo add grafana https://grafana.github.io/helm-charts
                        //     helm repo update
                        //     helm upgrade grafana grafana/grafana -f grafana-values.yaml
                        //     ''')
                        // } else {
                        //     // If the release is not deployed, install it
                        //     echo "Release 'Grafana' does not exist. Installing chart."
                        //     sh('''
                        //     helm repo add grafana https://grafana.github.io/helm-charts
                        //     helm repo update
                        //     helm install grafana grafana/grafana -f grafana-values.yaml
                        //     ''')
                        // }

                        // // Check if the Loki Helm release is already deployed
                        // def isLokiDeployed = sh(script: "helm list --namespace default -q | grep -w loki", returnStatus: true) == 0

                        // if (isLokiDeployed) {
                        //     // If the release is deployed, upgrade it
                        //     echo "Release 'Loki' exists. Upgrading chart."
                        //     sh('''
                        //     helm repo add grafana https://grafana.github.io/helm-charts
                        //     helm repo update
                        //     helm upgrade loki grafana/loki
                        //     ''')
                        // } else {
                        //     // If the release is not deployed, install it
                        //     echo "Release 'Loki' does not exist. Installing chart."
                        //     sh('''
                        //     helm repo add grafana https://grafana.github.io/helm-charts
                        //     helm repo update
                        //     helm install loki grafana/loki
                        //     ''')
                        // }