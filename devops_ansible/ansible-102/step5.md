# Template

Ansible has a template function, which enables dynamic file creation. [`Jinja2`](https://palletsprojects.com/p/jinja/) is used as the template engine.

Templates are a very versatile feature and can be used in a variety of situations. It is possible to dynamically generate and distribute the configuration file for the application, and create a report based on the information collected from each node.

## Jinja2
---
Two elements are required to use the template.

--Template file: A file with an embedded jinja2 format representation, typically with a j2 extension.
-[`template`](https://docs.ansible.com/ansible/latest/modules/template_module.html) Module: Similar to a copy module. If you specify the template file in src and the location in dest, when copying the template file, the jinja2 part is processed before copying the file.

Actually create. Create a `~/working/templates/index.html.j2` file and edit the contents so that it is as follows. This file will be the `jinja2` template file.

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

At first glance, this file looks like a simple HTML file, but there are parts enclosed by `{{}}` and `{%%}`. This part corresponds to the `Jinja2` representation expanded by the template engine.

--Evaluate the variables in `{{}}` and embed the values in parentheses.
--You can embed control statements in `{%%}`.

Before giving a detailed explanation, let's first create `~/working/template_playbook.yml` and actually move the template. Edit `template_playbook.yml` as follows.

```yaml
---
- name: using template
  hosts: web
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

    - name: Put index.html from template
      template:
        src: templates/index.html.j2
        dest: /var/www/html/index.html
```

* `template: `Calling the template module.

Let's move this playbook.

`cd ~/working`{{execute}}

`ansible-playbook template_playbook.yml -e 'LANG=JP'`{{execute}}

```bash
(省略)
TASK [Put index.html from template] **********************
changed: [node-2]
changed: [node-3]
changed: [node-1]
(省略)
```

Let's see what the result is. Execute the following command.

`ansible web -m uri -a 'url=http://localhost/ return_content=yes'`{{execute}}

This command makes use of a module that issues HTTP requests called the [`uri`](https://docs.ansible.com/ansible/latest/modules/uri_module.html) module. This module is used to access `http://localhost/ from each node to get the content.

```bash
node-1 | SUCCESS => {
    (省略)
    "content": "<html><body>\n<h1>This server is running on node-1.</h1>\n\n<p>\n     Konnichiwa!\n</p>\n</body></html>\n",
    (省略)
    "url": "http://localhost/"
}
node-2 | SUCCESS => {
    (省略)
    "content": "<html><body>\n<h1>This server is running on node-2.</h1>\n\n<p>\n     Konnichiwa!\n</p>\n</body></html>\n",
    (省略)
    "status": 200,
    "url": "http://localhost/"
}
node-3 | SUCCESS => {
    (省略)
    "content": "<html><body>\n<h1>This server is running on node-3.</h1>\n\n<p>\n     Konnichiwa!\n</p>\n</body></html>\n",
    (省略)
    "status": 200,
    "url": "http://localhost/"
}
```

The contents of the obtained `index.html` are stored in the `content` key. If you check this content, the `{{inventory_hostname}}` part in the template file will be replaced with the host name, and the `{% if LANG ==" JP "%}` part will be "Konnichiwa!" You can confirm that it is.

Now, change the conditions and check what happens if `LANG ==" JP "` does not hold.

`ansible-playbook template_playbook.yml -e 'LANG=EN'`{{execute}}

`ansible web -m uri -a 'url=http://localhost/ return_content=yes'`{{execute}}

In the next run, you should see that "Hello!" Was inserted.

> Note: Please also access each node with a browser to check.

By using the template in this way, it is possible to dynamically generate files. This function has a very wide range of applications and can be used in various situations such as automatic generation of configuration files and automatic creation of configuration reports.


## Filter
---
One of the features of Jinja2 is [`filter`] (https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html). This can be used when expanding a variable with `{{}}`, and the value of the variable can be easily processed. This feature is also available within the playbook.

To use the filter, use the format `{{var_name | filter_name}}`. Let's look at some examples.


### default filter

It is a filter that sets the initial value when the variable does not contain a value.

`ansible node-1 -m debug -a 'msg={{ hoge | default("abc") }}'`{{execute}}

```bash
node-1 | SUCCESS => {
    "msg": "abc"
}
```

### upper / lower filter

A filter that converts a character string to uppercase or lowercase.

`ansible node-1 -e 'str=abc' -m debug -a 'msg="{{ str | upper }}"'`{{execute}}

```bash
node-1 | SUCCESS => {
    "msg": "ABC"
}
```

### min / max filter

A filter that extracts the minimum and maximum values from the list.

`ansible node-1 -m debug -a 'msg="{{ [5, 1, 10] | min }}"'`{{execute}}

```bash
node-1 | SUCCESS => {
    "msg": "1"
}
```

`ansible node-1 -m debug -a 'msg="{{ [5, 1, 10] | max }}"'`{{execute}}

```bash
node-1 | SUCCESS => {
    "msg": "10"
}
```

Many other filters are implemented, so you can create a playbook more easily by using them properly according to the situation.

## Exercise answer
---
* [template_html_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/block_playbook.yml)
* [index.html.j2](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/templates/index.html.j2)
