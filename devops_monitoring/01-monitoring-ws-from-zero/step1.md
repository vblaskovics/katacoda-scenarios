## Let's examing the lab environment
Nothing is running yet.
First, click the "Prometheus" tab on your right, or follow:

https://[[HOST_SUBDOMAIN]]-9090-[[KATACODA_HOST]].environments.katacoda.com/

You should see a message similar to this showing that there is nothing running on the host yet:

![step1-empty-toolchain](/manuelpais/courses/treating-your-pipeline-as-a-product/01-from-zero-to-delivery/assets/step1-empty-toolchain.png)

That is because we haven't started yet the associated docker containers.

## Let's start Prometheus

We have prepared and pulled an environment for you. 

Change to the directory of this envirnment.

```
cd workshop-prometheus-grafana
```{{execute}}


Start prometheus container in docker.
```
docker-compose up -d prometheus
```{{execute}}

You can check if you service started properly by revisigin the url or the tab in the workspace called Prometheus

https://[[HOST_SUBDOMAIN]]-9090-[[KATACODA_HOST]].environments.katacoda.com/

## Notice what we get

We get:
* a Database (Prometheus DB)
* a Prometheus backend system ready to pull data from other endpoints
* a Prometheus UI web application (port 9090)

This system is not that useful at all yet. There are no metrics in the system yet.
Follow the next step in order to understand how you get metrics into Prometheus.