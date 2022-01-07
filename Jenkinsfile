pipeline {
    agent none
    options {
        buildDiscarder(logRotator(daysToKeepStr: '30'))
        parallelsAlwaysFailFast()
    }
    triggers { cron(env.BRANCH_NAME ==~ /^master$/ ? 'H H(0-6) 1 * *' : '') }
    stages {
        stage('Matrix') {
            matrix {
                axes {
                    axis {
                        name 'BUILD'
                        values 'php71|php72', 'php73|php74', 'php80'
                    }
                    axis {
                        name 'PLATFORM'
                        values 'linux-amd64', 'linux-arm64'
                    }
                }
                environment {
                    TAG_SUFFIX = "-${PLATFORM}"
                }
                stages {
                    stage('Build, Test, Publish') {
                        agent { label "${PLATFORM}" }
                        stages {
                            stage('Build') {
                                steps {
                                    sh 'docker-compose config --services | grep -E "${BUILD}" | xargs --no-run-if-empty docker-compose build --pull'
                                }
                            }
                            stage('Publish') {
                                environment {
                                    DOCKER_REGISTRY_CREDS = credentials('docker-registry-credentials')
                                }
                                when {
                                    branch 'master'
                                }
                                steps {
                                    sh 'echo "$DOCKER_REGISTRY_CREDS_PSW" | docker login --username "$DOCKER_REGISTRY_CREDS_USR" --password-stdin docker.io'
                                    sh 'docker-compose config --services | grep -E "${BUILD}" | xargs --no-run-if-empty docker-compose push'
                                }
                                post {
                                    always {
                                        sh 'docker logout docker.io'
                                    }
                                }
                            }
                        }
                        post {
                            always {
                                cleanWs()
                            }
                        }
                    }
                }
            }
        }
        stage('Publish main image') {
            agent { label "linux-amd64" }
            environment {
                DOCKER_REGISTRY_CREDS = credentials('docker-registry-credentials')
            }
            when {
                branch 'master'
            }
            steps {
                sh './manifest-push.sh'
            }
            post {
                always {
                    sh 'docker logout docker.io'
                    cleanWs()
                }
            }
        }
    }
}
