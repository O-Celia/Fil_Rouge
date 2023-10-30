pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS = credentials('ServicePrincipal')
    }
    
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
                    withCredentials([azure(credentialsId: 'AZURE_CREDENTIALS')]) {
                    sh('''
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
