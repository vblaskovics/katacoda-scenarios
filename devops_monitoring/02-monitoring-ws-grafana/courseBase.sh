git clone --single-branch --branch step2 https://github.com/tjozsa/workshop-prometheus-grafana.git
mv -f workshop-prometheus-grafana/prometheus_1.yml workshop-prometheus-grafana/prometheus.yml
mv -f workshop-prometheus-grafana/docker-compose_1.yml workshop-prometheus-grafana/docker-compose.yml
# cp -rf releasability-book/examples/cd-pipeline/demo-from-zero-to-delivery/docker/* .
# rm -rf releasability-book

#curl -LO https://katacoda.com/manuelpais/scenarios/01-from-zero-to-delivery/assets/demo-from-zero-to-delivery.tar
#tar -xf demo-from-zero-to-delivery.tar
#rm -f demo-from-zero-to-delivery.tar
