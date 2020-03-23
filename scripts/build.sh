#!/bin/bash
set -eo pipefail
CURRENT_DIR="$(dirname "$0")"

if [ -n "${CI_NAME}" ]; then
    . ${CURRENT_DIR}/init_${CI_NAME}.sh
    echo "${BUILD_COMMAND}"
    eval "${BUILD_COMMAND}"
    if [[ -n "${SONAR_COMMAND}" ]]; then
        echo "${SONAR_COMMAND}"
        eval "${SONAR_COMMAND} -Dsonar.login=${SONARCLOUD_TOKEN}"
    fi
else
    # local build
    BUILD_COMMAND="./gradlew build --write-locks --no-build-cache"
    echo "${BUILD_COMMAND}"
    eval "${BUILD_COMMAND}"
fi
