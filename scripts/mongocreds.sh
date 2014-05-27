#!/usr/bin/env bash

# get production mongodb credentials
read -t 0.1 -n 10000 discard # flush input from stdin
read -p "Please enter the AWS access key ID for mongolabs from our 1password vault: " -e -s AWS_ACCESS_KEY_ID
read -p "And what is the secret access key? " -e -s AWS_SECRET_ACCESS_KEY
cat <<EOF >> ~/.sekret
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

EOF
