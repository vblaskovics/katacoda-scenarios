Prepare the exercise environment.

## preparation work
---
Execute the following command to prepare the exercise environment. This operation takes about 1-2 minutes.

`apt install -y git && git clone https://github.com/tjozsa/katacoda-scenarios && cd katacoda-scenarios/devops_chef_solo/master-course-data/assets/tools/`{{execute}}

`bash ./kata_setup.sh`{{execute}}

## Environmental overview
---
In this exercise, we will use the following environment. Three servers, `node-1`,` node-2`, and `node-3`, are running, and you can use Ansible to perform various operations on them.

![image0-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/kata_env.png "kata_env.png")

## Supplementary information
---
At the top of the terminal there are tabs called `node-1`,` node-2`. Click here to connect to port 80 on each server. Now that nothing is running on each node, clicking it does nothing, but we will use this tab in the exercise.

> Note: This port is actually accessing the container, which is in the form of 8081-> node-1: 80, 8082-> node-2: 80.

Click this tab if you were instructed to "access the node in your browser" during the exercise steps.
