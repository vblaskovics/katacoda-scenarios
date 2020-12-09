# Partization by Role
---
So far, we've listed modules directly in the playbook. You can automate Ansible with this method, but when you actually use Ansible, you often encounter cases where you want to reuse the previous process. Copying and pasting the previous code at that time is inefficient, but if you try to call another entire playbook, the group name written in `hosts:` will not be consistent and will not work. Is most of the time. That's where the idea of ​​`Role` in the figure below comes into play.

![structure.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/structure.png)

Automation can be made into parts that can be reused in various units of work. `Role` is completely separate from the inventory and can be called and used from various playbooks. Ansible calls this kind of playbook development and management method [best practice](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html).

## Role structure
`Role` is used by arranging files in a directory with a predetermined configuration. The directory can then be called from Ansible as `Role`.

The typical roll structure is listed below.
```
site.yml           # Caller's playbook in the roles directory at the same level as 
roles /            # playbook
                   # Ansible determines that the role is stored. Directory to store the role 
  your_role/       # your_role
                   # (Directory name = role name)
     tasks/        #
       main.yml    # Describes the task to be executed in the role.
     handlers/     #
       main.yml    # Describes the handler to use in the role.
     templates/    #
       ntp.conf.j2 # Place the template used in the role.
     files/        #
       bar.txt     # Place the files to be used in the role.
       foo.sh      #
     defaults/     #
       main.yml    # List of variables used in the role
                   # Describe the default value. 
  your_2nd_role /   # The next role will be your_2nd_role.
```

When you create a directory structure like the one above, you can call roles in `site.yml` as follows.

```yaml
---
- hosts: all
  tasks:
  - import_role:
      name: your_role

  - include_role:
      name: your_2nd_role
```

In this way, you can call the process just by specifying the role name using the module `import_role` `include_role`. Both of these modules call roles, but the differences are:

-[`import_role`](https://docs.ansible.com/ansible/latest/modules/import_role_module.html) Load the role before running the playbook (look ahead)
-[`include_role`](https://docs.ansible.com/ansible/latest/modules/include_role_module.html) Roles are loaded when the task is executed (look-ahead)

> Note: At this point, you don't need to be aware of the difference between the two. Basically, it's safer and simpler to use `import_role`. `include_role` is used to describe complex processes such as dynamically changing the role to be called by the process.

## Creating a Role
---
Let's actually create a role. It's not difficult to say that. All you have to do is divide the processing you have written so far into the specified directories.

In this exercise, we will create a `web_setup` role that sets up the web server. The directory structure is as follows.
```
role_playbook.yml # playbook that actually calls the role
roles
└── web_setup # role name
    ├── defaults
    │ └── main.yml # Store default value of variable
    ├── files
    │ └── httpd.conf # Store the files to be distributed
    ├── handlers
    │ └── main.yml # define handler
    ├── tasks
    │ └── main.yml # Describe the task
    └── templates
        └── index.html.j2 # Place template file
```

Create each file.
### `~/working/roles/web_setup/tasks/main.yml`

```yaml
---
- name: install httpd
  yum:
    name: httpd
    state: latest

- name: start & enabled httpd
  service:
    name: httpd
    state: started
    enabled: yes

- name: Put index.html from template
  template:
    src: index.html.j2
    dest: /var/www/html/index.html

- name: Copy Apache configuration file
  copy:
    src: httpd.conf
    dest: /etc/httpd/conf/
  notify:
    - restart_apache
```

You don't need to write the `play` part in the role, so we'll just list the tasks. Also, the `templates`` files` directory in the role allows modules to reference files without explicitly specifying a path. Therefore, only the file name is described in `src` of the` copy` and `template` modules.

### `~/working/roles/web_setup/handlers/main.yml`

```yaml
---
- name: restart_apache
  service:
    name: httpd
    state: restarted
```

### `~/working/roles/web_setup/defaults/main.yml`

```yaml
---
LANG: JP
```

### `~/working/roles/web_setup/templates/index.html.j2`

```jinja2
<html><body>
<h1>This server is running on {{ inventory_hostname }}.</h1>

{% if LANG == "JP" %}
     Konnichiwa!
{% else %}
     Hello!
{% endif %}
</body></html>
```

### `~/working/roles/web_setup/files/httpd.conf`

Get this file from the server side and edit it as follows.

`cd ~/working/roles/web_setup`{{execute}}

`ansible node-1 -b -m yum -a 'name=httpd state=latest'`{{execute}}

`ansible node-1 -m fetch -a 'src=/etc/httpd/conf/httpd.conf dest=files/httpd.conf flat=yes'`{{execute}}

Confirm that the file has been acquired, and rewrite the file as follows.

`ls -l files/`{{execute}}

```
ServerAdmin root@localhost
      ↓
ServerAdmin centos_role@localhost
```

### `~/working/role_playbook.yml`

Create a playbook that actually calls the role.

```yaml
---
- name: using role
  hosts: web
  become: yes
  tasks:
    - import_role:
        name: web_setup
```

### Overall check

Check the role you created.

`cd ~/working`{{execute}}

`tree roles`{{execute}}

If the structure is as follows, the necessary files are ready.
```bash
roles
└── web_setup
    ├── defaults
    │ └── main.yml
    ├── files
    │ ├── dummy_file      # Ignore this.
    │ └── httpd.conf
    ├── handlers
    │ └── main.yml
    ├── tasks
    │ └── main.yml
    └── templates
        └── index.html.j2
```

## Run
---
Run the playbook you created.

`ansible-playbook role_playbook.yml` {{execute}}

`ansible-playbook role_playbook.yml`{{execute}}

```bash
(省略)
TASK [web_setup : install httpd] *********************
ok: [node-1]
ok: [node-3]
ok: [node-2]

TASK [web_setup : start & enabled httpd] *************
ok: [node-1]
ok: [node-3]
ok: [node-2]

TASK [web_setup : Put index.html from template] ******
ok: [node-3]
ok: [node-2]
ok: [node-1]

TASK [web_setup : Copy Apache configuration file] ****
changed: [node-3]
changed: [node-2]
changed: [node-1]

RUNNING HANDLER [web_setup : restart_apache] *********
changed: [node-2]
changed: [node-3]
changed: [node-1]
(省略)
```

If the execution is successful, access each server with a browser and check the result.

The use of rolls dramatically increases the reusability of automation. This is because the task and inventory are completely separated. At the same time, by setting a certain rule called [best practice](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html) in the highly automatic playbook description method, "where and what The outlook for "is it defined?" Will be improved, and other members will be able to reuse roles with peace of mind.


## Exercise answer
---
* [role_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/role_playbook.yml)
* [web_setup](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/roles/web_setup)
