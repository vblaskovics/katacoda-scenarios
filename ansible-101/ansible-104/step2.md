# Coding convention
---
Ansible has a high degree of coding freedom, and you can create playbooks in various writing styles. However, this degree of freedom can create challenges. It's time for teams to drive automation. If you create a playbook the way you like it, some people will put `name` on the task, but others will not. If the implementation contents vary from person to person in this way, the cost for ensuring quality will increase.

That's what the team needs to have coding conventions. By establishing rules, it is possible for teams to write in common, which leads to skill leveling and reduction of review costs. However, on the other hand, it is also necessary to check whether it complies with the rules.

Therefore, Ansible provides a method to automatically check compliance with the rules, so we will learn how to use it.

## Ansible Lint
---
Ansible offers a program called [ansible-lint](https://github.com/ansible/ansible-lint). This can do a static analysis of plyabook and check for any mention of rule violations. By default, the rules you check are commonly used, and you can define your own rules.

The following two playbooks are prepared as samples.

* `~/working/lint_ok_playbook.yml`
* `~/working/lint_ng_playbook.yml`
Both of these playbooks run correctly and print the result of `ps -ef`. Try two things.

`cd ~/working`{{execute}}

`ansible-playbook lint_ok_playbook.yml`{{execute}}

`ansible-playbook lint_ng_playbook.yml`{{execute}}

Both should have run successfully. Now let's apply `ansible-lint` to these two playbooks.

`ansible-lint lint_ok_playbook.yml` {{execute}}

This ends normally.

`ansible-lint lint_ng_playbook.yml`{{execute}}

```bash
[502] All tasks should be named
lint_ng_playbook.yml:6
Task/Handler: shell set -o pipefail
ps -ef |grep -v grep
```

The second command should have resulted in an error.

Here you can see that the error code is `[502]`. The summary of the error is `All tasks should be named`, which shows that it violates the convention that" all tasks should keep their name ".

Let's check the rules that `ansible-lint` checks by default. Execute the following command.

`ansible-lint -L`{{execute}}

You can see that many conventions are defined by default. Tags are assigned to these rules, and you can specify tags to set application / exclusion collectively.

To check the list of tags, see below.

`ansible-lint -T`{{execute}}

For example, in this example, let's exclude the rule that corresponds to this `[502]`. `[502]` is included in the tag `task`, so you can execute it as follows.

`ansible-lint lint_ng_playbook.yml -x task`{{execute}}`

In the previous execution, the check for `[502]` resulted in an error, but this time it was excluded, so it ended normally.


## Define non-standard rules
---
In addition to standard checks, you can also define project and organization-specific rules.

Proprietary rules are defined in python. You can easily create rules by inheriting a class called `AnsibleLintRule`.

See [Sample](https://github.com/ansible/ansible-lint/blob/master/examples/rules/TaskHasTag.py) for details.

The following will be defined in the original rule.

--Prevent operations (commands) prohibited by your company from entering the playbook
  --For example, if there is a bug in the farm of your router and you want to prohibit the command that causes the switch to hang when you execute that command.
  --Dangerous commands that cause problems when you execute other commands.


## Other check tools
---
A more general LINT tool, [YAMLLint](https://github.com/adrienverge/yamllint), can be used to check variable naming conventions and the wording given to `name`. Please use it as needed.


## Exercise answer
---
* [lint_ok_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/working/lint_ok_playbook.yml)
* [lint_ng_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/working/lint_ng_playbook.yml)
