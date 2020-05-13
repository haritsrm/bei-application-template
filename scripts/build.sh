#!/bin/bash
set -eo pipefail
CURRENT_DIR="$(dirname "$0")"

if [ -n "${CI_NAME}" ]; then
    . ${CURRENT_DIR}/init_${CI_NAME}.sh
    . ${CURRENT_DIR}/assume_role.sh -r arn:aws:iam::517530806209:role/BeiartfWriter_bei      # move this to the prebuild step
    echo "${BUILD_COMMAND}"
    eval "${BUILD_COMMAND}"
    if [[ -n "${RELEASE_COMMAND}" ]]; then
        echo "${RELEASE_COMMAND}"
        eval "${RELEASE_COMMAND}"
    fi
    if [[ -n "${SONAR_COMMAND}" ]]; then
        echo "${SONAR_COMMAND}"
        eval "${SONAR_COMMAND} -Dsonar.login=${SONARCLOUD_TOKEN}"
    fi
else
    # local build
    BUILD_COMMAND="./gradlew build --write-locks --no-build-cache"
    # run saml of your choice first
    . ${CURRENT_DIR}/assume_role.sh -p saml -r arn:aws:iam::517530806209:role/beiartf-reader-ff59caa9b4b093d9
    echo "${BUILD_COMMAND}"
    eval "${BUILD_COMMAND}"
fi
