#!/bin/bash
set -evo pipefail
CURRENT_DIR="$(dirname "$0")"
. ${CURRENT_DIR}/init_git.sh
. ${CURRENT_DIR}/init_${CI_NAME}.sh

BUILD_STATUS="succeed"
if [[ ${BUILD_RETURN_VALUE} == 0 ]]; then
    if [[ ${DETECTED_VERSION} =~ ${VERSION_PATTERN} ]]; then
        BUILD_MESSAGE="libraries version ${DETECTED_VERSION} published"
    fi
    if [[ ${FORCE_RELEASE} == "true" ]] || [[ ${GIT_INPUT_REFERENCE} =~ ${RELEASE_BRANCH_PATTERN} ]]; then
        BUILD_MESSAGE="services version $(git rev-parse --short HEAD) uploaded"
    fi
else
    BUILD_STATUS="failed"
    BUILD_MESSAGE="see build log for more details"
fi

send_build_notification "$BUILD_STATUS" "$BUILD_MESSAGE"
