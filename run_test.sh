#!/bin/bash

# Remember to install python python-pip pywinrm
#
# If you are running Ubuntu 12 and have an older version of python pip then 
# uninstall it:
#   $ sudo apt-get remove python-pip
#   $ sudo apt-get autoremove
#   $ wget https://bootstrap.pypa.io/get-pip.py
#   $ sudo python ./get-pip.py


ansible-playbook test.yml -i ./HOSTS
