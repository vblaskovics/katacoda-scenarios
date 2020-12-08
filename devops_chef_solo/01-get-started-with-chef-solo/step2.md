# Log into the Chef container
We want to do everything in this container from now on. This is our Chef Solo control node.

`docker exec -it --user centos chef /bin/bash`{{execute}}

## Configuring Chef Solo
`mkdir ~/chef`{{execute}}

`cd ~/chef`{{execute}}

`nano solo.rb`{{execute}}

Enter the following into the file:
```ruby
cookbook_path '~/chef/cookbooks'
```
Type `ctrl+x` then `Y` and enter to save and quit the editor

## Create Hello World cookbook

`cookbook_path 'mkdir -p ~/chef/cookbooks/test/recipes'`{{execute}}

Edit the default recipy file

`nano ~/chef/cookbooks/test/recipes/default.rb`{{execute}}

Enter the following into the file:

```ruby
puts "Hello, Chef"
```
Type `ctrl+x` then `Y` and enter to save and quit the editor

## Run the recipy

cd to the chef directory

`cd ~/chef`{{execute}}

run the default recipe

`chef-solo -c ~/chef/solo.rb -o 'recipe[test]'`{{execute}}