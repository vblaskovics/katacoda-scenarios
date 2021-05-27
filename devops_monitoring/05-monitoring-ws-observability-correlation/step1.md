## Install Docker Loki logger plugin

`docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions`{{execute}}

## Start Docker Compose

`cd tempo-springboot-example`{{execute}}

`docker-compose -f stack.yml up -d`{{execute}}

## Check to see if all components started

`docker-compose -f stack.yml ps`{{execute}}

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


## Test out the correlation

Navigate to [Grafana](http://localhost:3000/explore?orgId=1&left=%5B%22now-1h%22,%22now%22,%22Loki%22,%7B%7D%5D) and **query Loki a few times to generate some traces** (this setup does not use the synthetic load generator and all traces are generated from Loki).
Something like the below works, but feel free to explore other options!
```
{container_name="dockercompose_loki_1"}
```

> Note: When running docker-compose on a MacBook, the `container_name` would be `docker-compose_loki_1`.

Now let's execute a query specifically looking for some trace ids.  In an operational scenario you would normally be using Loki to search for things like
query path, or status code, but we're just going to do this for the example:

```
{container_name="dockercompose_loki_1"} |= "traceID"
```

> Note: When running docker-compose on a MacBook, the `container_name` would be `docker-compose_loki_1`.

Drop down the log line and click the Tempo link to jump directly from logs to traces!

![Tempo link](./tempo-link.png)


## Now we need an application to see logs traces and metrics of the Real World!

Let's add the OpenTelemetry Hot R.O.D. example to our compose environment.

<pre class="file" data-filename="tempo/example/compose/docker-compose.loki.yaml" data-target="append">
  hotrod:
    image: jaegertracing/example-hotrod:latest
    ports: 
      - "8080:8080"
    command: ["all"]
    environment:
      - JAEGER_AGENT_HOST=tempo
      # Note: if your application is using Node.js Jaeger Client, you need port 6832,
      #       unless issue https://github.com/jaegertracing/jaeger/issues/1596 is resolved.
      - JAEGER_AGENT_PORT=6832
    logging:
      driver: loki
      options:
        loki-url: 'http://localhost:3100/api/prom/push'
</pre>

`docker-compose -f docker-compose.loki.yaml up -d`{{execute}}

## Other Demoable things

### Metrics -> Logs -> Traces
- Go to the TNS dashboard
- Zoom in on a section with failed requests if you are so inclined
- Panel Drop Down -> Explore
- Datasource Drop Down -> Loki
- Choose a log line with a traceID -> Tempo

### Metrics -> Traces -> Logs
- Go to Explore
- Choose Datasource prometheus-exemplars
- Run this query `histogram_quantile(.99, sum(rate(tns_request_duration_seconds_bucket{}[1m])) by (le))`
- Click an exemplar
- Click the log icon on a span line

### LogQLV2
- Go to Explore
- Choose Datasource Loki
- Run this query `{job="tns/app", level="info"} | logfmt | status>=500 and status <=599 and duration > 50ms`
- Choose a log line with a traceID -> Tempo

## More information

Following instructions here: https://github.com/grafana/tns/
