#!/bin/bash
set -eo pipefail

role_arn="arn:aws:iam::015110552125:role/BeiartfReader"

# parse command line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -p) profile="$2"; shift 2;;
        -r) role_arn="$2"; shift 2;;
    esac
done

PRINCIPAL=$(aws --region ap-southeast-1 ${profile:+--profile $profile} sts get-caller-identity --output text --query UserId | cut -d : -f 2)

# assume the role_arn
response=$(aws ${profile:+--profile $profile} \
               sts assume-role --output text \
               --region ap-southeast-1 \
               --role-arn "$role_arn" \
               --role-session-name="$PRINCIPAL" \
               --query Credentials)

# creating a new aws profile
AWS_ACCESS_KEY_ID=$(echo $response | awk '{print $1}')
AWS_SECRET_ACCESS_KEY=$(echo $response | awk '{print $3}')
AWS_SESSION_TOKEN=$(echo $response | awk '{print $4}')
EXPIRATION=$(echo $response | awk '{print $2}')

eval "aws configure --profile beiartf set aws_access_key_id ${AWS_ACCESS_KEY_ID}"
eval "aws configure --profile beiartf set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}"
eval "aws configure --profile beiartf set aws_session_token ${AWS_SESSION_TOKEN}"

# login to codeartifact
CODEARTIFACT_AUTH_TOKEN=$(aws --region ap-southeast-1 --profile beiartf codeartifact get-authorization-token --domain org-codeartifact-domain-015110552125-242c507c3f --domain-owner 015110552125 --query authorizationToken --output text)

# insert / update codeartifact token in the machine's gradle.properties
touch ~/.gradle/gradle.properties
grep -q "^external_cache_codeartifact_token" ~/.gradle/gradle.properties && sed -i "s/^external_cache_codeartifact_token.*/external_cache_codeartifact_token=$CODEARTIFACT_AUTH_TOKEN/" ~/.gradle/gradle.properties || echo "external_cache_codeartifact_token=$CODEARTIFACT_AUTH_TOKEN" >> ~/.gradle/gradle.properties
