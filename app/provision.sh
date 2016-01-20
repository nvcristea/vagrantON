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

function setSugarBashAlias(){
    cd /home/vagrant
    echo "alias helper='bash /home/vagrant/git-repo/sugarBash/helper.sh'" >> ./.bashrc
}

function resetDeployer() {

    npm install -g grunt-cli grunt bower
    cd /var/www/html/deployer/
    git init
    git remote add origin git@github.com:svnvcristea/stack-deployer.git
    git remote add upstream git@github.com:sugarcrm/stack-deployer.git
    git fetch
    git checkout -b develop
    git checkout develop
    git reset --hard origin/develop
    bower install
    npm install
    npm install grunt-cli grunt
    chown vagrant:vagrant -R ./
    configDeployer $@
}

function configDeployer() {

    if [ $3 == "true" ]; then
        cat > _config.json <<EOL
{
  "host":  "localhost",
  "vagrant": {
    "host": "localhost",
    "port": 2222,
    "username": "vagrant"
  },
  "port": {
    "socket_io": "8333",
    "node_app": "8334",
    "web_app": "8080"
  }
}

EOL
    else
        cat > _config.json <<EOL
{
  "host":  "${2}",
  "vagrant": {
    "host": "${2}",
    "port": 22,
    "username": "vagrant"
  },
  "port": {
    "socket_io": "3333",
    "node_app": "3334",
    "web_app": "80"
  }
}

EOL
    fi
    grunt init
}

function getElasticsearchHQ() {
    cd /usr/share/elasticsearch/plugins
    wget https://github.com/royrusso/elasticsearch-HQ/archive/master.zip
    unzip master
    mv elasticsearch-HQ-master HQ
    rm master
}

echo "Stack provision: ${1}"
installTools
nfsExports
setSugarBashAlias
resetDeployer $@
getElasticsearchHQ
statuses $1 $2
