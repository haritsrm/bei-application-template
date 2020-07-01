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

GIT_INPUT_REFERENCE="${CODEBUILD_SOURCE_VERSION}"

if [ -n "${CODEBUILD_WEBHOOK_TRIGGER}" ]; then # webhook-triggered build
    BUILD_NOTIFICATION_SOURCE="${CODEBUILD_WEBHOOK_TRIGGER}:${CODEBUILD_RESOLVED_SOURCE_VERSION}"
    if [[ ${CODEBUILD_WEBHOOK_TRIGGER} == branch/* ]]; then
        IS_BRANCH_TRIGGER=true
        GIT_INPUT_REFERENCE="${CODEBUILD_WEBHOOK_TRIGGER:7}"
    elif [[ ${CODEBUILD_WEBHOOK_TRIGGER} == tag/* ]]; then
        IS_TAG_TRIGGER=true
        GIT_INPUT_REFERENCE="${CODEBUILD_WEBHOOK_TRIGGER:4}"
    elif [[ ${CODEBUILD_WEBHOOK_TRIGGER} == pr/* ]]; then
        IS_PR_TRIGGER=true
    fi
fi

BUILD_RETURN_VALUE=$(($CODEBUILD_BUILD_SUCCEEDING-1))
BUILD_ID_COLON_POSITION=$(expr index ${CODEBUILD_BUILD_ID} ":")
BUILD_PROJECT=${CODEBUILD_BUILD_ID::BUILD_ID_COLON_POSITION-1}
BUILD_URL="https://ap-southeast-1.console.aws.amazon.com/codesuite/codebuild/projects/${BUILD_PROJECT}/build/${CODEBUILD_BUILD_ID}"

BUILD_NOTIFICATION_CHANNEL="<YOUR_SLACK_CHANNEL>"
BUILD_NOTIFICATION_FUNCTION=beicisb-notify_slack-7ced697186ad71d0

function send_build_notification () {
    BUILD_NOTIFICATION_PAYLOAD="{\"invoker\":\"codebuild\",\"slack-channel\":\"${BUILD_NOTIFICATION_CHANNEL}\",\"name\":\"${BUILD_PROJECT}\",\"source-version\":\"${BUILD_NOTIFICATION_SOURCE}\",\"build-status\":\"$1\",\"build-message\":\"$2\",\"build-url\":\"${BUILD_URL}\"}"
    BUILD_NOTIFICATION_COMMAND="aws lambda invoke --function-name ${BUILD_NOTIFICATION_FUNCTION} --region ${AWS_REGION} --payload ${BUILD_NOTIFICATION_PAYLOAD@Q} .beicisb_output"
    eval ${BUILD_NOTIFICATION_COMMAND}
}

# "build" task will execute the "check", which will execute the "test" task: https://docs.gradle.org/current/userguide/java_plugin.html#sec:java_project_layout
BUILD_COMMAND="./gradlew build"

# https://docs.gradle.org/5.4.1/dsl/org.gradle.api.plugins.quality.Checkstyle.html#org.gradle.api.plugins.quality.Checkstyle:source
SONAR_TASK="sonarqube"
if [[ ${FORCE_RELEASE} == "true" ]] || [[ ${GIT_INPUT_REFERENCE} =~ ${RELEASE_BRANCH_PATTERN} ]] || [[ ${GIT_INPUT_REFERENCE} =~ ${RELEASE_BRANCH_TARGETED_PATTERN} ]]; then
    # app release build
    . ${CURRENT_DIR}/targeted_build.sh
    if [ -n "${SERVICE_MODULE_NAME}" ]; then
        # partial release
        BUILD_COMMAND="./gradlew :${SERVICE_MODULE_NAME}:build distTar"
        RELEASE_COMMAND="./gradlew :${SERVICE_MODULE_NAME}:uploadAmiBakingManifest -Pversion=$(git rev-parse --short HEAD) -Daws.profile=\"default\""
        SONAR_TASK=""
        BUILD_SUCCESS_MESSAGE="service ${SERVICE_NAME} version $(git rev-parse --short HEAD) are released"
    else
        # full release
        BUILD_COMMAND="${BUILD_COMMAND} distTar"
        RELEASE_COMMAND="./gradlew uploadAmiBakingManifest -Pversion=$(git rev-parse --short HEAD) -Daws.profile=\"default\""
        BUILD_SUCCESS_MESSAGE="services version $(git rev-parse --short HEAD) are released"
    fi
elif [ "${IS_BRANCH_TRIGGER}" = true ]; then
    # branch build
    SONAR_TASK="${SONAR_TASK} -Dsonar.branch.name=${CODEBUILD_WEBHOOK_HEAD_REF:11}"
elif [ "${IS_PR_TRIGGER}" = true ]; then
    # PR build
    SONAR_TASK="${SONAR_TASK} -Dsonar.pullrequest.key=${CODEBUILD_WEBHOOK_TRIGGER:3} -Dsonar.pullrequest.branch=${CODEBUILD_WEBHOOK_HEAD_REF:11} -Dsonar.pullrequest.base=${CODEBUILD_WEBHOOK_BASE_REF:11}"
elif [[ ${CODEBUILD_SOURCE_VERSION} =~ ${VERSION_PATTERN} ]]|| ([ "${IS_TAG_TRIGGER}" = true ] && [[ ${CODEBUILD_WEBHOOK_TRIGGER:4} =~ ${VERSION_PATTERN} ]]); then
    # library publishing build
    BUILD_COMMAND="${BUILD_COMMAND} publishMavenJavaPublicationToMavenRepository -Pversion=${DETECTED_VERSION:1}"
    BUILD_SUCCESS_MESSAGE="libraries version ${DETECTED_VERSION} are published"
else
    # other builds
    SONAR_TASK="${SONAR_TASK} -Pversion=$(git rev-parse --short HEAD)"
fi

BUILD_COMMAND="${BUILD_COMMAND} ${SONAR_TASK}"
