pipeline {
    agent { node { label 'jenkins-slave' } }
    environment {
        AWS_ACCOUNT_ID = "361752933564"
        AWS_DEFAULT_REGION = "ap-south-1"
        IMAGE_REPO_NAME = "x-non-prod-ecr"
        IMAGE_NAME = "x-app"
        IMAGE_TAG = "latest"
        
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }

    stages {
        stage('Logging into AWS ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                }
            }
        }

        stage('Building image') {
            steps {
                script {
                    docker.build "${IMAGE_NAME}:${IMAGE_TAG}" 
                }
            }
        }

        stage('Pushing to ECR') {
            steps {
                script {
                    def tag = "${IMAGE_NAME}_${IMAGE_TAG}"  // Define the tag based on your requirement
                    
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${tag}"
                    sh "docker push ${REPOSITORY_URI}:${tag}"
                }
            }
        }
    }
}
