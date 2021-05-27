## docker-blue-green-deployment
Example of blue-green deployment with docker-compose




```
cd docker-blue-green-deployment
```{{execute}}

`docker-compose.yml`{{open}}

`setup.sh`{{open}}


### Let's setup first our baseline relese (GREEN)
```
 ./setup.sh
```{{execute}}

We expect that shortly after the setup script executed we can test our app:

```
curl -s localhost
```{{execute}}

Should output
`$ green-backend`

### Let's deploy the next version (BLUE)

`switch.sh`{{open}}

```
./switch.sh
```{{execute}}

We expect similar output:
```
Removing old "blue-backend" container
Stopping mnt_blue-backend_1 ... done
Going to remove mnt_blue-backend_1
Removing mnt_blue-backend_1 ... done
Starting new "blue-backend" container
Creating mnt_blue-backend_1 ... 
Creating mnt_blue-backend_1 ... done
New "blue-backend" container started
Sleeping 5 seconds
Checking "blue-backend" container
blue-backend
New "blue-backend" container passed http check
Changing ingress config
Check ingress configs
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
New ingress nginx config is valid
Reload ingress configs
Ingress reloaded
Sleeping 2 seconds
Checking new ingress backend
blue-backend
New ingress backend passed http check
All done here! :)
```

Test the next version:

```
curl -s localhost
```{{execute}}

Should output:

`$ blue-backend`



