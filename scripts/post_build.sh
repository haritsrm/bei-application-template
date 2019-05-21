#!/bin/bash
set -eo pipefail
CURRENT_DIR="$(dirname "$0")"
. ${CURRENT_DIR}/init_git.sh
. ${CURRENT_DIR}/init_${CI_NAME}.sh

if [[ ${BUILD_RETURN_VALUE} == 0 ]]; then
    send_build_notification "succeed" "$BUILD_SUCCESS_MESSAGE"
else
    send_build_notification "failed" "see build log for more details"
fi
