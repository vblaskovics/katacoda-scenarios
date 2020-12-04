## Install Ansible

There are a ton of ways to install Ansible. The way I like to do this is to use Python3 pypi CLI called `pip`

`pip install ansible`{{execute}}

What this will do is install "All things Ansible".

## Test Ansible Installation

The way I like to test if it all workted out correctly is to see if the `ansible` command is available on the $PATH environment variable:

`ansible --version`{{execute}}

Notice that we get a bunch of status printouts.

Another thing to check is all the various commands you get that start with `ansible-`

Type `ansible-` and hit twice the TAB button to reviel all the tools you got as a package