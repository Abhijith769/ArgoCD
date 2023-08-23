pipeline {
    agent { node { label 'jenkins-slave' } }
    environment {
        AWS_ACCOUNT_ID = "361752933564"
        AWS_DEFAULT_REGION = "ap-south-1"
        IMAGE_REPO_NAME = "x-non-prod-ecr"
        IMAGE_NAME = "x-app"
        COMMIT_ID = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
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

                    // Print the working directory
                    sh 'pwd'

                    // List files in the current directory
                    sh 'ls'

                    def helmChartPath = '/opt/build/workspace/project-x/helm-chart'  // Path to your Helm Chart folder in the Git repo
                    def valuesFilePath = "${helmChartPath}/values.yaml"
                    
                    // Replace the image tag in the values.yaml file
                    sh "sed -i 's/tag:.*/tag: ${IMAGE_NAME}_${COMMIT_ID}/' ${valuesFilePath}"
                    
                    // Configure Git to use provided credentials
                    withCredentials([usernamePassword(credentialsId: 'project-x', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh "git -C ${helmChartPath} config --local credential.helper '!f() { echo username=${GIT_USERNAME}; echo password=${GIT_PASSWORD}; }; f'"
                        //sh "git -C ${helmChartPath} pull https://github.com/Abhijith769/project-x.git"
                        sh "git -C ${helmChartPath} add ${valuesFilePath}"
                        sh "git -C ${helmChartPath} commit -m 'Update image tag'"
                        
                        // Fetch and merge remote changes
                        sh "git -C ${helmChartPath} fetch origin main"
                        sh "git -C ${helmChartPath} merge origin/main"
                        

                        // Push the merged changes
                        sh "git -C ${helmChartPath} push origin HEAD:main"
                    }
                }
            }
        }
    }
}
