#!/bin/bash
set -eo pipefail

GIT_INPUT_REFERENCE=${CODEBUILD_SOURCE_VERSION}
if [ -n "${CODEBUILD_WEBHOOK_TRIGGER}" ]; then
    PROJECT_TRIGGER=${CODEBUILD_WEBHOOK_TRIGGER}
    GIT_INPUT_REFERENCE="${CODEBUILD_WEBHOOK_TRIGGER:7}"
else
    PROJECT_TRIGGER=${CODEBUILD_INITIATOR}
fi

BUILD_RETURN_VALUE=$(($CODEBUILD_BUILD_SUCCEEDING-1))
BUILD_ID_COLON_POSITION=$(expr index ${CODEBUILD_BUILD_ID} ":")
BUILD_PROJECT=${CODEBUILD_BUILD_ID::BUILD_ID_COLON_POSITION-1}
BUILD_URL="https://ap-southeast-1.console.aws.amazon.com/codesuite/codebuild/projects/${BUILD_PROJECT}/build/${CODEBUILD_BUILD_ID}"

BUILD_NOTIFICATION_CHANNEL=placeholder-slack-channel
BUILD_NOTIFICATION_FUNCTION=beicisb-notify_slack-7ced697186ad71d0

function send_build_notification () {
    BUILD_NOTIFICATION_PAYLOAD="{\"invoker\":\"codebuild\",\"slack-channel\":\"${BUILD_NOTIFICATION_CHANNEL}\",\"name\":\"${BUILD_PROJECT}\",\"source-version\":\"${PROJECT_TRIGGER}:${GIT_INPUT_REFERENCE}\",\"build-status\":\"$1\",\"build-message\":\"$2\",\"build-url\":\"${BUILD_URL}\"}"
    BUILD_NOTIFICATION_COMMAND="aws lambda invoke --function-name ${BUILD_NOTIFICATION_FUNCTION} --region ${AWS_REGION} --payload ${BUILD_NOTIFICATION_PAYLOAD@Q} .beicisb_output"
    eval $BUILD_NOTIFICATION_COMMAND
}
