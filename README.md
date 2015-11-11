# SugarCRM vagrantON Stacks

SugarCRM vagrantON Stacks it's built on top and dependent by SugarCRM Engineering Stacks.
It's main advantage is that allow developers to start and configure any stack from the same folder while keeping them custom configurations on them local environment. 
Also support simultaneous running of multiple stacks and can control them directly from CLI (ex: `vagrant up php55`) 

## Install 

### Easy steps

```bash
   git clone git@github.com:svnvcristea/vagrantON.git
   cd vagrantON
   git submodule init
   git submodule update
   cp _examples/config.yml ./
   nano config.yml
   vagrant up php55
```

After cloning the repo you can also copy _examples/config.yml on it's parent and change them accordingly with your needs.

## Configure vagrantON

It's very easy con configure it by changing values in the config.yml

Supported Stacks are on the list 
```yaml
stacks: [db2, mts, oracle, oracle12c, php54, php55, php56, phpenv, qa-php53, qa-php54, ubuntu-driver]
```
So ACTIVE_STACK = 3 will start the 'oracle12c' stack by default. 
In case you will send the name of the stack from cli, the ACTIVE_STACK will be overwritten with the stack sent.
So `vagrant up php55` will start the 'php55' stack.

If you will start without your own config.yml in place the default stack will be used:

```yaml
DEFAULT_STACK:
  cpus: 2
  ssd: false
  memory: 2048
  video_memory: 8
  forward_agent: false
  forward_port: false
  forwarded_port:
    80: 8080
    3333: 8333
    3334: 8334
    9200: 8920
    9000: 9900
    9191: 9191
    1521: 1521
  puppet:
    options: "--verbose"
  share:
    -
     source: "~/www"
     target: "/var/www"
```


## Starting 1st Stack

When you want to start the box, just type `vagrant up` from this directory in a terminal window, it will load the base box into VirtualBox and boot it.  Once it's booted, it will run the provision scripts, downloading everything that is needed for it to run.

Once the box has been provisioned, you can access it by typing in `vagrant ssh` from the same terminal window.  It will log you in as the vagrant user, which has unrestricted sudo access.

Detail about the box can be found in the main [README](../../../../sugarcrm/stacks/blob/master/README.md) file for the stacks as to what is installed and how it configured.

## Starting Additional Stack

In order to start an additional VM stack just change the value of ACTIVE_STACK from your conf.yml and `vagrant up`
