// Template Jenkinsfile for R CI/CD Tasks
// url: https://github.com/INWT/inwt-templates/blob/master/jenkins/r-ci.Jenkinsfile
// Author: Sebastian Warnholz
// Modified by: Andreas Neudecker
pipeline {
    agent none
    options { disableConcurrentBuilds() }
    environment {
        CUR_PROJ = 'inwt-utils' //
        CUR_PKG = 'INWTUtils' // r-package name
        CUR_PKG_FOLDER = '.' // defaults to root
        INWT_REPO = 'inwt-vmdocker1.inwt.de:8081'
        EMAIL = 'mira.klein@inwt-statistics.de'
        TMP_SUFFIX = """${sh(returnStdout: true, script: 'echo `cat /dev/urandom | tr -dc \'a-z\' | fold -w 6 | head -n 1`')}"""
    }
    stages {
        stage('Build Docker image for testing') {
            agent { label 'test' }
            when { not { branch 'depl' } }
            steps {
                sh '''
                docker build --pull -t tmp-$CUR_PROJ-$TMP_SUFFIX .
                '''
            }
        }
        stage('Testing with R') {
            agent { label 'test' }
            when { not { branch 'depl' } }
            steps {
                sh '''
                docker run --rm --network host tmp-$CUR_PROJ-$TMP_SUFFIX check
                docker rmi tmp-$CUR_PROJ-$TMP_SUFFIX
                '''
            }
        }
        stage('Deploy Docker-image') {
            agent { label 'docker' }
            when  { branch 'master' }
            steps {
                sh '''
                docker build --pull -t $INWT_REPO/$CUR_PROJ:latest .
                docker push $INWT_REPO/$CUR_PROJ:latest
                docker rmi $INWT_REPO/$CUR_PROJ:latest
                '''
            }
        }
        stage('Deploy R-package') {
            agent { label 'eh2' }
            when { branch 'master' }
            steps {
                sh '''
                docker pull $INWT_REPO/$CUR_PROJ:latest
                docker run --rm --network host -v $PWD:/app --user `id -u`:`id -g` $INWT_REPO/$CUR_PROJ:latest R CMD build $CUR_PKG_FOLDER
                docker run --rm -v $PWD:/app -v /var/www/html/r-repo:/var/www/html/r-repo inwt/r-batch:latest R -e "drat::insertPackage(dir(pattern='.tar.gz'), '/var/www/html/r-repo'); drat::archivePackages(repopath = '/var/www/html/r-repo')"
                docker rmi $INWT_REPO/$CUR_PROJ:latest
                rm -vf *.tar.gz
                '''
            }
        }
    }
    post {
        failure {
           script {
                if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'depl') {
                    emailext (
                        attachLog: true,
                        body: "Build of job ${env.JOB_NAME} (No. ${env.BUILD_NUMBER}) has completed\n\nBuild status: ${currentBuild.currentResult}\n\n${env.BUILD_URL}\n\nSee attached log file for more details of the build process.",
                        recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']],
                        to: "${env.EMAIL}",
                        subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}"
                    )
                }
            }
        }
    }
}
