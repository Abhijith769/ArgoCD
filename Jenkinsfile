pipeline {
    agent { node { label 'jenkins-slave' } }
    environment {
        AWS_ACCOUNT_ID = "361752933564"
        AWS_DEFAULT_REGION = "ap-south-1"
        IMAGE_REPO_NAME = "x-non-prod-ecr"
        IMAGE_NAME = "x-app"
        COMMIT_ID = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        HELM_CHART_PATH = "helm-chart"
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
                    docker.build "${IMAGE_NAME}:${COMMIT_ID}"
                }
            }
        }

        stage('Pushing to ECR') {
            steps {
                script {
                    def tag = "${IMAGE_NAME}_${COMMIT_ID}"
                    sh "docker tag ${IMAGE_NAME}:${COMMIT_ID} ${REPOSITORY_URI}:${tag}"
                    sh "docker push ${REPOSITORY_URI}:${tag}"
                }
            }
        }

        stage('Update Helm Chart Image Tag') {
            steps {
                script {
                    def valuesFilePath = "${HELM_CHART_PATH}/values.yaml"
                    
                    // Replace the image tag in the values.yaml file
                    sh "sed -i 's/tag:.*/tag: ${COMMIT_ID}/' ${valuesFilePath}"
                    
                    // Commit and push the changes back to Git
                    sh "git -C ${HELM_CHART_PATH} add ${valuesFilePath}"
                    sh "git -C ${HELM_CHART_PATH} commit -m 'Update image tag in Helm Chart'"
                    sh "git -C ${HELM_CHART_PATH} push origin master"  // Modify 'master' to your branch if necessary
                }
            }
        }
    }
}
