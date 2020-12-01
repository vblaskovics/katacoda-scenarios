## Start Prometheus

Change directory to 
```
cd workshop-prometheus-grafana
```

```
# Starts Prometheus
docker-compose up -d prometheus

# Starts system metrics exporter
docker-compose up -d node-exporter
```

## Setup Grafana

Uncomment grafana in docker-compose.yml and launch it:

```
docker-compose up -d grafana
```

Open [http://localhost:3000](http://localhost:3000) (user: grep / pass: demo).

Add a new datasource to Grafana.

- Mode: `server`
- Pointing to http://prometheus:9090

![](imgs/grafana-setup-datasource.png)

## 6 - Hand-made dashboard

Add a new dashboard to Grafana.

### 6.0 - Simple graph

Create a graph showing current memory usage.

<details>
  <summary>💡 Solution</summary>

  Query: `(node_memory_MemTotal_bytes{} - node_memory_MemFree_bytes{}) / node_memory_MemTotal_bytes{} * 100`

  ![](imgs/grafana-new-metric.png)
</details>

### 6.1 - Some formatting

Grafana should be displaying graph in %, such as:

![](imgs/grafana-graph-percent.png)

<details>
  <summary>💡 Solution</summary>

  ![](imgs/grafana-set-unit.png)
</details>

### 6.2 - CPU load

In the same dashboard, add a new graph for CPU load (1min, 5min, 15min).

Tips: you will need a new metric prefixed by `node_`.

![](imgs/grafana-cpu-load.png)

<details>
  <summary>💡 Solution</summary>

  ![](imgs/grafana-set-cpu-load-metrics.png)
</details>

### 6.3 - Disk usage

In the same dashboard, add a new graph for `sda` disk usage (ko written per second).

You will need `rate()` PromQL function: [https://prometheus.io/docs/prometheus/latest/querying/functions/#rate](https://prometheus.io/docs/prometheus/latest/querying/functions/#rate)

![](imgs/grafana-disk-load.png)

<details>
  <summary>💡 Solution</summary>

  Query:
  `rate(node_disk_written_bytes_total{device="sda"}[30s])`

</details>

## 7 - Dashboards from community

Let's import a dashboard from Grafana website.

- "Node Exporter Full" dashboard: [https://grafana.com/dashboards/1860](https://grafana.com/dashboards/1860)
- Or "Node Exporter Server Metrics" dashboard: [https://grafana.com/dashboards/405](https://grafana.com/dashboards/405)
- Or both ;)

Those dashboards are only compatible with Prometheus data-source and node-exporter.

![](imgs/grafana-community-dash.png)

## 8 - Monitor services: nginx, postgresql...

### 8.1 - Export Nginx and PostgreSQL metrics

Uncomment `postgres`, `postgresql-exporter` and `nginx-exporter` services in docker-compose.yml, and launch containers.

```
docker-compose up -d nginx-exporter
docker-compose up -d postgres postgresql-exporter
```

Update Prometheus configuration to scrape Nginx and PostgreSQL exporters.

<details>
  <summary>💡 Solution</summary>

  ```yml
scrape_config:

  [...]

  - job_name: 'postgresql-exporter'
    static_configs:
      - targets: ['postgresql-exporter:9187']

  - job_name: 'nginx-exporter'
    static_configs:
      - targets: ['nginx-exporter:9101']
  ```

  Then `docker-compose exec prometheus kill -HUP 1`
</details>

Check everything is working well here: [http://localhost:9090/targets](http://localhost:9090/targets)

Take a look on `/metrics` routes of exporters: [http://localhost:9187/metrics](http://localhost:9187/metrics) + [http://localhost:9101/metrics](http://localhost:9101/metrics)

### 8.2 - Generate some metrics

Send tens of requests to Nginx on localhost:8080 (200, 404...) and fill PostgreSQL database:

```sh
# 2xx
./infinite-200-req.sh

# 4xx
./infinite-404-req.sh
```

```sh
# inserts data into pg
./infinite-pg-insert.sh
```

### 8.3 - Import PG dashboards to Grafana

Go on [https://grafana.com/dashboards](https://grafana.com/dashboards) and find a dashboard for PostgreSQL, compatible with Prometheus and wrouesnel/postgres_exporter.

<details>
  <summary>💡 Solution</summary>

  Those exporters looks nice: [https://grafana.com/dashboards/6742](https://grafana.com/dashboards/6742), [https://grafana.com/dashboards/6995](https://grafana.com/dashboards/6995).

</details>

### 8.4 - Create Nginx dashboards

Display 2 graphs:

- number of 2xx http requests per second

- number of 4xx http requests per second

Tips: you should use `sum by(<label>) (<metric>)` and `irate(<metric>)` (cf PromQL doc).

![](imgs/grafana-nginx-404.png)

<details>
  <summary>💡 Solution</summary>

  Query graph 1: `sum by (status) (irate(nginx_http_requests_total{status=~"2.."}[1m]))`

  Legend graph 1: `Status: {{ status }}`

  Query graph 2: `sum by (status) (irate(nginx_http_requests_total{status=~"4.."}[1m]))`

  Legend graph 2: `Status: {{ status }}`

</details>

## 9 - Export some business metrics

Let's display in real time:

- number of users
- number of posts per user

### 9.0 - Export data

Grab custom metrics with `postgresql-exporter` by adding queries to `custom-queries.yml`:

- Metric `user_count` of type `counter` => `SELECT COUNT(*) FROM users;`
- Metric `post_per_user_count` of type `gauge` with user_id and email in labels => `SELECT u.id, u.email, COUNT(*) FROM posts p JOIN users u ON u.id = p.user_id GROUP BY u.id;`

Example and syntax [here](https://github.com/wrouesnel/postgres_exporter/blob/master/queries.yaml).

[http://localhost:9187/metrics](http://localhost:9187/metrics) should output:

```
[...]

# HELP user_count_count Number of users
# TYPE user_count_count counter
user_count_count 2

# HELP post_per_user_count_count Number of posts per user
# TYPE post_per_user_count_count gauge
post_per_user_count_count{email="foobar@gmail.com",id="e1c10ca1-60c8-405c-a9f3-3ff41456ca9f"} 1
post_per_user_count_count{email="samuel@grep.to",id="fde08ee6-5fb9-4c4f-9b40-dc2ad69bb855"} 2

[...]
```

<details>
  <summary>💡 Solution</summary>

  Append to `custom-queries.yml`:

```yaml
user:
  query: "SELECT COUNT(*) FROM users;"
  metrics:
    - count:
        usage: "COUNTER"
        description: "Number of users"

post_per_user:
  query: "SELECT u.id, u.email, COUNT(*) FROM posts p JOIN users u ON u.id = p.user_id GROUP BY u.id;"
  metrics:
    - count:
        usage: "GAUGE"
        description: "Number of posts per user"
    - id:
        usage: "LABEL"
        description: "User id"
    - email:
        usage: "LABEL"
        description: "User email"

```

</details>

### 9.1 - Graph time!

With `user_count{}` and `post_per_user_count{id,email}` metrics, build following graphs:

Simple graph of users signup (`rate(<metric>)`):

![assets/grafana-user-signups.png](assets/grafana-user-signups.png)

Heatmap of signups (`increase(<metric>)`):

```
docker-compose exec grafana grafana-cli plugins install petrslavotinek-carpetplot-panel
docker-compose restart grafana
```

![](imgs/grafana-heatmap-signups.png)

Table of top 10 users per post count (`topk()`, `sum by(<label>) (<metric>)`):

![](imgs/grafana-table-top-contributors.png)

<details>
  <summary>💡 Solution</summary>

  Query 1: `rate(user_count{}[1m])`

  Query 2: `increase(user_count{}[$__interval]) > 0`

  Query 3: `topk(10, sum by (id, email) (post_per_user_count{}) > 0)`

</details>

### 9.2 - Expose /metrics from a micro-service

You can play with this sample in NodeJS: [microservice-demo/README.md](microservice-demo/README.md).

Don't forget to update Prometheus configuration in `prometheus.yml` !

## 42 - More

- Monitor a Redis server, a RabbitMQ cluster, Mysql...
- Increase data retention (15d by default).
- Setup alerting with AlertManager and basic rules
- Setup Prometheus service discovery (consul, etc, dns...) to import configuration automatically
- Limits: multitenancy - partitionning/sharding - scaling - cron tasks
