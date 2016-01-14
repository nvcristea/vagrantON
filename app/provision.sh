#!/usr/bin/env bash

function installTools() {
    sudo yum -y install htop iotop nano
}

function pathExport() {
    sudo bash -c "echo '${1}   192.168.56.1/24(rw,no_subtree_check,all_squash,anonuid=500,anongid=500)' >> /etc/exports"
}

function nfsExports() {
    sudo chkconfig --add nfs
    sudo chkconfig nfs on
    pathExport '/var/www/html'
    pathExport '/home/vagrant'
    sudo service nfs start
    sudo exportfs -a
}

function statuses() {
    cat /etc/exports
    sudo chkconfig nfs --list
    echo "To mount on your host add to /etc/fstab"
    echo "${2}:/var/www/html             ~/mnt-${1}-html             nfs4  defaults 0 0"
    echo "http://${2}"
}

echo "Stack provision: ${1}"
installTools
nfsExports
statuses $1 $2
