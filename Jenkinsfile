#!groovy

// Project Settings for Deployment
String PROJECTNAME = "static-schemas"
String CONTAINERDIR = "."
String INFRASTRUCTURE = 'thanos'
String PLAYBOOK = 'deploy-static.yml'

// All other data uses variables, no changes needed for static
String CONTAINERNAME = "repo.data.amsterdam.nl/static/${PROJECTNAME}:${env.BUILD_NUMBER}"
String BRANCH = "${env.BRANCH_NAME}"

image = 'initial value'

def tryStep(String message, Closure block, Closure tearDown = null) {
    try {
        block();
    }
    catch (Throwable t) {
        // Disable while developing
        // slackSend message: "${env.JOB_NAME}: ${message} failure ${env.BUILD_URL}", channel: '#ci-channel', color: 'danger'
        throw t;
    }
    finally {
        if (tearDown) {
            tearDown();
        }
    }
}

node {
    // Get a copy of the code
    stage("Checkout") {
        checkout scm
    }

    // Build the Dockerfile in the $CONTAINERDIR and push it to Nexus
    stage("Build develop image") {
        tryStep "build", {
            image = docker.build("${CONTAINERNAME}","${CONTAINERDIR}")
            image.push()
        }
    }
}

if (BRANCH == "master") {
    node {
        stage("Deploy to ACC") {
            tryStep "deployment", {
                image.push("acceptance")
                build job: 'Subtask_Openstack_Playbook',
                parameters: [
                    [$class: 'StringParameterValue', name: 'INFRASTRUCTURE', value: "${INFRASTRUCTURE}"],
                    [$class: 'StringParameterValue', name: 'INVENTORY', value: 'acceptance'],
                    [$class: 'StringParameterValue', name: 'PLAYBOOK', value: "${PLAYBOOK}"],
                    [$class: 'StringParameterValue', name: 'STATIC_CONTAINER', value: "${PROJECTNAME}"],
                ]
            }
        }
    }

    stage('Waiting for approval') {
        slackSend channel: '#ci-channel', color: 'warning', message: 'BAG is waiting for Production Release - please confirm'
        input "Deploy to Production?"
    }

    node {
        stage("Deploy to PROD") {
            tryStep "deployment", {
                image.push("production")
                image.push("latest")
                build job: 'Subtask_Openstack_Playbook',
                parameters: [
                    [$class: 'StringParameterValue', name: 'INFRASTRUCTURE', value: "${INFRASTRUCTURE}"],
                    [$class: 'StringParameterValue', name: 'INVENTORY', value: 'production'],
                    [$class: 'StringParameterValue', name: 'PLAYBOOK', value: "${PLAYBOOK}"],
                    [$class: 'StringParameterValue', name: 'STATIC_CONTAINER', value: "${PROJECTNAME}"],
                ]
            }
        }
    }
}
