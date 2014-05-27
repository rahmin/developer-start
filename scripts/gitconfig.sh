#!/usr/bin/env bash

# configure git
echo "Configuring git settings:"
gitusername=$(git config --global user.name)
gituseremail=$(git config --global user.email)
read -t 0.1 -n 10000 # flush input from stdin
read -p "What name should go on your commits? " -ei $gitusername gitusername
read -p "What is your git email address? " -ei $gituseremail gituseremail
git config --global push.default simple
git config --global user.name $gitusername
git config --global user.email $gituseremail
git config --global credential.helper osxkeychain
