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

## Start node-exporter

The `workshop-prometheus-grafana/docker-compose.yml`{{open}} file contains another container definition called node-exporter. Take a look. This container is responsible to collect the server metrics on-demand. To trigger the collection of metrics you need to visit the built in web server. Once a GET request is received the node-exporter application will collect and return all metrics in a text document.

```
docker-compose up -d node-exporter
```{{execute}}

```
docker-compose restart prometheus
```{{execute}}

Try out the node exporter here:

https://[[HOST_SUBDOMAIN]]-9100-[[KATACODA_HOST]].environments.katacoda.com/metrics

The prometehus service will visit this endpoint periodically and downloads the merics. The mertics are stored in a Time Series database of the Prometheus DB.

## Check out Prometheus metrics types

Take a look on Prometheus metric types (counter, gauges, histogram, summary) => [https://prometheus.io/docs/concepts/metric_types/](https://prometheus.io/docs/concepts/metric_types/)

Visit the prometheus UI to check if the prometheus service processed the node-exporter metrics endpoint:
https://[[HOST_SUBDOMAIN]]-9090-[[KATACODA_HOST]].environments.katacoda.com/targets

Visit the prometheus UI to create PromQL queries and display them in form of table or graph.
https://[[HOST_SUBDOMAIN]]-9090-[[KATACODA_HOST]].environments.katacoda.com/graph

## PromQL query hello world

**PromQL documentation**:

- basic: 

[https://prometheus.io/docs/prometheus/latest/querying/basics/](https://prometheus.io/docs/prometheus/latest/querying/basics/)

- advanced: 

[https://prometheus.io/docs/prometheus/latest/querying/functions/](https://prometheus.io/docs/prometheus/latest/querying/functions/)

- histogram vs summary

[https://prometheus.io/docs/practices/histograms/]

### Check Memory usage

Go to [http://localhost:9090/graph](http://localhost:9090/graph) and write a query displaying a graph of free memory on your OS.

Metric name is `node_memory_MemFree_bytes`.

<details>
  <summary>💡 Solution</summary>

  Query: `node_memory_MemTotal_bytes{}`
</details>

### Human readable

Same metric but in GigaBytes ?

<details>
  <summary>💡 Solution</summary>

  Query: `node_memory_MemTotal_bytes{} / 1024 / 1024 / 1024`
</details>


### Relative to total memory

Same metric, but in percent of total available memory ?

Tips: `node-exporter` metrics are prefixed by `node_`.

<details>
  <summary>💡 Solution</summary>

  Query: `(node_memory_MemTotal_bytes{} - node_memory_MemFree_bytes{}) / node_memory_MemTotal_bytes{} * 100)`
</details>