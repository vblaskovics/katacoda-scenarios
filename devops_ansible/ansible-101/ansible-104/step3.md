# Automation of testing and verification
---
Ansible can also automate testing and verification tasks. In particular, you can expect great effects by automating various confirmation tasks such as large-scale tests and tests that are repeatedly executed even if they are small.

Now let's see how to create a playbook to run the tests.

## Modules that can be used for testing
---
First, I will introduce the modules that can be used for testing.

* [shell](https://docs.ansible.com/ansible/latest/modules/shell_module.html) Module: Execute any command and collect the result.
* [uri](https://docs.ansible.com/ansible/latest/modules/uri_module.html) Module: Issue an HTTP method to any URL.
  * *_command module: A module that mainly issues arbitrary commands to network devices and collects the results. Example [ios_command](https://docs.ansible.com/ansible/latest/modules/ios_command_module.html) [junos_command](https://docs.ansible.com/ansible/latest/modules/junos_command_module.html) etc. ..
  * *_facts/info module: This module mainly gets environment information. Example [ec2_vol_info_module](https://docs.ansible.com/ansible/latest/modules/ec2_vol_info_module.html) [netapp_e_facts]https://docs.ansible.com/ansible/latest/modules/netapp_e_facts_module.html)
* [assert](https://docs.ansible.com/ansible/latest/modules/assert_module.html) Module: Evaluates the conditional expression and returns ok if true.
* [fail](https://docs.ansible.com/ansible/latest/modules/fail_module.html) Module: Evaluates the conditional expression and returns failed if true.
* [template](https://docs.ansible.com/ansible/latest/modules/template_module.html) Module: Used to output test results.

> Note: When testing an environment built / modified with Ansible using Ansible itself, it is recommended to test using a module different from the module used for building. For example, you can use the `shell` module to check the files distributed using the` copy` module.


## How to write a test
---
Testing in Ansible has a commonly used pattern: `shell`, `*_command`, `*_facts` to get information and the result to be judged by `assert`, `fail`.

sample
```yaml
- name: get command AAA result
  shell: exec AAA
  register: ret_AAA

- name: check AAA result
  assert:
    that:
      - ret_AAA.rc == 0
```

Normally, when an error occurs, the playbook will stop at the task that caused the error. This is not a problem when setting, but in the case of testing, the test will stop in the middle. The test is executed to the end regardless of whether an error occurs or not, and it is necessary to know how many of the entire test items are successful / error. In such cases, group the test commands with `block` and set `ignore_error` to ignore the error.

sample
```yaml
- ignore_errors: yes
  block:
  - name: get command AAA result
    shell: exec AAA
    register: ret_AAA

  - name: get command BBB result
    shell: exec BBB
    register: ret_BBB

  - name: get command CCC result
    shell: exec CCC
    register: ret_CCC

- name: check test results
  assert:
    that: "{{ item.failed == false }}"
  loop:
    - "{{ ret_AAA }}"
    - "{{ ret_BBB }}"
    - "{{ ret_CCC }}"
```

In the above sample, the results are collectively judged in a loop. This method is convenient, but you need to output the information so that the `register` side can easily determine it. When setting complicated conditions, you can also write as follows.

```yaml
- name: check test results
  assert:
    that:
      - ret_AAA.rc == 0                     # Judge the return value
      - ret_BBB.stdout.find("string") != -1 # Output contains
      - ret_CCC.stdout.find("string") == -1 # Output does not contain string
```
In the `that` clause of` assert`, if you pass the condition as an array, it will be treated as an AND condition.



## Creating a test
---
Let's actually create a test. As a simple example, the test target assumed here is the server on which the httpd server is installed and started. Specifically, we will test the server that has executed the following.

`ansible node-1 -b -m yum -a 'name=httpd state=present'`{{execute}}

`ansible node-1 -b -m systemd -a 'name=httpd state=started enabled=yes'`{{execute}}

To test the above, we will make the following checks.

* Package httpd is installed
* Process httpd exists (starts)
* Service httpd is automatically started (enabled)

Edit the file `~/working/testing_assert_playbook.yml` as follows:
```yaml
---
- name: Test with assert
  hosts: node-1
  become: yes
  gather_facts: no
  tasks:
    - ignore_errors: yes
      block:
        - name: Is httpd package installed?
          shell: yum list installed | grep -e '^httpd\.'
          register: ret_httpd_pkg

        - name: check httpd processes is running
          shell: ps -ef |grep http[d]
          register: ret_httpd_proc

        - name: Is httpd service enabled?
          shell: systemctl is-enabled httpd
          register: ret_httpd_enabled

    - block:
        - name: Assert results
          assert:
            that:
              - ret_httpd_pkg.rc == 0
              - ret_httpd_proc.rc == 0
              - ret_httpd_enabled.rc == 0
      always:
        - name: build report
          copy:
            content: |
              # Test Reports
              ---
              | test | result |
              | ---- | ------ |
              {% for i in results %}
              | {{ i.cmd | regex_replace(query, '&#124;') }} | {{ i.rc }} |
              {% endfor %}
            dest: result_report_{{ inventory_hostname }}.md
          vars:
            results:
              - "{{ ret_httpd_pkg }}"
              - "{{ ret_httpd_proc }}"
              - "{{ ret_httpd_enabled }}"
            query: "\\|"
          delegate_to: localhost
```

* The first `ignore_errors` below runs the required test code and `registers` each result.
* In the second `ignore_errors`, the result is confirmed by the `assert` module.
* The last `always` is the test result report. This will cause the report to be created even if the assert fails.
  * In this report creation, a file in `Markdown` format is created by writing Jinja2 directly in the `content` parameter of the `copy` module.
  * The `regex_replace` filter replaces strings with regular expressions.
    * Here, the `|` contained in the command is replaced with `&#124;`. This replaces `|` in the executed command with another expression (`&#124;`) because `|` is the delimiter when outputting the result in table format.

Run the playbook.

`cd ~/working`{{execute}}

`ansible-playbook testing_assert_playbook.yml`{{execute}}

This test should succeed. A report file called `~/working/result_report_node-1.md` should have been created, so check the contents.

Next, let's fail the test. Stop the httpd process before running the test.

`ansible node-1 -b -m systemd -a 'name=httpd state=stopped enabled=yes'`{{execute}}

`ansible-playbook testing_assert_playbook.yml`{{execute}}

This time it should have failed. Check out what the report looks like.


This report can be converted from html format to pdf by using [pandoc](https://pandoc.org/) etc., so if you improve the appearance a little more, you can submit it as a report as it is.


## Exercise answer
---
* [testing_assert_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/testing_assert_playbook.yml)
