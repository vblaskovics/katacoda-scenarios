# Loops, conditional expressions, handlers
---
Since the playbook is written in YAML format, it is basically a format for expressing work and parameters as "data". However, there are many cases where it is easier to describe the work by using expressions as programming. In this exercise, we will look at the "function as programming" of the playbook.

## loop
---
It is used when executing a specific task repeatedly. For example, take a look at a playbook that creates three OS users: `apple`, `orange`, and `pineapple`. To add a user, the [`user`](https://docs.ansible.com/ansible/latest/modules/user_module.html) module is available, so you can write a playbook like this:

```yaml
---
- name: add three users individually
  hosts: node-1
  become: yes
  tasks:
    - name: add apple user
      user:
        name: apple
        state: present

    - name: add orange user
      user:
        name: orange
        state: present

    - name: add pineapple user
      user:
        name: pipeapple
        state: present
```

This playbook works to add three users exactly as intended. However, this method is verbose because the same description has to be repeated many times. If the specifications of the `user` module change, the way parameters are given changes, or if you want the user you create later to have additional information, you will need to edit each task altogether.

The `loop` clause can be used for such iterations.

Edit `~/working/loop_playbook.yml` as follows.
```yaml
---
- name: add users by loop
  hosts: node-1
  become: yes
  vars:
    user_list:
      - apple
      - orange
      - pineapple
  tasks:
    - name: add a user
      user:
        name: "{{ item }}"
        state: present
      loop: "{{ user_list }}"
```


* The `vars:` variable `user_list` is defined to define a list with three elements: apple, orange and pineapple.
* `loop: "{{user_list}}" `If you add a loop clause to a task and give a list as a parameter, the task will be executed repeatedly for the number of elements.
* `name: "{{item}}" `The item variable is a variable that can be used only in the loop, and the extracted variable is stored here. That is, apple in the first loop and orange in the second loop.

Run `loop_playbook.yml`.

`cd ~/working`{{execute}}

`ansible-playbook loop_playbook.yml`{{execute}}

```bash
(省略)
TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [add a user] ************************************
changed: [node-1] => (item=apple)
changed: [node-1] => (item=orange)
changed: [node-1] => (item=pineapple)

(省略)
```

Let's see if the user was really added. If the playbook is written correctly, you should have created a user on node-1.

`ansible node-1 -b -m shell -a 'cat /etc/passwd'`{{execute}}

```bash
(省略)
apple:x:1001:1001::/home/apple:/bin/bash
orange:x:1002:1002::/home/orange:/bin/bash
pineapple:x:1003:1003::/home/pineapple:/bin/bash
```


Suppose you also want to add `mango`, `peach` users. In that case, how do you edit the playbook? Please actually edit the playbook and try again. If the execution result is as follows, it is described correctly. You should be able to confirm that idempotence is working.

`ansible-playbook loop_playbook.yml`{{execute}}

```bash
(省略)
TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [add a user] ************************************
ok: [node-1] => (item=apple)
ok: [node-1] => (item=orange)
ok: [node-1] => (item=pineapple)
changed: [node-1] => (item=mango)
changed: [node-1] => (item=peach)

(省略)
```

An example answer can be found at the end of this page.

> Note: In this exercise, the variable `user_list` is defined inside the playbook, but by having this in a file such as` group_vars`, "the process of adding a user" and "data of the user to be added" It becomes possible to manage separately.

I introduced the simplest loop here, but the loop method in various cases is introduced in the [Official Document] (https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html). .. Please use properly according to the situation.


## Conditional expression
---
Ansible conditional expressions are used to control whether or not a task is executed under specific conditions. Use the `when` clause to describe the condition. As a typical usage method, it is a case of controlling whether to execute the next task based on the execution result of one task.

Let's actually write the following `~/working/when_playbook.yml`
```yaml
---
- name: start httpd if it's stopped
  hosts: node-1
  become: yes
  tasks:
    - name: install httpd
      yum:
        name: httpd
        state: latest

    - name: check httpd processes is running
      shell: ps -ef |grep http[d]
      register: ret
      ignore_errors: yes
      changed_when: no

    - name: print return value
      debug:
        var: ret

    - name: start httpd (httpd is stopped)
      service:
        name: httpd
        state: started
      when:
        - ret.rc == 1
```

This playbook checks the startup status of the httpd process and starts it if the process does not exist.

> Note: Since idempotency actually works, this process has the same effect on the `service` part alone, so it doesn't make much sense, but think of it as a practice subject.

* `register: ret` Here we store the result of` ps -ef | grep http [d] `.
* `ignore_errors: yes` This option ignores errors that occur within the task. This command will result in an error if the process cannot be found, so the task will stop here without this option.
* `changed_when: no` Describes the conditions under which this task becomes` changed`. The `shell` module always returns` changed`, but specifying `no` for this option returns` ok`.
* `when:` The conditions are listed here. If multiple conditions are given in a list, it will be an AND condition.
  * `- ret.rc == 1` The value of` rc`, which is the return value of the shell module, is being compared. `rc` contains the command line return value. That is, if a process is "not found" with `ps -ef | grep http [d]`, an error will occur and `1` will be stored here.

Stop httpd before running the playbook (this can be an error, but ignore it)

`ansible node-1 -b -m shell -a 'systemctl stop httpd'`{{execute}}

Run `~/working/when_playbook.yml`.

`ansible-playbook when_playbook.yml`{{execute}}

```bash
TASK [check httpd processes is running] **************
fatal: [node-1]: FAILED! => {"changed": false, "cmd": "ps -ef |grep http[d]", "delta": "0:00:00.023918", "end": "2019-11-18 06:07:44.403881", "msg": "non-zero return code", "rc": 1, "start": "2019-11-18 06:07:44.379963", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
...ignoring

TASK [print return value] ****************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "cmd": "ps -ef |grep http[d]",
        "delta": "0:00:00.023918",
        "end": "2019-11-18 06:07:44.403881",
        "failed": true,
        "msg": "non-zero return code",
        "rc": 1,
        "start": "2019-11-18 06:07:44.379963",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "",
        "stdout_lines": []
    }
}

TASK [start httpd (httpd is stopped)] ****************
changed: [node-1]
```

Here, the httpd startup task is running because it meets the condition `ret.rc == 1`.

Now run `~/working/when_playbook.yml` again. This time httpd is running.

`ansible-playbook when_playbook.yml`{{execute}}

```bash
TASK [check httpd processes is running] **************
ok: [node-1]

TASK [print return value] ****************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "cmd": "ps -ef |grep http[d]",
        "delta": "0:00:00.018448",
        "end": "2019-11-18 06:08:30.779933",
        "failed": false,
        "rc": 0,
        "start": "2019-11-18 06:08:30.761485",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "root      4913     1  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4914  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4915  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4916  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4917  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4918  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
        "stdout_lines": [
            "root      4913     1  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4914  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4915  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4916  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4917  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4918  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND"
        ]
    }
}

TASK [start httpd (httpd is stopped)] ****************
skipping: [node-1]
```

In this execution, the value of `ret.rc` is `0`, so the condition is not met and it is `skipping`.

For details on how to describe conditions, see [Official Documents](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html) for more detailed explanations.

By using a conditional expression, it is possible to control the processing according to the situation. However, if you specify too complicated conditions, it will be difficult to debug and maintain. It is important to standardize the environment side so that conditional branching does not occur as much as possible.

## Handler
---
Handlers are similar to conditional expressions like the `when` clause, but they have more limited uses. Specifically, when a specific task becomes `changed`, another task is started. A typical use is when a configuration file is updated and the process is restarted as a set.

The exercise will create a playbook that distributes `httpd.conf` to the server and restarts` httpd` when the files are updated.

First, get the `httpd.conf` to distribute from the server.

`ansible node-1 -m fetch -a 'src=/etc/httpd/conf/httpd.conf dest=files/httpd.conf flat=yes'`{{execute}}

```bash
node-1 | CHANGED => {
    "changed": true,
    "checksum": "fdb1090d44c1980958ec96d3e2066b9a73bfda32",
    "dest": "/notebooks/solutions/files/httpd.conf",
    "md5sum": "f5e7449c0f17bc856e86011cb5d152ba",
    "remote_checksum": "fdb1090d44c1980958ec96d3e2066b9a73bfda32",
    "remote_md5sum": null
}
```

`ls -l files/`{{execute}}

```bash
total 16
-rw-r--r-- 1 jupyter jupyter 11753 Nov 18 07:40 httpd.conf
-rw-r--r-- 1 jupyter jupyter     2 Nov 17 14:35 index.html
```

* [`fetch`](https://docs.ansible.com/ansible/latest/modules/fetch_module.html) A module is a module that fetches files from a remote server locally (the reverse of the` copy` module).

Edit `~/working/handler_playbook.yml` as follows.
```yaml
---
- name: restart httpd if httpd.conf is changed
  hosts: node-1
  become: yes
  tasks:
    - name: Copy Apache configuration file
      copy:
        src: files/httpd.conf
        dest: /etc/httpd/conf/
      notify:
        - restart_apache
  handlers:
    - name: restart_apache
      service:
        name: httpd
        state: restarted
```

The handler consists of two parts, `notify` and `handler`.

* Declare to send `nofily` to the` notify: `handler and specify the code to actually send after that.
  * `- restart_apache` Specifies the code to send.
* ` handlers: `Declare a handler section and describe the processing corresponding to the code sent below this.
  `-name: restart_apache`: This task runs as a handler by defining a name that corresponds to` restart_apache` in `notify`.

Run `~/working/handler_playbook.yml`.

`ansible-playbook handler_playbook.yml` {{execute}}

`ansible-playbook handler_playbook.yml`{{execute}}

```bash
PLAY [restart httpd if httpd.conf is changed] ********

TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [Copy Apache configuration file] ****************
ok: [node-1]

PLAY RECAP *******************************************
node-1  : ok=2 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

In this state, all tasks are `ok`. This is because at this point, the httpd.conf obtained from the server is distributed to the server as it is. So `handler` doesn't work.

Now let's edit `files/httpd.conf` so that the copy is` changed`. Please edit as follows.
```
ServerAdmin root@localhost
      ↓
ServerAdmin centos@localhost
```

Run `~/working/handler_playbook.yml` again.

`ansible-playbook handler_playbook.yml`{{execute}}

```bash
PLAY [restart httpd if httpd.conf is changed] ********

TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [Copy Apache configuration file] ****************
changed: [node-1]

RUNNING HANDLER [restart_apache] *********************
changed: [node-1]

PLAY RECAP *******************************************
node-1 : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

The `copy` module is now` chaged` because we updated `httpd.conf`. Then the set `notify` is called and` restart_apache` is executed.

In this way, the handler is a method of executing another task triggered by the task `changed`.


## Exercise answer
---
* [loop_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/loop_playbook.yml)
* [when_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/when_playbook.yml)
* [handler_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/handler_playbook.yml)
