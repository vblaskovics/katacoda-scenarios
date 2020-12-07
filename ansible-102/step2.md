#Variable
---
You can increase the versatility of your playbook by using variables. Here you will learn how to use various variables.

## Variable basics
---
Variables in Ansible have the following characteristics.

* No type
* All global variables (no scope)
* Can be defined / overwritten in various places

Since all are global variables and can be defined and overwritten in various ways, it will be more convenient if you devise a usage policy within the team such as naming conventions.

Where variables can be defined and what their priorities are in the [Official Documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable).

In this exercise, we will look at how to use typical variables.

## debug module
---
The [`debug`](https://docs.ansible.com/ansible/latest/modules/debug_module.html) module is useful for checking the contents of defined variables.

Edit `~/working/vars_debug_playbook.yml` as follows.
```yaml
---
- hosts: node-1
  gather_facts: no
  tasks:
    - name: print all variables
      debug:
        var: vars

    - name: get one variable
      debug:
        msg: "This value is {{ vars.ansible_version.full }}"
```

* `gather_facts: no` Ansible by default runs the` setup` module before executing a task to collect information about the node to be operated on and set it in a variable. You can skip information gathering by setting this variable to `no`. This is to reduce the amount of output of the variable list and make it easier to proceed with the exercise (the setup module collects a huge amount of information).
* `debug:`
  * `var: vars` The var option displays the contents of the variable given as an argument. Here, a variable called `vars` is given as an argument. `vars` is a special variable that contains all the variables.
  * `msg: "This value is {{vars.ansible_version.full}}" `The msg option outputs any string. In this, the part enclosed by `{{}}` is expanded as a variable.
    * The dictionary data in the variable is retrieved in the form of `.keyname`.
    * The list data in the variable is retrieved in the form `[index_number]`.

Run `vars_debug_playbook.yml`.

`cd ~/working`{{execute}}

`ansible-playbook vars_debug_playbook.yml`{{execute}}

```bash
PLAY [node-1] ****************************************

TASK [print all variables] ***************************
ok: [node-1] => {
    "vars": {
        (abridgement)
        "ansible_ssh_private_key_file": "/jupyter/aitac-automation-keypair.pem",
        "ansible_user": "centos",
        "ansible_verbosity": 0,
        "ansible_version": {
            "full": "2.9.0",
            "major": 2,
            "minor": 9,
            "revision": 0,
            "string": "2.9.0"
        },
        (abridgement)

TASK [get one variable] ******************************
ok: [node-1] => {
    "msg": "This value is 2.9.0"
}
(abridgement)
```

The contents of `vars` are the [magic variables](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html) defined by Ansible by default.


## Variable definition in playbook
---
Now let's actually define the variables.

Edit `~/working/vars_play_playbook.yml` as follows.
```yaml
---
- hosts: node-1
  gather_facts: no
  vars:
    play_vars:
      - order: 1st word
        value: ansible
      - order: 2nd word
        value: is
      - order: 3rd word
        value: fine
  tasks:
    - name: print play_vars
      debug:
        var: play_vars

    - name: access to the array
      debug:
        msg: "{{ play_vars[1].order }}"

    - name: join variables
      debug:
        msg: "{{ play_vars[0].value}} {{ play_vars[1].value }} {{ play_vars[2].value }}"
```


* If you write a `vars:` section in the `vars:` play part, you can define variables under it.
  * `play_vars: `variable name. It can be set freely.
    * This variable creates a list with three elements as values, and each one creates dictionary data with the key `order` `value`.
  * `msg: "{{play_vars [1] .order}}"` Retrieving the values in the list.
  * `msg: "{{play_vars [0] .value}} {{play_vars [1] .value}} {{play_vars [2] .value}}"` Combine the values of multiple variables, as in this example. It is also possible to use it.

Run `vars_play_playbook.yml`.

`cd ~ / working`{{execute}}

`ansible-playbook vars_play_playbook.yml`{{execute}}
`cd ~/working`{{execute}}

`ansible-playbook vars_play_playbook.yml`{{execute}}

```bash
(abridgement)
TASK [print play_vars] **************
ok: [node-1] => {
    "play_vars": [
        {
            "order": "1st word",
            "value": "ansible"
        },
        {
            "order": "2nd word",
            "value": "is"
        },
        {
            "order": "3rd word",
            "value": "fine"
        }
    ]
}

TASK [access to the array] **********
ok: [node-1] => {
    "msg": "2nd word"
}

TASK [join variables] ***************
ok: [node-1] => {
    "msg": "ansible is fine"
}
(abridgement)
```

Run `vars_play_playbook.yml` 

`cd ~/working`{{execute}}

`ansible-playbook vars_play_playbook.yml`{{execute}}

```bash
(abridgement)
TASK [print play_vars] **************
ok: [node-1] => {
    "play_vars": [
        {
            "order": "1st word",
            "value": "ansible"
        },
        {
            "order": "2nd word",
            "value": "is"
        },
        {
            "order": "3rd word",
            "value": "fine"
        }
    ]
}

TASK [access to the array] **********
ok: [node-1] => {
    "msg": "2nd word"
}

TASK [join variables] ***************
ok: [node-1] => {
    "msg": "ansible is fine"
}
(abridgement)
```

Variable definition in ## task
---
It is possible to define variables that are used only within one task, and to temporarily overwrite them.

Edit `~/working/vars_task_playbook.yml` as follows.
```yaml
---
- hosts: node-1
  gather_facts: no
  vars:
    task_vars: 100
  tasks:
    - name: print task_vars 1
      debug:
        var: task_vars

    - name: override task_vars
      debug:
        var: task_vars
      vars:
        task_vars: 20

    - name: print task_vars 2
      debug:
        var: task_vars
```

Run `vars_task_playbook.yml`.

`ansible-playbook vars_task_playbook.yml` {{execute}}

```bash
(abridgement)
TASK [print task_vars 1] ************
ok: [node-1] => {
    "task_vars": 100
}

TASK [override task_vars] ***********
ok: [node-1] => {
    "task_vars": 20
}

TASK [print task_vars 2] ************
ok: [node-1] => {
    "task_vars": 100
}
```

`Vars:` in a task is only within that task [Variable Priority](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable) is higher than `play vars`, so the result is as above.

Now let's see what happens when we use the higher priority `extra_vars` (variable specified from the command line).

To give `extra_vars`, run` vars_task_playbook.yml` with the `-e` option.

`ansible-playbook vars_task_playbook.yml -e 'task_vars=50'`{{execute}}

```bash
(abridgement)
TASK [print task_vars 1] ************
ok: [node-1] => {
    "task_vars": "50"
}

TASK [override task_vars] ***********
ok: [node-1] => {
    "task_vars": "50"
}

TASK [print task_vars 2] ************
ok: [node-1] => {
    "task_vars": "50"
}
```

The highest priority value of `extra_vars` is used for all tasks. As you can see, in Ansible, the priority differs depending on where the variable is defined, so be careful.

## Other variable definitions
---
Introducing how to define other variables.


### Definition in set_fact
---
You can use the [set_fact](https://docs.ansible.com/ansible/latest/modules/set_fact_module.html) module to define any variable in your task part. 
A common use is to receive the execution result of one task, process its value to define a new variable, and use that value in subsequent tasks.

Exercises using `set_fact` will appear in the next part.


### Definition in host\_vars, group\_vars
---
It is a variable explained in the item of inventory. You can define variables that are associated with a particular group or host. In addition to listing in the inventory file, create a `gourp_vars` `host_vars` directory in the same directory as the playbook you want to run, and create `<group_name>.yml`, `<node_name>.yml` files there. By doing so, it can be recognized as a group or host variable.

> Note: This directory name `gourp_vars` `host_vars` cannot be changed with a fixed name within Ansible.

It actually defines some host and group variables.

### `~/working/group_vars/all.yml`

Define a group variable.
`` `yaml
---
vars_by_group_vars: 1000
`` ```

### `~ / working / host_vars / node-1.yml`

Define the host variable.
```yaml
---
vars_by_host_vars: 111
```

### `~ / working / host_vars / node-2.yml`

Define the host variable.
```yaml
---
vars_by_host_vars: 222
```

### `~ / working / host_vars / node-3.yml`

Define the host variable.
```yaml
---
vars_by_host_vars: 333
```

### `~ / working / vars_host_group_playbook.yml`

Create a playbook that takes advantage of these variables.
```yaml
---
- hosts: all
  gather_facts: no
  tasks:
    - name: print group_vars
      debug:
        var: vars_by_group_vars

    - name: print host vars
      debug:
        var: vars_by_host_vars

    - name: vars_by_group_vars + vars_by_host_vars
      set_fact:
        cal_result: "{{ vars_by_group_vars + vars_by_host_vars }}"

    - name: print cal_vars
      debug:
        var: cal_result
```

When you're ready, run `vars_host_group_playbook.yml`.

`ansible-playbook vars_host_group_playbook.yml`{{execute}}

```bash
(abridgement)
TASK [print group_vars] ******************************
ok: [node-1] => {
    "vars_by_group_vars": 1000
}
ok: [node-2] => {
    "vars_by_group_vars": 1000
}
ok: [node-3] => {
    "vars_by_group_vars": 1000
}

TASK [print host vars] *******************************
ok: [node-1] => {
    "vars_by_host_vars": 111
}
ok: [node-2] => {
    "vars_by_host_vars": 222
}
ok: [node-3] => {
    "vars_by_host_vars": 333
}

TASK [vars_by_group_vars + vars_by_host_vars] ********
ok: [node-1]
ok: [node-2]
ok: [node-3]

TASK [print cal_vars] ********************************
ok: [node-1] => {
    "cal_result": "1111"
}
ok: [node-2] => {
    "cal_result": "1222"
}
ok: [node-3] => {
    "cal_result": "1333"
}
(abridgement)
```


In this way, it is possible to have different values ​​for each group or host with the same variable.


### Saving execution results by register
---
Ansible modules return various return values ​​when executed. You can save this return value in the playbook and use it in subsequent tasks. The `register` clause is used in that case. If you specify a variable name in `register`, the return value is stored in that variable.

Edit `~/working/vars_register_playbook.yml` as follows.
```yaml
---
- hosts: node-1
  gather_facts: no
  tasks:
    - name: exec hostname command
      shell: hostname
      register: ret

    - name: print ret
      debug:
        var: ret

    - name: create a directory
      file:
        path: /tmp/testdir
        state: directory
        mode: '0755'
      register: ret

    - name: print ret
      debug:
        var: ret
```

Run `vars_register_playbook.yml`.

`ansible-playbook vars_register_playbook.yml`{{execute}}

```bash
(abridgement)
TASK [exec hostname command] *************************
changed: [node-1]

TASK [print ret] *************************************
ok: [node-1] => {
    "ret": {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python"
        },
        "changed": true,
        "cmd": "hostname",
        "delta": "0:00:00.005958",
        "end": "2019-11-17 14:02:44.892010",
        "failed": false,
        "rc": 0,
        "start": "2019-11-17 14:02:44.886052",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "ip-10-0-0-92.ap-northeast-1.compute.internal",
        "stdout_lines": [
            "ip-10-0-0-92.ap-northeast-1.compute.internal"
        ]
    }
}

TASK [create a directory] ****************************
changed: [node-1]

TASK [print ret] *************************************
ok: [node-1] => {
    "ret": {
        "changed": true,
        "diff": {
            "after": {
                "mode": "0755",
                "path": "/tmp/testdir",
                "state": "directory"
            },
            "before": {
                "mode": "0775",
                "path": "/tmp/testdir",
                "state": "absent"
            }
        },
        "failed": false,
        "gid": 1000,
        "group": "centos",
        "mode": "0755",
        "owner": "centos",
        "path": "/tmp/testdir",
        "secontext": "unconfined_u:object_r:user_tmp_t:s0",
        "size": 6,
        "state": "directory",
        "uid": 1000
    }
}
```

In this example, the result of executing the hostname command in the `shell` module is first stored in the variable` ret`, and the contents are displayed in the `debug` module immediately after. Then I use the [`file`](https://docs.ansible.com/ansible/latest/modules/file_module.html) module to create a directory and store its return value in` ret`. .. And also check the contents with the `debug` module.

You can see what the return value of each module returns in the module's documentation.


## Exercise answer
---
* [vars_debug_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/vars_debug_playbook.yml)
* [vars_play_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/vars_play_playbook.yml)
* [vars_task_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/vars_task_playbook.yml)
* [vars_host_group_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/vars_host_group_playbook.yml)
  * [host_vars/node-1.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/host_vars/node-1.yml)
  * [host_vars/node-2.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/host_vars/node-2.yml)
  * [host_vars/node-3.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/host_vars/node-3.yml)
  * [group_vars/all.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/group_vars/all.yml)
* [vars_register_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/vars_register_playbook.yml)
