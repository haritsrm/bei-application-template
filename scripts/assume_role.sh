#!/bin/bash
set -eo pipefail

role_arn="arn:aws:iam::517530806209:role/beiartf-reader-ff59caa9b4b093d9"

# parse command line
while [ "$#" -gt 0 ]; do
    case "$1" in
        -p) profile="$2"; shift 2;;
        -r) role_arn="$2"; shift 2;;
    esac
done

response=$(aws ${profile:+--profile $profile} \
               sts assume-role --output text \
               --region ap-southeast-1 \
               --role-arn "$role_arn" \
               --role-session-name="beiartfRole" \
               --query Credentials)

AWS_ACCESS_KEY_ID=$(echo $response | awk '{print $1}')
AWS_SECRET_ACCESS_KEY=$(echo $response | awk '{print $3}')
AWS_SESSION_TOKEN=$(echo $response | awk '{print $4}')
EXPIRATION=$(echo $response | awk '{print $2}')

eval "aws configure --profile beiartf set aws_access_key_id ${AWS_ACCESS_KEY_ID}"
eval "aws configure --profile beiartf set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}"
eval "aws configure --profile beiartf set aws_session_token ${AWS_SESSION_TOKEN}"
