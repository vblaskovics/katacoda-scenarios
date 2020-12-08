# Log into the Solt container
We want to do everything in this container from now on. This is our SaltStack control node.

`docker exec -it --user centos salt /bin/bash`{{execute}}

# Setup Salt server in container salt

## add saltstack apt source
We need to first trust the GPG key of the Saltstack apt source.

`wget -O - https://repo.saltstack.com/py3/ubuntu/20.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -`{{execute}}

Edit your apt sources and add SaltStack package source

`sudo nano /etc/apt/sources.list.d/saltstack.list`{{execute}}

Add the following line:

```
deb http://repo.saltstack.com/py3/ubuntu/20.04/amd64/latest focal main
```

Type `ctrl+x` then `Y` and enter to save and quit the editor

`sudo apt update`{{execute}}

## Install Salt Server
`sudo apt-get install -y salt-master`{{execute}}

## Install Salt Minion
`sudo apt-get install -y salt-minion`{{execute}}

## Install SSH package
`sudo apt-get install -y salt-ssh`{{execute}}

## Configure the salt container to manage itself via salt minion

First we need to make sure that only one entry is present in the /etc/hosts file for the salt hostname

`sudo nano /etc/host`{{execute}}

```
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
# 172.18.0.2    salt
172.19.0.2      salt
```
Now we need to start the salt server in daemon mode:

`sudo salt-server -d`{{execute}}

Now we can start the salt minion in daemon mode:
`sudo salt-minon -d`{{execute}}

Salt server needs to approve the minion's key in order to start the communication

`sudo salt-key -A`{{execute}}

## Test your salt setup

`sudo salt '*' test.version`{{execute}}

`sudo salt '*' disk.usage`{{execute}}

`sudo salt '*' sys.doc`{{execute}}

`sudo salt '*' cmd.run 'ls -l /etc'`{{execute}}

`sudo salt '*' pkg.install vim`{{execute}}

`sudo salt '*' network.interfaces`{{execute}}

`sudo salt myminion grains.item pythonpath --out=pprint`{{execute}}

## Do the same bootstrapping procedure for target1 and target2

`exit`{{execute}}

`docker exec -it --user centos target1 /bin/bash`{{execute}}

...

`exit`{{execute}}

`docker exec -it --user centos target1 /bin/bash`{{execute}}

...

`exit`{{execute}}

`docker exec -it --user centos salt /bin/bash`{{execute}}


`sudo salt '*' test.version`{{execute}}

`sudo salt '*' disk.usage`{{execute}}

`sudo salt '*' sys.doc`{{execute}}

`sudo salt '*' cmd.run 'ls -l /etc'`{{execute}}

`sudo salt '*' pkg.install vim`{{execute}}

`sudo salt '*' network.interfaces`{{execute}}

`sudo salt myminion grains.item pythonpath --out=pprint`{{execute}}

## Grains

Salt uses a system called Grains to build up static data about minions. This data includes information about the operating system that is running, CPU architecture and much more. The grains system is used throughout Salt to deliver platform data to many components and to users.

Grains can also be statically set, this makes it easy to assign values to minions for grouping and managing.

A common practice is to assign grains to minions to specify what the role or roles a minion might be. These static grains can be set in the minion configuration file or via the grains.setval function.

## Targetting

Salt allows for minions to be targeted based on a wide range of criteria. The default targeting system uses globular expressions to match minions, hence if there are minions named larry1, larry2, curly1, and curly2, a glob of larry* will match larry1 and larry2, and a glob of *1 will match larry1 and curly1.

Many other targeting systems can be used other than globs, these systems include:

Regular Expressions
Target using PCRE-compliant regular expressions

Grains
Target based on grains data: Targeting with Grains

Pillar
Target based on pillar data: Targeting with Pillar

IP
Target based on IP address/subnet/range

Compound
Create logic to target based on multiple targets: Targeting with Compound

Nodegroup
Target with nodegroups: Targeting with Nodegroup

The concepts of targets are used on the command line with Salt, but also function in many other areas as well, including the state system and the systems used for ACLs and user permissions.

## Passing in arguments
Many of the functions available accept arguments which can be passed in on the command line:

`sudo salt '*' pkg.install vim`{{execute}}

This example passes the argument vim to the pkg.install function. Since many functions can accept more complex input than just a string, the arguments are parsed through YAML, allowing for more complex data to be sent on the command line:

`sudo salt '*' test.echo 'foo: bar'`{{execute}}

In this case Salt translates the string 'foo: bar' into the dictionary "{'foo': 'bar'}"

## Salt States

Now that the basics are covered the time has come to evaluate States. Salt States, or the State System is the component of Salt made for configuration management.

The state system is already available with a basic Salt setup, no additional configuration is required. States can be set up immediately.

### SLS Formulas

The state system is built on SLS (SaLt State) formulas. These formulas are built out in files on Salt's file server. To make a very basic SLS formula open up a file under /srv/salt named vim.sls. The following state ensures that vim is installed on a system to which that state has been applied.

`sudo nano /srv/salt/vim.sls`{{execute}}

```yaml
vim:
  pkg.installed
```

Now install vim on the minions by calling the SLS directly:

`sudo salt '*' state.apply vim`{{execute}}

This command will invoke the state system and run the vim SLS.

Now, to beef up the vim SLS formula, a vimrc can be added:

`sudo nano /srv/salt/vim.sls`{{execute}}

```yaml
vim:
  pkg.installed: []

/etc/vimrc:
  file.managed:
    - source: salt://vimrc
    - mode: 644
    - user: root
    - group: root
```

Now the desired vimrc needs to be copied into the Salt file server to /srv/salt/vimrc. In Salt, everything is a file, so no path redirection needs to be accounted for. The vimrc file is placed right next to the vim.sls file. The same command as above can be executed to all the vim SLS formulas and now include managing the file.

`sudo salt '*' state.apply vim`{{execute}}

### Deploy nginx

/srv/salt/nginx/init.sls:

`sudo nano /srv/salt/nginx/init.sls`{{execute}}

```yaml
nginx:
  pkg.installed: []
  service.running:
    - require:
      - pkg: nginx
```
This new sls formula has a special name -- init.sls. When an SLS formula is named init.sls it inherits the name of the directory path that contains it. This formula can be referenced via the following command:

`salt '*' state.apply nginx`{{execute}}