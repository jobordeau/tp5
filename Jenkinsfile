pipeline {
    agent any 
    environment {
        DOCKERHUB_CREDENTIALS = credentials('karim-dockerhub')
        APP_NAME = "jobordeau/myapp-flask"
    }
    stages { 
        stage('SCM Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/jobordeau/tp5.git'
            }
        }
        stage('Build docker image') {
            steps {  
                sh 'docker build -t $APP_NAME:$BUILD_NUMBER .'
            }
        }
        stage('Scan Docker Image') {
            steps {
                script {
                    // Exécutez Trivy pour scanner l'image Docker et ne rapporter que les vulnérabilités "HIGH" et "CRITICAL"
                    def trivyOutput = sh(script: "trivy image --severity HIGH,CRITICAL $APP_NAME:$BUILD_NUMBER", returnStdout: true).trim()
                    println trivyOutput
                    
                    // Vérifiez si des vulnérabilités "CRITICAL" ont été trouvées
                    if (trivyOutput.contains("CRITICAL: 0")) {
                        echo "No critical vulnerabilities found in the Docker image."
                    } else {
                        echo "Critical vulnerabilities found in the Docker image."
                        error "Critical vulnerabilities found in the Docker image."
                    }
                }
            }
        }
        stage('login to dockerhub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'karim-dockerhub', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
                        sh 'echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin'
                    }
                }
            }
        }
        stage('push image') {
            steps {
                sh 'docker push $APP_NAME:$BUILD_NUMBER'
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}
