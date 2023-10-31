pipeline {
    agent any
    
    stages {
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
                        cd terraform
                        terraform init
                        terraform apply --auto-approve
                    ''')
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Nettoyage de l'espace de travail Jenkins
            step([$class: 'WsCleanup'])
        }
    }
}
