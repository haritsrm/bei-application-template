#!/usr/bin/env groovy

// DEPRECATED. Please migrate to CodeBuild ASAP

@Library("backend-jenkins")
import com.traveloka.common.jenkins.beiartf.BeiartfUtil

node("aws-ecs") {
  timestamps {
    wrap([$class: "AnsiColorBuildWrapper", "colorMapName": "XTerm", "defaultFg": 1, "defaultBg": 2]) {

      def VERSION
      def currentDir = pwd()

      stage("checkout") {
        checkout scm
        VERSION = sh script: "git rev-parse --short HEAD", returnStdout: true
        VERSION = VERSION.trim()
        currentBuild.displayName = "#$BUILD_NUMBER $VERSION"
        currentBuild.description = "Bei Template Release"
      }

      stage("publish") {
        withCredentials([
          [
            $class           : 'AmazonWebServicesCredentialsBinding',
            accessKeyVariable: "AWS_ACCESS_KEY_ID",
            credentialsId    : 'tvlk-dev-user-jenkins',
            secretKeyVariable: "AWS_SECRET_ACCESS_KEY"
          ]
        ]) {
          BeiartfUtil.assumeRole(this)
          sh "GIT_INPUT_REFERENCE=$GIT_REF FORCE_RELEASE=$FORCE_RELEASE ./build.sh"
        }
      }
    }
  }
}
