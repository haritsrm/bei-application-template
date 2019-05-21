#!/bin/bash
set -eo pipefail
CURRENT_DIR="$(dirname "$0")"
. ${CURRENT_DIR}/init_git.sh

if [ -n "${CI_NAME}" ]; then
    . ${CURRENT_DIR}/init_${CI_NAME}.sh
    echo "${BUILD_COMMAND}"
    eval "${BUILD_COMMAND}"
    echo "${SONAR_COMMAND}"
    eval "${SONAR_COMMAND} -Dsonar.login=${SONARCLOUD_TOKEN}"
else
    # local build
    ./gradlew build --write-locks --no-build-cache
fi
