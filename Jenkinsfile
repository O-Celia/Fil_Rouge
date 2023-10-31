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
                sh('''
                git clone https://github.com/Simplon-CeliaOuedraogo/Fil_Rouge.git
                ''')
            }
        }
        
        stage('Set up infrastructure with terraform') {
            steps {
                script {
                    withCredentials([azureServicePrincipal(credentialsId: 'ServicePrincipal')]) {
                    sh('''
                        #az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                        #az account set -s $AZURE_SUBSCRIPTION_ID
                        ls
                        cd terraform
                        terraform init
                        terraform apply --auto-approve
                    ''')
                    }
                }
            }
        }
    }
}
