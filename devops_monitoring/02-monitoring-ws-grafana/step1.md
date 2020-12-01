## Start Prometheus


Change directory to 
`cd workshop-prometheus-grafana`{{execute}}

# Starts Prometheus
`docker-compose up -d`{{execute}}

## 5 - Setup Grafana

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

