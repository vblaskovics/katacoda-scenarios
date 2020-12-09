#Collections
---
`Collection` takes the Galaxy reuse mechanism one step further. It is possible to manage and distribute multiple roles and custom modules together. Available in Ansible 2.9 and later (experimentally available from 2.8).

What was previously managed in one role and one repository can now be managed in one repository by collecting common functions used by organizations and teams.

## Use of Collection
---
In the exercise, we will use the sample collection [https://galaxy.ansible.com/irixjp/sample_collection_hello](https://galaxy.ansible.com/irixjp/sample_collection_hello) that has already been created. The name of this collection is `irixjp.sample_collection_hello`. The original source code is stored on [github](https://github.com/irixjp/ansible-sample-collection-hello).

> Note: The collection name is expressed in the format `<namespace>.<Collection_name>`.

This collection contains:

* -role: hello
* -role: uptime
* -module: sample \ _get \ _hello

To make use of the collection, create `requirements.yml`.

Edit `~/working/collections/requirements.yml` as follows.

```yaml
---
collections:
- irixjp.sample_collection_hello
```

To get the collection: By default, collections are downloaded to `~/.ansible/collections/`. You can change the save destination by adding `-p`, and forcibly overwrite the latest version with` -f`.

`ansible-galaxy collection install -r collections/requirements.yml`{{execute}}

Create a playbook that uses the retrieved collection. Access the collection in the following format.

`<namespace>.<collection_name>.<role or module name>`

Edit `~/working/collection_playbook.yml` as follows.

```yaml
---
- name: using collection
  hosts: node-1
  tasks:
    - import_role:
        name: irixjp.sample_collection_hello.hello

    - import_role:
        name: irixjp.sample_collection_hello.uptime

    - name: get locale
      irixjp.sample_collection_hello.sample_get_locale:
      register: ret

    - debug: var=ret
```

Check the execution result.

`ansible-playbook collection_playbook.yml`{{execute}}

`ansible-playbook collection_playbook.yml`{{execute}}

```bash
TASK [hello : say hello! (C)] **************
ok: [node-1] => {
    "msg": "Hello"
}

TASK [uptime : get uptime] *****************
ok: [node-1]

TASK [uptime : debug] **********************
ok: [node-1] => {
    "msg": " 03:38:16 up 4 days, 23:01,  1 user,  load average: 0.16, 0.05, 0.06"
}

TASK [get locale] **************************
ok: [node-1]

TASK [debug] *******************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "failed": false,
        "locale": "C.UTF-8"
    }
}
```

You can see that each role and module in the collection is called. Unlike the case of a single role, it is also possible to call a custom module by itself, further improving convenience.

## Supplementary information
---
Also check the following if necessary.

* More detailed usage: [Using collections](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)
* How to create collections: [Developing collections](https://docs.ansible.com/ansible/devel/dev_guide/developing_collections.html)

You have to run `ansible-galaxy collection install` every time on the command line, but Ansible Tower / AWX has the ability to automatically download roles from` requirements.yml` before running the playbook, so forget to update. It is possible to prevent such accidents.


## Exercise answer
---
* [collection_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/collection_playbook.yml)
* [requirements.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/collections/requirements.yml)
