git clone --single-branch --branch step4 https://github.com/tjozsa/workshop-prometheus-grafana.git
docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
docker-compose -f workshop-prometheus-grafana/docker-compose.yml up -d

# cp -rf releasability-book/examples/cd-pipeline/demo-from-zero-to-delivery/docker/* .
# rm -rf releasability-book

#curl -LO https://katacoda.com/manuelpais/scenarios/01-from-zero-to-delivery/assets/demo-from-zero-to-delivery.tar
#tar -xf demo-from-zero-to-delivery.tar
#rm -f demo-from-zero-to-delivery.tar
