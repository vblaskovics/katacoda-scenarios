# Log into the Bolt container
We want to do everything in this container from now on. This is our Puppet Bolt control node.

`docker exec -it --user centos bolt /bin/bash`{{execute}}

## Configuring Bolt
`mkdir ~/Boltdir`{{execute}}

`cd ~/Boltdir`{{execute}}

`nano bolt.yaml`{{execute}}

Enter the following into the file:
```yaml
ssh:
  host-key-check: false
  run-as-command:
    - "sudo"
    - "-n"
    - "-u"
```
Type `ctrl+x` then `Y` and enter to save and quit the editor

## Create inventory

`nano inventory.yaml`{{execute}}

Enter the following into the file:

```yaml
groups:
 - name: all_linux
   targets:
    - target1
    - target2
   config:
     ssh:
       password: password
```
Type `ctrl+x` then `Y` and enter to save and quit the editor

## Simple command execution

`bolt command run "date" --targets all_linux`{{execute}}

And another one just for fun:

You can of course limit which host to run the commands on by selecting just one host

`bolt command run "df -h" --targets target2`{{execute}}

Or listing them:

`bolt command run "df -h" --targets target1,target2`{{execute}}

You can also run commands from a local script:

create a script caled myscript.sh and add some bash script commands to it:

`nano myscript.sh`{{execute}}

```bash
#!/bin/bash
date
df -h
```
Type `ctrl+x` then `Y` and enter to save and quit the editor

now run the contents of this script line-by-line on target nodes

`bolt command run @myscript.sh --targets all_linux`{{execute}}

You can upload a file to the targets:

`bolt file upload myscript.sh /home/centos/myscript.sh --targets all_linux`{{execute}}

And download files:
`bolt file download /etc/ssh/sshd_config sshd_config --targets all_linux`{{execute}}

## bolt plan
In order to create more complicated and reusable configuration you can create and reuse modules.
Create the followin strucure in your project:

```
.
├── inventory.yaml
└── modules
    └── apache
        ├── files
        └── plans
            └── install.yaml
```

`mkdir ~/Boltdir/modules`{{execute}}

`mkdir ~/Boltdir/modules/apache`{{execute}}

`mkdir ~/Boltdir/modules/apache/files`{{execute}}

`mkdir ~/Boltdir/modules/apache/plans`{{execute}}

Create your plan file:

`nano ~/Boltdir/modules/apache/plans/install.yaml`{{execute}}

add thhe following content

```
parameters:
  targets:
    type: TargetSpec

steps:
  - name: install_apache
    task: package
    targets: $targets
    parameters:
      action: install
      name: apache2
    description: "Install Apache using the packages task"
```

Type `ctrl+x` then `Y` and enter to save and quit the editor

Make sure you are in the right directory:

`cd ~/Boltdir`{{execute}}

Execute the bolt plan:

`bolt plan run apache::install -t all_linux`{{execute}}

This fails because of privilige issues. We should install using sudo

```bash
Starting: plan apache::install
Starting: Install Apache using the packages task on target1, target2
Finished: Install Apache using the packages task with 2 failures in 0.62 sec
Finished: plan apache::install in 0.64 sec
Failed on target1:
  E: Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied) E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), are you root?
  {
    "status": "failure"
  }
Failed on target2:
  E: Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied) E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), are you root?
  {
    "status": "failure"
  }
Failed on 2 targets: target1,target2
```

`--run-as root` is the simplest way to progress:

`bolt plan run apache::install -t all_linux --run-as root`{{execute}}

```bash
Starting: plan apache::install
Starting: Install Apache using the packages task on target1, target2
Finished: Install Apache using the packages task with 0 failures in 13.64 sec
Finished: plan apache::install in 13.65 sec
Plan completed successfully with no result
```