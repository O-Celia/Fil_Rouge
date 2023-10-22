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
        stage('Build infrastructure') {
            steps {
                sh('''
                    cd terraform
                ''')
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
