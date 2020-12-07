# Playbook description and execution
---
In the previous exercise, you ran the modules one at a time, but when you actually work, you'll have to run a number of steps in a row. The one used at this time is `playbook`. The modules and parameters you want to call can be described in order in the playbook and executed continuously as a series of steps.

## Playbook basics
---
The `playbook` is written in [YAML](https://ja.wikipedia.org/wiki/YAML) format. Here are some important points about YAML:

* YAML is a text format for representing data.
* The beginning of the file starts with `---`
* Indentation has meaning
  * Indentation is written as `space`. `tab` will result in an error.
* `-` represents a list
* `key`: `value` is in dictionary format
* Can be converted to [json](https://ja.wikipedia.org/wiki/JavaScript_Object_Notation)

Below is a sample playbook.
```yaml
---
- hosts: all
  become: yes
  tasks:
  - name: first task
    yum:
      name: httpd
      state: latest
  - name: second task
    service:
      name: httpd
      state: started
      enabled: yes
```

This content is as follows when expressed in json.

```json
[
	{
		"hosts": "all",
		"become": "yes",
		"tasks": [
			{
				"name": "first task",
				"yum": {
					"name": "httpd",
					"state": "latest"
				}
			},
			{
				"name": "second task",
				"service": {
					"name": "httpd",
					"state": "started",
					"enabled": "yes"
				}
			}
		]
	}
]
```

## Creating a playbook
---
Now let's actually create a playbook.

Open `~ /working/first_playbook.yml` in an editor. This file contains only `---` at the beginning. Follow the instructions below to add to this file and complete it as a playbook.

Here, we will create a playbook that builds a web server.

### play part
---
Please add to the file as follows.

```yaml
---
- name: deploy httpd server
  hosts: all
  become: yes
```

The contents described here are as follows.
* `name: `: Here is an overview of what this playbook does. Optional. You can also use Japanese.
* `hosts: all`: Specifies the groups and nodes on which the playbook will be executed.
* `become: yes`: This playbook declares privilege escalation. It has the same meaning as `-b` given on the command line.

This part declares the overall behavior in a part of the playbook called the `play` part. Check the [Official document for details](https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html#play) of the items that can be specified in the play part.

### task part
---
Next, add the following. Pay attention to the indentation hierarchy.

```yaml
---
- name: deploy httpd server
  hosts: all
  become: yes
  tasks:
  - name: install httpd
    yum:
      name: httpd
      state: latest

  - name: start & enabled httpd
    service:
      name: httpd
      state: started
      enabled: yes
```

The content added here will be the part called the `task` part, and we will describe the processing actually performed by this playbook. The task part lists the modules in the order they are called and gives them the required parameters.

* `tasks:` Declares that the following is the task part.
* `- name: ...` Contains a description of this task. Optional
* ` yum:` `service:` Specifies the module to call.
* The following are the parameters given to the module.
  * `name: httpd` `state: latest`
  * `name: httpd` `state: started`` enabled: yes`

The module called here is as follows.
* [`yum`](https://docs.ansible.com/ansible/latest/modules/yum_module.html): Used to install the httpd package.
* [`service`](https://docs.ansible.com/ansible/latest/modules/service_module.html): Starts the installed httpd and enables the automatic start setting.

You can check the created playbook for syntax errors with the following command.

`cd ~/working`{{execute}}

`ansible-playbook first_playbook.yml --syntax-check`{{execute}}

```bash
playbook: first_playbook.yml
```

The above is the case without error. If there is an error in the indent etc., it will be as follows.
```bash
$ ansible-playbook first_playbook.yml --syntax-check

ERROR! Syntax Error while loading YAML.
  expected <block end>, but found '<block sequence start>'

The error appears to be in '/notebooks/working/first_playbook.yml': line 6, column 2, but may
be elsewhere in the file depending on the exact syntax problem.

The offending line appears to be:

  tasks:
 - name: install httpd
 ^ here
```


In this case, double check that the indentation of the playbook is the same as the sample.

## Run playbook
---
Run the playbook you created. Use the `ansible-playbook` command to run the playbook. If successful, the httpd server should start and you should be able to see the initial apache screen.

`ansible-playbook first_playbook.yml`{{execute}}

```bash
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node-2]
ok: [node-3]
ok: [node-1]

TASK [install httpd] ********************************************************
changed: [node-1]
changed: [node-2]
changed: [node-3]

TASK [start & enabled httpd] ************************************************
changed: [node-1]
changed: [node-2]
changed: [node-3]

PLAY RECAP ******************************************************************
node-1  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```


If the output looks like the above, it is successful. Please access node-1,2,3 with a browser and check the operation of the site.

> Note: If you are practicing on katacoda, click `node-1,2,3` at the top of the screen.

> Note: If you are practicing on Jupyter, check the IP address to access with `~ / inventory` and access with a browser.

If the following screen is displayed, it is successful.

![apache_top_page.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/apache_top_page.png)


## Add task
---
Add a task to distribute the top page of the site to the created plyabook.

Open `~ / working / files / index.html` in an editor.

Edit the file as follows.
```html
<body>
<h1>Apache is running fine</h1>
</body>
```

Then edit `first_playbook.yml` as follows:
```yaml
---
- name: deploy httpd server
  hosts: all
  become: yes
  tasks:
  - name: install httpd
    yum:
      name: httpd
      state: latest

  - name: start & enabled httpd
    service:
      name: httpd
      state: started
      enabled: yes

  - name: copy index.html
    copy:
      src: files/index.html
      dest: /var/www/html/
```

After editing, let's run the playbook after performing a syntax check.


`ansible-playbook first_playbook.yml --syntax-check`{{execute}}

`ansible-playbook first_playbook.yml`{{execute}}

```bash
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node-2]
ok: [node-3]
ok: [node-1]

TASK [install httpd] ********************************************************
ok: [node-1]
ok: [node-3]
ok: [node-2]

TASK [start & enabled httpd] ************************************************
ok: [node-2]
ok: [node-1]
ok: [node-3]

TASK [copy index.html] ******************************************************
changed: [node-1]
changed: [node-3]
changed: [node-2]

PLAY RECAP ******************************************************************
node-1  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

After normal completion, access the 3 nodes again with a browser. If the playbook is written correctly and it works, you should see the contents of the `index.html` you just created.

## Idempotence
---
I explained that the amount of description can be significantly reduced as a merit of using the Ansible module, but there are other merits as well. That is `idempotence`.

In this exercise, you are running `ansible-playbook first_playbook.yml` twice. When I installed and started httpd, and when I added the top page of the site. That is, the httpd installation and startup tasks have been performed twice. However, no error occurred in the second playbook execution. This is because Ansible's `idempotence` is working.

If you carefully check the results of the first and second runs, you will notice a difference in the output. The difference is whether each process outputs `changed` or` ok`.

* `changed`: As a result of Ansible executing the process, the state of the target host has changed (Ansible actually set it)
* `ok`: Ansible tried to process, but the status did not change because it was already the expected setting (Ansible did not set / did not need to do it)

This behavior is the idempotency of Ansible. Ansible will tell you if you need to do what you're about to do or not before you do it.

Now let's run this playbook again. Think about what the three tasks will look like before you run them.

`ansible-playbook first_playbook.yml`{{execute}}

```bash
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node-3]
ok: [node-1]
ok: [node-2]

TASK [install httpd] ********************************************************
ok: [node-2]
ok: [node-1]
ok: [node-3]

TASK [start & enabled httpd] ************************************************
ok: [node-1]
ok: [node-2]
ok: [node-3]

TASK [copy index.html] ******************************************************
ok: [node-3]
ok: [node-1]
ok: [node-2]

PLAY RECAP ******************************************************************
node-1  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

All tasks should be `ok`. You can easily see the difference in the results by arranging the last `PLAY RECAP` parts when running the playbook. Here you can see how many tasks have become `changed` on each node.


1st time (2 tasks changed)
```
PLAY RECAP ******************************************************************
node-1  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

2nd time (1 task changed)
```
PLAY RECAP ******************************************************************
node-1  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

3rd time (changed is 0)
```
PLAY RECAP ******************************************************************
node-1  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

So what makes me happy about this idempotence?

* In the playbook, "the state can be described declaratively, not the processing procedure" → Playbook = setting parameter + procedure manual can be handled.
* Even if the process executed for multiple hosts fails in the middle, it can be restarted from the beginning (because the part where the setting was successful is skipped).

Each Ansible module is designed to take this idempotency into account, and this module makes it easy and safe to write automation.

If this is a script, is it okay to rerun the script, especially when re-running? Is it useless? You can easily imagine that such troublesome points of consideration will be created.

> Note: However, not all modules of Ansible are guaranteed to be completely idempotent. Some modules, such as shells, do not know what will be executed, and some modules are difficult to ensure idempotency in principle depending on the operation target (NW device or cloud environment). Users need to be careful when using these modules

## Exercise answer
-[first_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/first_playbook.yml)
