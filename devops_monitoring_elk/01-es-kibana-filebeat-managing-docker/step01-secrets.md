### Network

Create a network shared between the app and the Elastic Stack:

`docker network create course_stack`{{execute HOST1}}

### Deploy Elasticsearch 

This docker run command deploys a development Elasticsearch instance.  You can read more at https://www.elastic.co/guide/en/elasticsearch/reference/7.x/docker.html

`
docker run -d \
  --name=elasticsearch \
  --env="discovery.type=single-node" \
  --env="ES_JAVA_OPTS=-Xms256m -Xmx256m" \
  --network=course_stack \
  -p 9300:9300 -p 9200:9200 \
  --health-cmd='curl -s -f http://localhost:9200/_cat/health' \
  docker.elastic.co/elasticsearch/elasticsearch:7.12.0
`{{execute HOST1}}

### Check the health / readiness of Elasticsearch

In the run command that you just ran, there is a health check defined.  This connects to the cluster health API of Elasticsearch.  In the output of the following command you will see the test result.  Wait until it returns a healthy response before deploying Kibana.  You may have to run this command several times as it takes a minute or two to download Elasticsearch and then it takes another minute for the process to get to the ready state the first time.

`docker inspect elasticsearch | grep -A8 Health`{{execute HOST1}}

### Deploy Kibana

This docker run command starts Kibana with the default configuration.  If you want to customize the configuration you can pass in environment variables or mount a configuration file.  There is more information about running the official Kibana Docker container at https://www.elastic.co/guide/en/kibana/6.4/docker.html 

`
docker run -d \
  --name=kibana \
  --user=kibana \
  --network=course_stack -p 5601:5601 \
  --health-cmd='curl -s -f http://localhost:5601/login' \
  docker.elastic.co/kibana/kibana:7.12.0
`{{execute HOST1}}

### Check the health / readiness of Kibana

In the run command that you just ran, there is a health check defined.  This connects to Kibana and ensures that it is available. In the output of the following command you will see the test result.  Wait until it returns a healthy response before deploying Beats, as the Beats need to connect to both Elasticsearch and Kibana to install the modules that customize the experience related to the apps you are running (NGINX, Apache HTTPD, etc.).

`docker inspect kibana | grep -A8 Health`{{execute HOST1}}

### Start Filebeat

Before you start Filebeat, have a look at the configuration.  The hints based autodiscover feature is enabled by uncommenting a few lines of the filebeat.yml, so we will bind mount it in the Docker run command.  Use grep to see the lines that enable hints based autodiscover:

`grep -A4 filebeat.autodiscover course/filebeat.yml`{{execute HOST1}}

And now start Filebeat:

`docker run -d \
--net course_stack \
--name=filebeat \
--user=root \
--volume="/var/lib/docker/containers:/var/lib/docker/containers:ro" \
--volume="/root/course/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro" \
--volume="/var/run/docker.sock:/var/run/docker.sock:ro" \
docker.elastic.co/beats/filebeat:7.12.0 filebeat -e -strict.perms=false`{{execute HOST1}}

### Start NGINX
`docker run -d \
--net course_stack \
--label co.elastic.logs/module=nginx \
--label co.elastic.logs/fileset.stdout=access \
--label co.elastic.logs/fileset.stderr=error \
--name nginx \
-p 81:80 nginx`{{execute HOST1}}

Note in the NGINX run command there are three labels, these labels are available in the Docker environment, and Filebeat detects them and configures itself.  The three labels tell Filebeat that the module name **nginx** should be used to collect, parse, and visualize the logs from this container, and that the access logs are at STDOUT, while the error logs are at STDERR.
You can see these labels with the command:

`docker inspect nginx | grep -A4 Labels`{{execute HOST1}}

### Generate some traffic through NGINX
At the top of the terminal you will see an NGINX tab.  Click on that and you will see the default NGINX page.  Add a page name to the URL, for example /foo, and this will generate a 404 error.  Now return to the Katacoda tab and click on the Kibana tab above the terminal.  Open the Dashboards and search for nginx, click on the Filebeat NGINX overview.

### Interact with your data in the Kibana dashboard
At the top of the terminal you will see a Kibana tab.  Click on that and you will see the default Kibana page. Open the **Dashboards** app in the left navigation of Kibana and search for nginx, click on the Filebeat NGINX overview.
