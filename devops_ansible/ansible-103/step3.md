# Role management and reuse
---
Here, we will look at how to manage and reuse the created role. Roles allow you to make a playbook part, but you don't want to copy the set of roles to the `roles` directory every time you reuse that part. This is because if the original role changes after copying, it cannot keep up with the changes. In addition, the time and effort required to manage such distribution of source code is enormous.

To solve this problem, Ansible has a way to get the complete set of roles needed to run the playbook. That is [`ansible-galaxy`](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html).

In addition to using Galaxy, we will explain the Role management method.

## How to manage Role
---
Ansible strongly recommends using a source code control system such as `git` to manage roles.

> Note: Although it is said to be recommended, it is practically almost mandatory. Of course, you can also manage Role and playbook files manually. However, just because it is possible, I strongly state that "manual management should not be done" under any circumstances.

When managing roles with git, "1 role = 1 repository" is the basis. Adopting this management method will result in a large number of repositories, so creating a catalog of roles will give you a better view. There is a site called `Galaxy` (https://galaxy.ansible.com/) as a mechanism of the catalog officially provided by Ansible, and you can also register your role here.

The `Galaxy` (https://galaxy.ansible.com/) already has a huge number of roles registered, and in most cases you can search to find what you want to do.

> Note: In some cases it can be used as is, in other cases it needs to be modified. However, you can significantly reduce the effort of creating a role while checking for zero each time.

## Using the `ansible-galaxy` command
---
Let's import and utilize the role for the exercise. Use the `ansible-galaxy` command to reuse a role that has already been created and is accessible on git.

The roles used this time are as follows.

-[irixjp.role_example_hello](https://galaxy.ansible.com/irixjp/role_example_hello) A role that only displays greetings
-[irixjp.role_example_uptime](https://galaxy.ansible.com/irixjp/role_example_uptime) A role that only displays the result of uptime

> Note: To create a role for `Galaxy`, add [` meta`](https://galaxy.ansible.com/docs/contributing/creating_role.html) data to the normal role and register it in Galaxy. Just do it.

To get these roles together, prepare the `requirements.yml` file.

Edit `~/working/roles/requirements.yml` as follows.

```yaml
---
- src: irixjp.role_example_hello
- src: irixjp.role_example_uptime
```

The format of `requirements.yml` is explained in detail at [here](https://galaxy.ansible.com/docs/using/installing.html). Here, the catalog name (`irixjp.role_example_hello`) on Galaxy is specified, but it is also possible to directly refer to github or your own git server.

Next, create a `~/working/galaxy_playbook.yml` that uses this role.
```yaml
---
- name: using galaxy
  hosts: node-1
  tasks:
    - import_role:
        name: irixjp.role_example_hello

    - import_role:
        name: irixjp.role_example_uptime
```

Now you're ready to go.

## Download Role and run playbook
---
Learn roles from Galaxy.

`cd ~/working`{{execute}}

`ansible-galaxy install -r roles/requirements.yml`{{execute}}

```bash
- downloading role 'role_example_hello', owned by irixjp
- downloading role from https://github.com/irixjp/ansible-role-sample-hello/archive/master.tar.gz
- extracting irixjp.role_example_hello to /jupyter/.ansible/roles/irixjp.role_example_hello
- irixjp.role_example_hello (master) was installed successfully
- downloading role 'role_example_uptime', owned by irixjp
- downloading role from https://github.com/irixjp/ansible-role-sample-uptime/archive/master.tar.gz
- extracting irixjp.role_example_uptime to /jupyter/.ansible/roles/irixjp.role_example_uptime
- irixjp.role_example_uptime (master) was installed successfully
```

The `ansible-galaxy install` command by default expands roles to `$HOME/.ansible/roles`. This can be controlled with the `-p` option.

Also, by using `-f`, you can overwrite the existing downloaded role and learn it, so you can always use the latest role.

Actually run the playbook.

`ansible-playbook galaxy_playbook.yml`{{execute}}

```bash
TASK [irixjp.role_example_hello : say hello!] ********
ok: [node-1] => {
    "msg": "Hello"
}

TASK [irixjp.role_example_uptime : get uptime] *******
changed: [node-1]

TASK [irixjp.role_example_uptime : debug] ************
ok: [node-1] => {
    "msg": " 07:41:00 up 1 day,  3:04,  1 user,  load average: 0.00, 0.01, 0.05"
}
```

By managing roles on git and managing required roles in `requirements.yml` in this way, it is possible to reduce the distribution of source code and improve efficiency and security.

## Use of custom modules and filters in Role
---
Custom modules and filters contained in a Role are also available to tasks outside the role once the role is loaded into the playbook.

As an example, the role `irixjp.role_example_hello` contains a custom module` sample_get_locale`.

You can use this custom module as follows: Edit `~/working/galaxy_playbook.yml`.
```yaml
---
- name: using galaxy
  hosts: node-1
  tasks:
    - import_role:
        name: irixjp.role_example_hello

    - import_role:
        name: irixjp.role_example_uptime

    - name: get locale
      sample_get_locale:
      register: ret

    - debug: var=ret
```
I will do it.

`ansible-playbook galaxy_playbook.yml`{{execute}}

```bash
TASK [get locale] *********************
ok: [node-1]

TASK [debug] **************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "failed": false,
        "locale": "en_US.UTF-8"
    }
}
```


You can see that the custom module is running after the role.

In this way, roles can be used as a mechanism for distributing custom modules. In this case, leave the role'tasks / main.yml` empty and implement it in such a way that the role itself does not perform any tasks.


## How to create a role for Galaxy
---
You must include `galaxy.yml` in your repository in order to use Galaxy to create redistributable roles. See [Creating Roles](https://galaxy.ansible.com/docs/contributing/creating_role.html) for how to create it.


## Supplementary information
---
You have to run `ansible-galaxy install` every time on the command line, but Ansible Tower / AWX has the ability to automatically download roles from` requirements.yml` before running the playbook, so you forget to update it. It is possible to prevent accidents.


## Exercise answer
---
* [galaxy_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/galaxy_playbook.yml)
* [requirements.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/roles/requirements.yml)
