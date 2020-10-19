#!/bin/bash

# VARS
export ES_NS=$1
export ES_POD=$2
export ES_ARGS="-s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca"
#ES_POD=$(oc get po -l component=elasticsearch -n $ES_NS --no-headers -o jsonpath='{range .items[?(@.status.phase=="Running")]}{.metadata.name}{"\n"}{end}' | head -n1)

echo "=== HEALTH ==========================================================================================================="
oc exec -n $ES_NS $ES_POD -c elasticsearch -- curl -s $ES_ARGS https://localhost:9200/_cat/health?pretty

echo "=== NODES ==========================================================================================================="
oc exec -n $ES_NS $ES_POD -c elasticsearch -- curl -s $ES_ARGS $ES_ARGS https://localhost:9200/_cat/nodes?pretty

echo "=== MASTER ==========================================================================================================="
oc exec -n $ES_NS $ES_POD -c elasticsearch -- curl -s $ES_ARGS https://localhost:9200/_cat/master?pretty

echo "=== INDICES ==========================================================================================================="
oc exec -n $ES_NS $ES_POD -c elasticsearch -- curl -s $ES_ARGS https://localhost:9200/_cat/indices?pretty

echo "=== INDICES RED ==========================================================================================================="
oc exec -n $ES_NS $ES_POD -c elasticsearch -- curl -s $ES_ARGS https://localhost:9200/_cat/indices?pretty | awk '/red/ {print $3}'

echo "=== INDICES YELLOW ==========================================================================================================="
oc exec -n $ES_NS $ES_POD -c elasticsearch -- curl -s $ES_ARGS https://localhost:9200/_cat/indices?pretty | awk '/yellow/ {print $3}'

echo "=== SHARDS ==========================================================================================================="
oc exec -n $ES_NS $ES_POD -c elasticsearch -- curl -s $ES_ARGS https://localhost:9200/_cat/shards?pretty

echo "=== SHARDS UNASSIGNED ==========================================================================================================="
oc exec -n $ES_NS $ES_POD -c elasticsearch -- curl -s $ES_ARGS https://localhost:9200/_cat/shards?pretty | awk '/UNASSIGNED/ {print $0}'

echo "=== ALLOCATION ==========================================================================================================="
oc exec -n $ES_NS $ES_POD -c elasticsearch -- curl -s $ES_ARGS https://localhost:9200/_cat/allocation?pretty 