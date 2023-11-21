pipeline {
    agent any
    
    stages {
        stage('Pré-Cleanup') {
            steps {
                cleanWs()
                echo "Building ${env.JOB_NAME}..."
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
                        sh "git pull"
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
                    sh('''
                        az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                        cd Fil_Rouge/terraform
                        terraform init
                        terraform apply --auto-approve
                    ''')
                    }
                }
            }
        }
    }
}
