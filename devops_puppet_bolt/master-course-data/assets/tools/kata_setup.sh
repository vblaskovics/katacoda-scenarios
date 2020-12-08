#!/bin/bash

wget https://apt.puppet.com/puppet-tools-release-bionic.deb
dpkg -i puppet-tools-release-bionic.deb
apt-get update && sudo apt-get install puppet-bolt python3 python3-pip

pip install ansible

ansible-playbook -i localhost, -c local kata_prepare.yml

ret=$?
if [ "$ret" == 0 ]; then
    echo "Exit! Let's proceed the next step !!"
else
    echo "Something wrong ... please try again X("
fi

# This is workaround for https://github.com/irixjp/katacoda-scenarios/issues/6.
cd ~/katacoda-scenarios/devops_saltstack/master-course-data/assets/
cp -a tools/kata_prepare.yml ~/
cp -a tools/.ansible.cfg ~/
cp -a working/ ~/working/
cd ~/
