#!groovy
def tryStep(String message, Closure block, Closure tearDown = null) {
    try {
        block();
    }
    catch (Throwable t) {
        slackSend message: "${env.JOB_NAME}: ${message} failure ${env.BUILD_URL}", channel: '#ci-channel', color: 'danger'
        throw t;
    }
    finally {
        if (tearDown) {
            tearDown();
        }
    }
}
node {
    stage("Checkout") {
        checkout scm
    }
}
String BRANCH = "${env.BRANCH_NAME}"
if (BRANCH == "master" || BRANCH == "develop") {
    node {
        stage('Push acceptance image') {
            tryStep "image tagging", {
                def image = docker.image("build.data.amsterdam.nl:5000/static/static-schemas:${env.BUILD_NUMBER}",
                    "--shm-size 1G " +
                    "--build-arg BUILD_ENV=acc " +
                    "--build-arg BUILD_NUMBER=${env.BUILD_NUMBER} " +
                    ".")
                image.pull()
                image.push("acceptance")
            }
        }
    }
    node {
        stage("Deploy to ACC") {
            tryStep "deployment", {
                build job: 'Subtask_Openstack_Playbook',
                        parameters: [
                                [$class: 'StringParameterValue', name: 'INVENTORY', value: 'acceptance'],
                                [$class: 'StringParameterValue', name: 'PLAYBOOK', value: 'deploy-static-schemas.yml'],
                        ]
            }
        }
    }
}
if (BRANCH == "master") {
    stage('Waiting for approval') {
        slackSend channel: '#ci-channel', color: 'warning', message: 'static-schemas is waiting for Production Release - please confirm'
        input "Deploy to Production?"
    }
    node {
        stage('Push production image') {
            tryStep "image tagging", {
                def image = docker.image("build.data.amsterdam.nl:5000/static/static-schemas:${env.BUILD_NUMBER}",
                    "--shm-size 1G " +
                    "--build-arg BUILD_ENV=prod " +
                    "--build-arg BUILD_NUMBER=${env.BUILD_NUMBER} " +
                    ".")
                image.pull()
                image.push("production")
                image.push("latest")
            }
        }
    }
    node {
        stage("Deploy") {
            tryStep "deployment", {
                build job: 'Subtask_Openstack_Playbook',
                        parameters: [
                                [$class: 'StringParameterValue', name: 'INVENTORY', value: 'production'],
                                [$class: 'StringParameterValue', name: 'PLAYBOOK', value: 'deploy-static-schemas.yml'],
                        ]
            }
        }
    }
}