# Ad-Hoc commands and modules
---
Here you will learn about the key elements of Ansible, `Module`, and the` Ad-hoc command` to execute modules.

![structure.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/structure.png)

## What is a module?
---
A module is a "part of a common operation in infrastructure work". Ansible has about 3000 built-in modules as standard. It's not an exact expression, but it could be called a "library collection for infrastructure work."

Modules are provided to simplify the description of automation. As an example, let's take a look at the `yum` module provided by Ansible.

This `yum` module is a module that manages packages for the OS. You can install or remove packages by passing parameters to this module. Now consider writing a shell script that does the same thing.

The simplest implementation is as follows.
```bash
function yum_install () {
    PKG=$1
    yum install -y ${PKG}
}
```
> Note: The script content is meant to explain the behavior and is not accurate

This script is not enough to actually use it. For example, you should consider the case where the package you are trying to install is already installed. Then it should look like this:

```bash
function yum_install () {
    PKG=$1
    if [ Does this package already exist? ]; then
        exit 0
    else
        yum install -y ${PKG}
    fi
}
```

> Note: The script content is meant to explain the behavior and is not accurate

However, this is still not enough. What if a package is already installed and the version of the package is older, the same, or newer than the one you are about to install? Let's extend the script to take this case into account.


```bash
function yum_install () {
    PKG=$1
    VERSION=$2
    if [ Does this package already exist? ]; then
        case ${VERSION} in
            lower ) yum install -y ${PKG} ;;
            same ) exit 0
            higher ) exit 0
    else
        yum install -y ${PKG}
    fi
}
```

> Note: The script content is meant to explain the behavior and is not accurate

In this way, even with the simple operation of installing a package, various considerations arise when trying to implement it from scratch, and it is necessary to implement it to deal with it.

Therefore, Ansible's modules have these considerations built in in advance, allowing users to take advantage of automation without implementing fine-grained controls. In other words, the amount of automation description can be significantly reduced.

## List of modules
---
You can check the list of modules that Ansible has from the following [Official Documents] (https://docs.ansible.com/ansible/latest/modules/modules_by_category.html).

Alternatively, in an environment where Ansible is installed, you can also refer to it with the command `ansible-doc`.

To see the list of installed modules, run the following command.

`ansible-doc -l`{{execute}}

> Note: Enter with space, return with b, end with q.

To see the documentation for a particular module, do the following:

`ansible-doc yum`{{execute}}

```bash
> YUM    (/usr/local/lib/python3.6/site-packages/ansible/modules/packaging/os/yum.py)

        Installs, upgrade, downgrades, removes, and lists packages and
        groups with the `yum' package manager. This module only works
        on Python 2. If you require Python 3 support see the [dnf]
        module.

  * This module is maintained by The Ansible Core Team
  * note: This module has a corresponding action plugin.
```

In the module documentation, you can find a description of the parameters given to the module, the return value after the module is executed, and a sample of how to actually use it.

> Note: The sample usage of the module is very helpful.

## Ad-hoc command
---
You can call one of the modules mentioned above to get Ansible to do a small task. This method is called the `Ad-hoc command`.

The command format is as follows.

```bash
$ ansible all -m <module_name> -a '<parameters>'
```

* `-m <module_name>`: Specify the module name.
* `-a <parameters>`: Specifies the parameters to pass to the module. It may be optional.

Let's use the Ad-hoc command to actually get some modules working.

### ping
---
[`ping`](https://docs.ansible.com/ansible/latest/modules/ping_module.html) Let's run the module. This is a module that determines whether Ansible can "communicate as Ansible" to the node to be operated. The parameters are optional.

`ansible all -m ping`{{execute}}

```bash
node-1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
node-2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
node-3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
```

### shell
---
Next, let's call the [`shell`] (https://docs.ansible.com/ansible/latest/modules/shell_module.html) module. This is a command that executes an arbitrary command on the target node and collects the result.

`ansible all -m shell -a 'hostname'`{{execute}}

```bash
node-1 | CHANGED | rc=0 >>
ip-10-0-0-92.ap-northeast-1.compute.internal

node-3 | CHANGED | rc=0 >>
ip-10-0-0-204.ap-northeast-1.compute.internal

node-2 | CHANGED | rc=0 >>
ip-10-0-0-218.ap-northeast-1.compute.internal
```

Run some other commands and see the results.

`ansible all -m shell -a 'uname -a'`{{execute}}

`ansible all -m shell -a 'date'`{{execute}}

`ansible all -m shell -a 'df -h'`{{execute}}

`ansible all -m shell -a 'rpm -qa | grep bash'`{{execute}}


### yum
---
[`yum`](https://docs.ansible.com/ansible/latest/modules/yum_module.html) is a module that operates packages. Try installing a new package using this module.

This time install the screen package. First, make sure screen is not installed in your environment.

`ansible all -m shell -a 'which screen'`{{execute}}

This command should give an error because screen does not exist.

Now let's install screen with the yum module.

`ansible all -b -m yum -a 'name=screen state=latest'`{{execute}}

* `-b`: become option. This is an option to use root privileges to operate on the node you are connecting to. This option is included because installing the package requires root privileges. If not, this command will fail.

If you check the screen command again, it should succeed because the package was installed this time.

`ansible all -m shell -a 'which screen'`{{execute}}

### setup
---
[`setup`](https://docs.ansible.com/ansible/latest/modules/setup_module.html) is a module to get the information of the target node. The retrieved information will be automatically accessible with the variable name `ansible_xxx`.

Since the amount of information output is large, execute it on only one node.

`ansible node-1 -m setup`{{execute}}

In this way, Ansible has various modules, which can be used to operate on nodes and collect information.
