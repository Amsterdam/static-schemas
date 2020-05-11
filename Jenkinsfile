#!groovy

// Project Settings for Deployment
String PROJECTNAME = "static-schemas"
String CONTAINERDIR = "."
String PRODUCTION_BRANCH = "master"
String ACCEPTANCE_BRANCH = "development"
String PLAYBOOK = 'deploy-static-schemas.yml'
String CONTAINERNAME = "docker-registry.data.amsterdam.nl/static/${PROJECTNAME}:${env.BUILD_NUMBER}"
String BRANCH = "${env.BRANCH_NAME}"

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
    // Get a copy of the code
    stage("Checkout") {
        checkout scm
    }

    // Build the Dockerfile in the $CONTAINERDIR and push it to Nexus
    stage("Build develop image") {
        tryStep "build", {
            image = docker.build("${CONTAINERNAME}","${CONTAINERDIR} --build-arg CACHE_BUST=${env.BUILD_NUMBER}")
            // image = docker.build("${CONTAINERNAME}","${CONTAINERDIR}")
            image.push()
        }
    }
}

// Acceptance branch, fetch the container, label with acceptance and deploy to acceptance
if (BRANCH == "${ACCEPTANCE_BRANCH}" || BRANCH == "${PRODUCTION_BRANCH}") {
    node {
        stage("Deploy to ACC") {
            tryStep "deployment", {
                image.push("acceptance")
                build job: 'Subtask_Openstack_Playbook',
                        parameters: [
                                [$class: 'StringParameterValue', name: 'INVENTORY', value: 'acceptance'],
                                [$class: 'StringParameterValue', name: 'PLAYBOOK', value: "${PLAYBOOK}"],
                        ]
            }
        }
  }
}

// On master branch, fetch the container, tag with production and latest and deploy to production
if (BRANCH == "${PRODUCTION_BRANCH}") {
    node {
        stage("Deploy to PROD") {
            tryStep "deployment", {
                image.push("production")
                image.push("latest")
                build job: 'Subtask_Openstack_Playbook',
                        parameters: [
                                [$class: 'StringParameterValue', name: 'INVENTORY', value: 'production'],
                                [$class: 'StringParameterValue', name: 'PLAYBOOK', value: "${PLAYBOOK}"],
                        ]
            }
        }
    }
}
