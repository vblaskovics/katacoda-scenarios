## Let's grab some system metrics (memory, CPU, disk...)

Update `workshop-prometheus-grafana/prometheus.yml`{{open}} config file, to scrape node-exporter metrics every 10 seconds.

<pre class="file" data-filename="workshop-prometheus-grafana/prometheus.yml" data-target="insert"  data-marker="#NODEEXPORTER">  - job_name: 'node-exporter'
    scrape_interval: 10s
    static_configs:
      - targets: ['node-exporter:9100']
</pre>

This is how the file should look like when you are done editing it.

```
#
# /etc/prometheus/prometheus.yml
#

global:
  scrape_interval: 30s

scrape_configs:
  - job_name: 'node-exporter'
    scrape_interval: 10s
    static_configs:
      - targets: ['node-exporter:9100']
```

## 1 - Metrics types

Take a look on Prometheus metric types (counter, gauges, histogram, summary) => [https://prometheus.io/docs/concepts/metric_types/](https://prometheus.io/docs/concepts/metric_types/)

## 2 - Start node exporter

```
# Starts Prometheus
docker-compose up -d prometheus

# Starts system metrics exporter
docker-compose up -d node-exporter
```

- Prometheus console: [http://localhost:9090](http://localhost:9090).
- Full list of ingested metrics: [http://localhost:9090/graph](http://localhost:9090/graph).
- `node-exporter` metrics: [http://localhost:9100/metrics](http://localhost:9100/metrics).

## 3 - 

Update `prometheus.yml` config file, to scrape node-exporter metrics every 10 seconds. 🚀

<details>
  <summary>💡 Solution</summary>



</details>

## 4 - Execute your first PromQL query

**PromQL documentation**:

- basic: [https://prometheus.io/docs/prometheus/latest/querying/basics/](https://prometheus.io/docs/prometheus/latest/querying/basics/)

- advanced: [https://prometheus.io/docs/prometheus/latest/querying/functions/](https://prometheus.io/docs/prometheus/latest/querying/functions/)

### 4.0 - Memory usage

Go to [http://localhost:9090/graph](http://localhost:9090/graph) and write a query displaying a graph of free memory on your OS.

Metric name is `node_memory_MemFree_bytes`.

<details>
  <summary>💡 Solution</summary>

  Query: `node_memory_MemTotal_bytes{}`
</details>

### 4.1 - Human readable

Same metric but in GigaBytes ?

<details>
  <summary>💡 Solution</summary>

  Query: `node_memory_MemTotal_bytes{} / 1024 / 1024 / 1024`
</details>


### 4.2 - Relative to total memory

Same metric, but in percent of total available memory ?

Tips: `node-exporter` metrics are prefixed by `node_`.

<details>
  <summary>💡 Solution</summary>

  Query: `(node_memory_MemTotal_bytes{} - node_memory_MemFree_bytes{}) / node_memory_MemTotal_bytes{} * 100`
</details>