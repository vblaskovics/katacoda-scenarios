## Install Docker Loki logger plugin

`docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions`{{execute}}

## Start Docker Compose

`cd tempo-springboot-example`{{execute}}

`docker-compose up -d`{{execute}}

## Check to see if all components started

`docker-compose ps`{{execute}}

You should see similar output:
```bash
            Name                          Command               State            Ports
------------------------------------------------------------------------------------------------
docker-compose_grafana_1       /run.sh                          Up      0.0.0.0:3000->3000/tcp
docker-compose_loki_1          /usr/bin/loki -config.file ...   Up      0.0.0.0:3100->3100/tcp
docker-compose_prometheus_1    /bin/prometheus --config.f ...   Up      0.0.0.0:9090->9090/tcp
docker-compose_tempo-query_1   /go/bin/query-linux --grpc ...   Up      0.0.0.0:16686->16686/tcp
docker-compose_tempo_1         /tempo -storage.trace.back ...   Up      0.0.0.0:32774->14268/tcp
```

### Step 5 - Exercise the API
`curl http://localhost:8080/TianMiao/api/users`{{execute}}

`curl -X POST -H 'Content-Type: application/json' -d '{"username": "test"}'  http://localhost:8080/TianMiao/api/users`{{execute}}

`curl http://localhost:8080/TianMiao/api/users/1`{{execute}}

`curl -X PUT -H 'Content-Type: application/json' -d '{"username": "newUser"}' http://localhost:8080/TianMiao/api/notes/`{{execute}}

### Step 6 - Find some traces!

1. Open https://[[HOST_SUBDOMAIN]]-3000-[[KATACODA_HOST]].environments.katacoda.com and make sure that Loki is selected.
1. Search for `{container_name="tomcat_service"} |= "/api"`
1. Expand a log line and click the Tempo button to see the trace!