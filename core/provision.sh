#!/usr/bin/env bash

function installTools() {
    sudo yum -y install htop iotop nano
}

function getSugarBash() {
    git clone git@github.com:svnvcristea/sugarBash.git /home/vagrant/git-repo/sugarBash
    cd /home/vagrant/git-repo/sugarBash
    cp config.def.yml config.yml
    echo "alias helper='bash /home/vagrant/git-repo/sugarBash/helper.sh'" >> ./.bashrc
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

function resetDeployer() {

    sudo npm install -g grunt-cli grunt bower
    cd /var/www/html/deployer/
    git init
    git remote add origin git@github.com:svnvcristea/stack-deployer.git
    git remote add upstream git@github.com:sugarcrm/stack-deployer.git
    git fetch
    git checkout -b develop
    git reset --hard origin/develop
    bower install
    sudo npm install
    npm install grunt-cli grunt
    sudo service deployer restart
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
getSugarBash
resetDeployer
statuses $1 $2