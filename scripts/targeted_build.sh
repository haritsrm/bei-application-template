#!/bin/bash
# credit to flight team for the basic structure
declare -A SERVICE_MODULE_MAPPING

if [[ ${GIT_INPUT_REFERENCE} =~ ${RELEASE_BRANCH_TARGETED_PATTERN} ]]; then
  SERVICE_NAME=${BASH_REMATCH[1]}
  SERVICE_MODULE_NAME=${SERVICE_MODULE_MAPPING[${SERVICE_NAME}]}
fi

