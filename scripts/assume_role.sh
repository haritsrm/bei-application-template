#!/bin/bash
set -eo pipefail

declare -A saved_role_arn
saved_role_arn[beiartf]="arn:aws:iam::015110552125:role/BeiartfReader"
saved_role_arn[default]="arn:aws:iam::015110552125:role/DevExample"     # change this with the role arn that you need to run applications correctly

session_name="beiartf"

# parse command line
while [ "$#" -gt 0 ]; do
    case "$1" in
        -p) profile="$2"; shift 2;;
        -r) role_arn="$2"; shift 2;;
        -n) session_name="$2"; shift 2;;
    esac
done

if [[ -z "${role_arn}" ]]; then
    role_arn=${saved_role_arn[${session_name}]}
fi

response=$(aws ${profile:+--profile $profile} \
               sts assume-role --output text \
               --region ap-southeast-1 \
               --role-arn "$role_arn" \
               --role-session-name="$session_name" \             
               --query Credentials)

AWS_ACCESS_KEY_ID=$(echo $response | awk '{print $1}')
AWS_SECRET_ACCESS_KEY=$(echo $response | awk '{print $3}')
AWS_SESSION_TOKEN=$(echo $response | awk '{print $4}')
EXPIRATION=$(echo $response | awk '{print $2}')

eval "aws configure --profile ${session_name} set aws_access_key_id ${AWS_ACCESS_KEY_ID}"
eval "aws configure --profile ${session_name} set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}"
eval "aws configure --profile ${session_name} set aws_session_token ${AWS_SESSION_TOKEN}"
