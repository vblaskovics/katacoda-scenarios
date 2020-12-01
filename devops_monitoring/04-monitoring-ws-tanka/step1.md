## Prerequsites

`curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"`{{execute}}

`chmod +x ./kubectl`{{execute}}

`sudo mv ./kubectl /usr/local/bin/kubectl`{{execute}}

`kubectl version --client`{{execute}}

`wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash`{{execute}}

## getting lab sources

`git clone https://github.com/grafana/tns`{{execute}}

`cd tns`{{execute}}

## install lab

`./create-k3d-cluster`{{execute}}

`export KUBECONFIG=$(k3d kubeconfig write tns)`{{execute}}

`./install`{{execute}}

`kubectl get pods -A`{{execute}}

## Access the demo 

You should now be able to access the demo via http://localhost:8080/.


## Demoable things

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
