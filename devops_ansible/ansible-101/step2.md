# Ansible Basics, Inventory, Credentials
---
Learn about Ansible's basic inventory and credentials. This is two of the three minimum pieces of information you need to get Ansible running.

![structure.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/structure.png)

## Running Ansible in a practice environment
---
First, execute the following command. It uses Ansible to check the disk usage of the three exercise nodes.

`cd ~/`{{execute}}

`ansible all -m shell -a 'df -h'`{{execute}}

```bash
node-1 | CHANGED | rc=0 >>
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       10G  885M  9.2G   9% /
devtmpfs        473M     0  473M   0% /dev
tmpfs           495M     0  495M   0% /dev/shm
tmpfs           495M   13M  482M   3% /run
tmpfs           495M     0  495M   0% /sys/fs/cgroup
tmpfs            99M     0   99M   0% /run/user/1000

node-2 | CHANGED | rc=0 >>
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       10G  885M  9.2G   9% /
devtmpfs        473M     0  473M   0% /dev
tmpfs           495M     0  495M   0% /dev/shm
tmpfs           495M   13M  482M   3% /run
tmpfs           495M     0  495M   0% /sys/fs/cgroup
tmpfs            99M     0   99M   0% /run/user/1000

node-3 | CHANGED | rc=0 >>
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       10G  885M  9.2G   9% /
devtmpfs        473M     0  473M   0% /dev
tmpfs           495M     0  495M   0% /dev/shm
tmpfs           495M   13M  482M   3% /run
tmpfs           495M     0  495M   0% /sys/fs/cgroup
tmpfs            99M     0   99M   0% /run/user/1000
```

> Note: Ignore the difference between the actual output content and the above output example. The important thing is that `df -h` was executed.

Now you can get the disk usage information from the 3 nodes. But how were these three nodes determined? Of course, this is pre-configured for exercises, but you may be wondering where that information is set in Ansible. I will check the settings from now on.

## ansible.cfg
---
First, execute the following command.

`ansible --version`{{execute}}

```bash
ansible 2.9.0
  config file = /jupyter/.ansible.cfg
  configured module search path = ['/jupyter/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.6/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 3.6.8 (default, Oct  7 2019, 17:58:22) [GCC 8.2.1 20180905 (Red Hat 8.2.1-3)]
```

> Note: The output content may vary depending on the environment.

If you add the `--version` option to the ansible command, basic information about the execution environment is output. The version and the version of Python you are using. Pay attention to the following lines here.

* `config file = /jupyter/.ansible.cfg`

It shows the path to the Ansible config file that is loaded when you run the ansible command in this directory. This file is a configuration file for controlling the basic behavior of Ansible.

I used the phrase "when run in this directory", but Ansible has a fixed order to search ansible.cfg. Details can be found in [Ansible Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#the-configuration-file).

Simply put, ansible.cfg is searched in the order given by the environment variables, the current directory, the home directory, and the common path for the entire OS, this time the home directory `~/.ansible.cfg` is the first. This file is being used to find it.

Let's check this content.

`cat ~/.ansible.cfg`{{execute}}

```bash
[defaults]
inventory = inventory
host_key_checking = False
force_color = True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
```

Some settings are set up for exercises. The following settings are important here.

* `inventory = inventory`

This is the "inventory" setting that Ansible decides where to perform the automation.

Let's take a closer look at this setting below.

## Inventory
---
Inventory is a feature that allows Ansible to determine where to perform automation. Let's check the contents of the file. In the config file, `inventory = inventory` is a bit confusing, but this means that the file` inventory` is specified with a relative path from ansible.cfg.

Let's check the contents of this file.


`cat ~/inventory`{{execute}}

```bash
[web]
node-1 ansible_host=3.114.16.114
node-2 ansible_host=3.114.209.178
node-3 ansible_host=52.195.15.8

[all: vars]
ansible_user=centos
ansible_ssh_private_key_file=/jupyter/aitac-automation-keypair.pem
```

This inventory is written in the `ini` file format. There is also support for the `YAML` format and the` dynamic inventory` mechanism, which dynamically configures inventory with scripts. See [How to build your inventory] (https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html) for more information.

This inventory file is described by the following rules.

* Write information in one node per line, such as `node-1` `node-2`.
  * The node line consists of `node identifier (node-1)` and `host variable (s) given to the node (ansible_host = xxxx)`.
  * You can also specify the IP address or FQDN in the `node-1` part.
* You can create a group of hosts with `[web]`. Here, a group called `web` is created.
  * You can use any group name other than `all` and `localhost`.
    * Example: `[web]` `[ap]` `[db]` is used for the purpose of grouping systems.
* `[all: vars]` defines a `group variable` for the group` all`.
  * `all` is a special group that points to all the nodes listed in the inventory.
  * The `ansible_user` `ansible_ssh_private_key_file` given here is a special variable that indicates the username and SSH private key path used to log in to each node.
    * You can control the behavior of Ansible with [magic variable](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html) called `ansible_xxxx`, environment information that Ansible automatically acquires, etc. Contains special values. Details will be explained in the variable section.

Let's actually run Ansible on the defined nodes using this inventory. Execute the following command.

`ansible web -i ~/inventory -m ping -o`{{execute}}

```bash
node-3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
node-2 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
```

The options for this command have the following meanings:

* `web`: Specifying a group in the inventory.
* `-i ~/inventory`: Specify the inventory file to use.
* `-m ping`: Execute the module `ping`. Details about the module will be described later.
* `-o`: Combine the output into one node and one line.

In this environment, the `ansible.cfg` file specifies the default inventory, so you can omit` -i ~/inventory` as shown below.

`ansible web -m ping -o`{{execute}}

```bash
node-3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
node-2 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
```

> Note: In the following exercises, we will omit specifying the inventory as described above.

You can also specify the node name instead of the group name, as shown below.

`ansible node-1 -m ping -o`{{execute}}

```bash
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
```

It is also possible to specify multiple nodes.

`ansible node-1,node-3 -m ping -o`{{execute}}

```bash
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
node-3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
```

Let's specify a special group, `all`. `all` covers all nodes in the inventory. In this inventory, the `all` and` web` groups point to the same thing, so the result is the same.

`ansible all -m ping -o`{{execute}}

```bash
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
node-2 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
node-3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "ping": "pong"}
```


## Authentication information
---
In the inventory check above, we ran the `ping` module on three nodes. This module actually logs in to the node and checks if Ansible is ready to run. Let's take a look at the Credentials used to log in at this time.

In this exercise environment, the credentials are specified in the inventory we saw earlier. The following is an excerpt.

```bash
[all: vars]
ansible_user = centos
ansible_ssh_private_key_file = /jupyter/aitac-automation-keypair.pem
```

Here, `[all: vars]` is defined as a variable for all groups, and the variable used for authentication is defined there.

* ` ansible_user`: Specify the user name that Ansible uses to log in.
* ` ansible_ssh_private_key_file`: Specify the private key that Ansible uses to log in.

Although the private key is used in this exercise, it is possible to specify a password for login.

* `ansible_password`: Specifies the password that Ansible uses to log in.

There are several other ways to give credentials. A typical method is to give it as a command line option.

`ansible all -u centos --private-key ~/aitac-automation-keypair.pem -m ping`{{execute}}

* `-u centos`: You can specify the user name to use for login.
* `-- private-key`: You can specify the private key to use for login.

You can also use a password. The following is a sample.

```bash
$ ansible all -u centos -k -m ping
SSH password: ← You will be prompted to enter the password here
node-1 | FAILED! => {
    "msg": "to use the'ssh' connection type with passwords, you must install the sshpass program"
}
node-2 | FAILED! => {
    "msg": "to use the'ssh' connection type with passwords, you must install the sshpass program"
}
node-3 | FAILED! => {
    "msg": "to use the'ssh' connection type with passwords, you must install the sshpass program"
}
```

> Note: The exercise environment does not allow password login, so this step will fail if you do.

* `-k`: Prompt for password when executing command.

There are several other ways to pass credentials to Ansible. This exercise uses the most basic method (directly specified by a variable), but when actually using it in production, it is necessary to carefully consider how to handle the authentication information.

In general, how to use it in combination with automation platform software such as [Ansible Tower](https://www.ansible.com/products/tower) and [AWX](https://github.com/ansible/awx) Is often adopted.
