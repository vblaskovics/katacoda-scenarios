### Network

Create a network shared between the app and the Elastic Stack:

`docker network create course_stack`{{execute}}

### Deploy Elasticsearch 

`
docker run -d \
  --name=elasticsearch \
  --env="discovery.type=single-node" \
  --env="ES_JAVA_OPTS=-Xms256m -Xmx256m" \
  --network=course_stack \
  -p 9300:9300 -p 9200:9200 \
  --health-cmd='curl -s -f http://localhost:9200/_cat/health' \
  docker.elastic.co/elasticsearch/elasticsearch:7.11.1 
`{{execute}}

### Check the health / readiness of Elasticsearch

In the run command that you just ran, there is a health check defined.  This connects to the cluster health API of Elasticsearch.  In the output of the following command you will see the test result.  Wait until it returns a healthy response before deploying Kibana.

`docker inspect elasticsearch | grep -A8 Health`{{execute HOST2}}

### Deploy Kibana

`
docker run -d \
  --name=kibana \
  --user=kibana \
  --network=course_stack -p 5601:5601 \
  --health-cmd='curl -s -f http://localhost:5601/login' \
  docker.elastic.co/kibana/kibana:7.11.1 
`{{execute}}

### Check the health / readiness of Kibana

In the run command that you just ran, there is a health check defined.  This connects to Kibana and ensures that it is available. In the output of the following command you will see the test result.  Wait until it returns a healthy response before deploying Beats, as the Beats need to connect to both Elasticsearch and Kibana to install the modules that customize the experience related to the apps you are running (NGINX, Apache HTTPD, etc.).

`docker inspect kibana | grep -A8 Health`{{execute HOST2}}

### Run the APM Server

`
docker run -d \
--name=apm-server \
--network=course_stack \
-p 8200:8200 \
docker.elastic.co/apm/apm-server:7.11.1
`{{execute}}

### Run Redis

`
docker run \
  --network=course_stack \
  --name redis \
  --label=co.elastic.logs/module=redis \
  --label=co.elastic.logs/fileset.stdout=log \
  --label=co.elastic.metrics/module=redis \
  -d -p 6379:6379 redis
`{{execute}}

### Run the node-guestbook

Before running the guestbook demo app we need to build a Docker image.

```
docker build -t tjozsa/node-guestbook .
```{{execute}}

`
docker run \
  --name guestbook \
  -p 8080:8080  \
  --network=course_stack \
  -d tjozsa/node-guestbook
`{{execute}}

### Generate some traffic through the Guestbook
Open the Guestbook and add some entries:

- [Guestbook](https://[[HOST2_SUBDOMAIN]]-8080-[[KATACODA_HOST]].environments.katacoda.com/)


#### Configure Kibana defaults

Need to set default index pattern.

#### Explore Data

If you made entries in the Guestbook earlier in the demo, you should be able to see these in the Kibana Discover app, and in the APM Dashboards. The Guestbook application relies on Redis to store data, and you will see the time it takes for each of the Redis commands related to storing and retrieving guestbook entries in the Redis cache.  Remember, we did not do anything to modify the standard Redis docker run command, the timings shown in the APM dashboard are from the perspective of the Node JS app that we instrumented.  Because this is the app that users interact with, it is crucial that we get our timings from the perspective of this app.

- [APM Dashboard](https://[[HOST2_SUBDOMAIN]]-5601-[[KATACODA_HOST]].environments.katacoda.com/app/apm#/guestbook/transactions)


## Metrics with metricbeat
If you want to get some metrics into kibana from this sandbox, I suggest using metricbeat and read Docker metrics.

Create new index `metricbeat-*` in elastic search.

```
docker run \
--net course_stack \
docker.elastic.co/beats/metricbeat:7.11.1 \
setup -E setup.kibana.host=kibana:5601 \
-E output.elasticsearch.hosts=["elasticsearch:9200"]
```{{execute}}

You need to configure metricbeats.

Get example configuration here: 

`curl -L -O https://raw.githubusercontent.com/elastic/beats/7.11/deploy/docker/metricbeat.docker.yml`{{execute}}


Start collecting metrics from docker runtime with metricbeats container:

```
docker run -d \
  --name=metricbeat \
  --net course_stack \
  --user=root \
  --volume="$(pwd)/metricbeat.docker.yml:/usr/share/metricbeat/metricbeat.yml:ro" \
  --volume="/var/run/docker.sock:/var/run/docker.sock:ro" \
  --volume="/sys/fs/cgroup:/hostfs/sys/fs/cgroup:ro" \
  --volume="/proc:/hostfs/proc:ro" \
  --volume="/:/hostfs:ro" \
  docker.elastic.co/beats/metricbeat:7.11.1 metricbeat -e \
  -E output.elasticsearch.hosts=["elasticsearch:9200"]
```{{execute}}