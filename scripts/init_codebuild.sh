#!/bin/bash
set -eo pipefail
. ${CURRENT_DIR}/init_git.sh

IS_BRANCH_TRIGGER=false
IS_TAG_TRIGGER=false
IS_PR_TRIGGER=false

BUILD_NOTIFICATION_SOURCE="${CODEBUILD_INITIATOR}:${CODEBUILD_SOURCE_VERSION}"
if [ "${CODEBUILD_SOURCE_VERSION}" != "${CODEBUILD_RESOLVED_SOURCE_VERSION}" ]; then
    BUILD_NOTIFICATION_SOURCE="${BUILD_NOTIFICATION_SOURCE}:${CODEBUILD_RESOLVED_SOURCE_VERSION}"
fi

if [ -n "${CODEBUILD_WEBHOOK_TRIGGER}" ]; then # webhook-triggered build
    BUILD_NOTIFICATION_SOURCE="${CODEBUILD_WEBHOOK_TRIGGER}:${CODEBUILD_RESOLVED_SOURCE_VERSION}"
    if [[ ${CODEBUILD_WEBHOOK_TRIGGER} == branch/* ]]; then
        IS_BRANCH_TRIGGER=true
    elif [[ ${CODEBUILD_WEBHOOK_TRIGGER} == tag/* ]]; then
        IS_TAG_TRIGGER=true
    elif [[ ${CODEBUILD_WEBHOOK_TRIGGER} == pr/* ]]; then
        IS_PR_TRIGGER=true
    fi
fi

BUILD_RETURN_VALUE=$(($CODEBUILD_BUILD_SUCCEEDING-1))
BUILD_ID_COLON_POSITION=$(expr index ${CODEBUILD_BUILD_ID} ":")
BUILD_PROJECT=${CODEBUILD_BUILD_ID::BUILD_ID_COLON_POSITION-1}
BUILD_URL="https://ap-southeast-1.console.aws.amazon.com/codesuite/codebuild/projects/${BUILD_PROJECT}/build/${CODEBUILD_BUILD_ID}"

BUILD_NOTIFICATION_CHANNEL=backend-infra-review
BUILD_NOTIFICATION_FUNCTION=beicisb-notify_slack-7ced697186ad71d0

function send_build_notification () {
    BUILD_NOTIFICATION_PAYLOAD="{\"invoker\":\"codebuild\",\"slack-channel\":\"${BUILD_NOTIFICATION_CHANNEL}\",\"name\":\"${BUILD_PROJECT}\",\"source-version\":\"${BUILD_NOTIFICATION_SOURCE}\",\"build-status\":\"$1\",\"build-message\":\"$2\",\"build-url\":\"${BUILD_URL}\"}"
    BUILD_NOTIFICATION_COMMAND="aws lambda invoke --function-name ${BUILD_NOTIFICATION_FUNCTION} --region ${AWS_REGION} --payload ${BUILD_NOTIFICATION_PAYLOAD@Q} .beicisb_output"
    eval ${BUILD_NOTIFICATION_COMMAND}
}

BUILD_COMMAND="./gradlew smallTest smallJacocoReport"
# https://docs.gradle.org/5.4.1/dsl/org.gradle.api.plugins.quality.Checkstyle.html#org.gradle.api.plugins.quality.Checkstyle:source
SONAR_COMMAND="./gradlew check sonarqube --no-build-cache"
if [ "${IS_BRANCH_TRIGGER}" = true ]; then
    SONAR_COMMAND="${SONAR_COMMAND} -Dsonar.branch.name=${CODEBUILD_WEBHOOK_HEAD_REF:11}"
elif [ "${IS_PR_TRIGGER}" = true ]; then
    SONAR_COMMAND="${SONAR_COMMAND} -Dsonar.pullrequest.key=${CODEBUILD_WEBHOOK_TRIGGER:3} -Dsonar.pullrequest.branch=${CODEBUILD_WEBHOOK_HEAD_REF:11} -Dsonar.pullrequest.base=${CODEBUILD_WEBHOOK_BASE_REF:11}"
elif [[ ${CODEBUILD_SOURCE_VERSION} =~ ${VERSION_PATTERN} ]]|| ([ "${IS_TAG_TRIGGER}" = true ] && [[ ${CODEBUILD_WEBHOOK_TRIGGER:4} =~ ${VERSION_PATTERN} ]]); then
    BUILD_COMMAND="${BUILD_COMMAND} publishMavenJavaPublicationToMavenRepository -Pversion=${DETECTED_VERSION:1}"
    SONAR_COMMAND="${SONAR_COMMAND} -Pversion=${DETECTED_VERSION:1}"
    BUILD_SUCCESS_MESSAGE="libraries ${DETECTED_VERSION} are published"
elif [[ ${FORCE_RELEASE} == "true" ]] || [[ ${CODEBUILD_SOURCE_VERSION} =~ ${RELEASE_BRANCH_PATTERN} ]] || ([ "${IS_BRANCH_TRIGGER}" = true ] && [[ ${CODEBUILD_WEBHOOK_TRIGGER:7} =~ ${RELEASE_BRANCH_PATTERN} ]]); then
    BUILD_COMMAND="${BUILD_COMMAND} uploadAmiBakingManifest -Pversion=$(git rev-parse --short HEAD)"
    SONAR_COMMAND="${SONAR_COMMAND} -Pversion=$(git rev-parse --short HEAD)"
    BUILD_SUCCESS_MESSAGE="services version $(git rev-parse --short HEAD) are released"
else
    SONAR_COMMAND="${SONAR_COMMAND} -Pversion=$(git rev-parse --short HEAD)"
fi
