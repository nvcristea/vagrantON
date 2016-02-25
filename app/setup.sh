#!/usr/bin/env bash

error()
{
    echo -e "\033[1;31m${1}\033[0m" 1>&2
    draw _ ${#1} red
    exit 1
}

askToProceed()
{
    echo -e "\033[93m"; read -e -p "Proceed $1 ? (y/n): " -i "y" OPT ; echo -e "\033[0m"
    if [ ${OPT} != "y" ] && [ -z ${2} ]; then
        error 'Proceeding abort!'
    fi
}

getStacks()
{
    curl https://api.github.com/repos/sugarcrm/stacks/tarball/master -s -L -u ${GIT_USER}:${GIT_PASS} > stacks/stacks.tar.gz
    tar -xzf stacks/stacks.tar.gz -C stacks --strip 1
    rm stacks/stacks.tar.gz
}

gitAccess()
{
    echo -e "\033[93m"; read -e -p "Git username: " GIT_USER
    echo -e "\033[93m"; read -s -e -p "Git password: " GIT_PASS ; echo -e "\033[0m"
}

config()
{
    if [ ! -f config/_private.yml ]; then
        cp config/_private.yml.dist config/_private.yml
    fi
    askToProceed "edit config/_private.yml" true
    if [[ ${OPT} == "y" ]]; then
        nano config/_private.yml
    fi
}

setup()
{
    gitAccess
    mkdir stacks
    getStacks
    config
}

update()
{
    gitAccess
    rm -rf stacks/*
    getStacks
}

if [[ ${1} == "update" ]]; then
    update
else
    setup
fi