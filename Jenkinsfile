pipeline {
    agent any
    
    stages {
        stage('Pré-Cleanup') {
            steps {
                // cleanWs()
                // echo "Building ${env.JOB_NAME}..."
                sh "ls"
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

                // sh('''
                // git clone https://github.com/Simplon-CeliaOuedraogo/Fil_Rouge.git
                // ''')
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
    }
}
