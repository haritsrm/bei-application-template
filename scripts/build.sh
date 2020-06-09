#!/bin/bash
set -eo pipefail
CURRENT_DIR="$(dirname "$0")"

if [ -n "${CI_NAME}" ]; then
    . ${CURRENT_DIR}/init_${CI_NAME}.sh
    echo "${BUILD_COMMAND}"
    eval "${BUILD_COMMAND} -Dsonar.login=${SONARCLOUD_TOKEN}"
    if [[ -n "${RELEASE_COMMAND}" ]]; then
        echo "${RELEASE_COMMAND}"
        eval "${RELEASE_COMMAND}"
    fi
else
    set -v
    # local build
    BUILD_COMMAND="./gradlew build resolveAndLockAll --write-locks"

    eval "${BUILD_COMMAND}"
fi
