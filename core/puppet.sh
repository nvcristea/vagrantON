#!/usr/bin/env bash

ping -c 1 $2 1>/dev/null 2>&1
if [ $? -ne 0 ]; then echo \"${1}  ${2}\" | sudo tee --append /etc/hosts > /dev/null; fi
mkdir -p /var/lib/puppet/ssl/certs;
mkdir -p /var/lib/puppet/ssl/private_keys;
cp /vagrant/puppet_ssl/certs/* /var/lib/puppet/ssl/certs;
cp /vagrant/puppet_ssl/private_keys/* /var/lib/puppet/ssl/private_keys