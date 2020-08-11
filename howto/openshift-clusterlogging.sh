# Chequeos de elasticsearch para Openshift

#how to forward logs to external rsyslog in openshift 4.3?
https://access.redhat.com/solutions/4931831

#Can't access to kibana in ocp4 http: TLS handshake error from IP: remote error: tls: unknown certificate authority
https://access.redhat.com/solutions/4963621

#Supported versions of EFK stack in OCP 3.x and OCP 4.x.
https://access.redhat.com/solutions/4850671

#Setting Fluentd pod logs to debug level in OCP 4.x
https://access.redhat.com/solutions/4661421

#Fluentd buffer logs are causing pod evictions in OpenShift 4
https://access.redhat.com/solutions/4801291

#Este ultimo problema es el que hemos tenido en ITAU y GIRE

#Ajustes avanzados: encontrar y resolver búsquedas lentas en Elasticsearch
https://www.elastic.co/es/blog/advanced-tuning-finding-and-fixing-slow-elasticsearch-queries

#DiskPressure due to 80 GB /var/lib/fluentd
https://bugzilla.redhat.com/show_bug.cgi?id=1780698

oc get pod fluentd-z8fx7 -o yaml |grep BUFFER -A 2
    - name: BUFFER_QUEUE_LIMIT
      value: "32"
    - name: BUFFER_SIZE_LIMIT
      value: 8m
    - name: FILE_BUFFER_LIMIT
      value: 256Mi
    - name: FLUENTD_CPU_LIMIT

oc exec fluentd-z8fx7 -- du -sh /var/lib/fluentd/clo_default_output_es/
7.7G	/var/lib/fluentd/clo_default_output_es/
 oc logs fluentd-ff8nn
2020-05-06 02:22:18 +0000 [warn]: [clo_default_output_es] failed to write data into buffer by buffer overflow action=:block

#Dashboard de Grafana para ElasticSearch
https://gitlab.com/rahasak-labs/prometheus-elasticsearch/-/blob/master/elastic-dashboard.json
https://medium.com/rahasak/monitor-elasticsearch-with-prometheus-and-grafana-687a0b6712

#Elasticsearch reporting IndexPrimaryShardNotAllocatedException and in RED state
https://access.redhat.com/solutions/3768141


# Consultar estado de cluster de ES
oc rsh $POD_NAME

export ES_ARGS="-s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca"

# Healh del cluster
curl $ES_ARGS https://localhost:9200/_cat/health?pretty

# Listar estado de los nodos
curl $ES_ARGS https://localhost:9200/_cat/nodes?pretty

# Verificar nodo master
curl $ES_ARGS https://localhost:9200/_cat/master?pretty

# Verificar estado de los indices
curl $ES_ARGS https://localhost:9200/_cat/indices?pretty

# Listar estado de los indices en estado red
curl $ES_ARGS https://localhost:9200/_cat/indices?pretty | awk '/red/ {print $3}'

# Listar estado de los indices en estado yellow
curl $ES_ARGS https://localhost:9200/_cat/indices?pretty | awk '/yellow/ {print $3}'

# Listamos los indices del día anterior (date --date='-1 day')
curl $ES_ARGS https://localhost:9200/_cat/indices/project.*.$(date --date='-1 day' +"%Y.%m.%d")

# Verificar estado de los shards
curl $ES_ARGS https://localhost:9200/_cat/shards?pretty

# Verificar los shards en estado UNASSIGNED
curl $ES_ARGS https://localhost:9200/_cat/shards?pretty | awk '/UNASSIGNED/ {print $0}'

# Verificar porque un shard esta en UNASSIGNED, completar con INDEX_NAME, nro de shard y si es primario o no
curl $ES_ARGS https://localhost:9200/_cluster/allocation/explain?pretty -H 'Content-Type: application/json' -d'
{
  "index": "INDEX_NAME",
  "shard": 0,
  "primary": true
}
'

# Aplicar politica de routing allocation enabled all
curl $ES_ARGS -X PUT https://localhost:9200/_cluster/settings?pretty -H 'Content-Type: application/json' -d'
{
    "transient" : {
        "cluster.routing.allocation.enable" : "all"
    }
}
'

# Rebalance de los shards en otro nodo
# NODE="YOUR NODE NAME"
IFS=$'\n'
for line in $(curl $ES_ARGS https://localhost:9200/_cat/shards' | fgrep UNASSIGNED); do
  INDEX=$(echo $line | (awk '{print $1}'))
  SHARD=$(echo $line | (awk '{print $2}'))
  curl -XPOST 'localhost:9200/_cluster/reroute' -d '{
     "commands": [
        {
            "allocate": {
                "index": "'$INDEX'",
                "shard": '$SHARD',
                "node": "'$NODE'",
                "allow_primary": true
          }
        }
    ]
  }'
'

# Backup y Restore
# TBD