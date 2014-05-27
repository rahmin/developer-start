#!/bin/bash

set -e

git clone git://github.com/ansible/ansible.git
source ./ansible/hacking/env-setup
sudo easy_install pip
sudo pip install paramiko PyYAML jinja2

ansible-playbook playbooks/packages.yaml -i hosts

# we're done!
echo "Done setting up your developer laptop! Now feel free to make it your own."
echo "We recommend restarting your machine at this point."
