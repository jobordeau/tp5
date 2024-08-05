pipeline {
    agent any 
    environment {
        DOCKERHUB_CREDENTIALS = credentials('karim-dockerhub')
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        APP_NAME = "jobordeau/myapp-flask"
    }
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
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
        stage('Terraform Checkout') {
            steps {
                script {
                    dir("terraform") {
                        git branch: 'main', url: 'https://github.com/jobordeau/tp6.git'
                    }
                }
            }
        }
        stage('Terraform Init and Plan') {
            steps {
                sh 'cd terraform && terraform init'
                sh 'cd terraform && terraform plan -out tfplan'
                sh 'cd terraform && terraform show -no-color tfplan > tfplan.txt'
            }
        }
        stage('Terraform Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'cd terraform && terraform apply -input=false tfplan'
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}
