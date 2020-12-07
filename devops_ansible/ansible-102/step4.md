#Error handling
---
You can group a set of tasks in a playbook and apply `when` or` ingore_errors` together. This is where the `block` clause comes in. The `block` clause also has error handling capabilities, allowing you to use the` always` clause to perform the task of the `rescue` clause for errors within the` block`, or to execute regardless of the error.

## block
---
A playbook with the `block` clause can be written as:

Edit `~/working/block_playbook.yml`.
```yaml
---
- name: using block statement
  hosts: node-1
  become: yes
  tasks:
    - name: Install, configure, and start Apache
      block:
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
      when:
        - exec_block == 'yes'
```

--`block: ~~ when:` Here, the three tasks are grouped in the `block` clause and conditional in the` when` clause. This `block` part is executed together when` exec_block =='yes'` is satisfied.

Let's see what the difference is in the execution results of `block_playbook.yml` between `-e 'exec_block = no'` and `yes`.

`cd ~/working`{{execute}}

The first is the case where the conditions are not met.

`ansible-playbook block_playbook.yml -e 'exec_block=no'`{{execute}}

```bash
TASK [install httpd] *********************************
skipping: [node-1]

TASK [start & enabled httpd] *************************
skipping: [node-1]

TASK [copy index.html] *******************************
skipping: [node-1]
```

You can see that the three tasks are skipped together. Next is the case where the condition is met.

`ansible-playbook block_playbook.yml -e 'exec_block=yes'`{{execute}}

```bash
TASK [install httpd] *********************************
ok: [node-1]

TASK [start & enabled httpd] *************************
ok: [node-1]

TASK [copy index.html] *******************************
ok: [node-1]
```

You can see that the three tasks grouped by `block` are running.

By grouping related tasks in this way, it is possible to control them collectively using the `when` clause.


## rescue, always
---
You can use `rescue`, `always` in the `block` clause.

Create `~/working/rescue_playbook.yml` as follows.

```yaml
---
- name: using block, rescue, always statement
  hosts: node-1
  become: yes
  tasks:
    - block:
        - name: block task
          debug:
            msg: "message from block"

        - name: check error flag in block
          assert:
            that:
              - error_flag == 'no'

      rescue:
        - name: rescue task
          debug:
            msg: "message from rescue"

        - name: check error flag in rescue
          assert:
            that:
              - error_flag == 'no'

      always:
        - name: always task
          debug:
            msg: "message from always"
```

* `block`: Describes the main process.
  -[`assert`] (): This is a judgment module. If the condition given by `that` is satisfied, it becomes` ok`, and if the condition is not satisfied, it becomes `failed`.
* ` rescue`: Executed when an error occurs in `block`.
* `always`: Execute the process you want to execute.

This playbook will exit normally if the value of the `error_flag` variable is` no`, otherwise an error will occur.

Actually run it and check the result. First, set `error_flag = no` to terminate normally.

`ansible-playbook rescue_playbook.yml -e 'error_flag=no'`{{execute}}

```bash
TASK [block task] ************************************
ok: [node-1] => {
    "msg": "message from block"
}

TASK [check error flag in block] *********************
ok: [node-1] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [always task] ***********************************
ok: [node-1] => {
    "msg": "message from always"
}
```

In this case, the task in `block` is running, then the task in` always` is running.

Next, let's look at the case when an error occurs.

`ansible-playbook rescue_playbook.yml -e 'error_flag=yes'`{{execute}}

```bash
TASK [block task] ************************************
ok: [node-1] => {
    "msg": "message from block"
}

TASK [check error flag in block] *********************
fatal: [node-1]: FAILED! => {
    "assertion": "error_flag == 'no'",
    "changed": false,
    "evaluated_to": false,
    "msg": "Assertion failed"
}

TASK [rescue task] ***********************************
ok: [node-1] => {
    "msg": "message from rescue"
}

TASK [check error flag in rescue] ********************
fatal: [node-1]: FAILED! => {
    "assertion": "error_flag == 'no'",
    "changed": false,
    "evaluated_to": false,
    "msg": "Assertion failed"
}

TASK [always task] ***********************************
ok: [node-1] => {
    "msg": "message from always"
}
```

Here the task `block` is executed first, but an error occurs. The processing of `rescue` is being called because an error has occurred. I also get an error inside `rescue`, but the playbook does not stop and` always` is executed.

By using `block`,` rescue`, `always` in this way, it is possible to perform error handling in the playbook. A typical usage scene is to use `rescue` to perform recovery work in the event of a failure, and use` always` to notify the status.


## Exercise answer
---
* [block_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/block_playbook.yml)
* [rescue_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/rescue_playbook.yml)
