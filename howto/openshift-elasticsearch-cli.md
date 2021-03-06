# Openshfit ElasticSerach CLI

## Contexto

Un simple script para poder consultar elasticsearch desplegado dentro de openshift.

## Instalación

El script requiere el cliente por linea de comandos de Openshift. Definir la variable de entorno con la version del su clientes de Openshift `OCP_VERSION`

```bash
OCP_VERSION=4.4.9
echo "Openshfit Client Install..."
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-client-linux-${OCP_VERSION}.tar.gz
tar zxvf openshift-client-linux-${OCP_VERSION}.tar.gz -C /usr/bin
rm -f openshift-client-linux-${OCP_VERSION}.tar.gz /usr/bin/README.md
chmod +x /usr/bin/oc
ls -l /usr/bin/oc
```

```bash
curl -O https://raw.githubusercontent.com/gonzaloacosta/openshift-howto/master/howto/files/escli.sh
sudo mv escli.sh /usr/loca/bin/escli
sudo chmod +x /usr/local/bin/escli
```
Para poder hacer uso de script deben loguearse con el cliente oc.

```
oc login -u <user_name> https://api.<cluster_id>.<domain>:6443
```

## Sintaxis

### Elasticsearch CLI Help

```bash
$ escli help
---------------------------------------------------------------------------------------
ElasticSearch Command Help for Openshift Cluster
---------------------------------------------------------------------------------------
Params:
         escli.sh <subcommand> <argument1> <argument2>

Sub Commands:

         help
         info
         health
         indices
         deleteindice <indice>
         shards
         shardsunassigned
         start
         stop
         api <string>
         replicas <num_replica> <indice>

For more informacion RH KB:

- Troubleshooting ES on Openshift:
        https://access.redhat.com/articles/3136551

- Need to manually rebalance or reallocate primary shards on Elasticsearch nodes
        https://access.redhat.com/solutions/4079301

---------------------------------------------------------------------------------------
Gonzalo Acosta <gonzaloacostapeiro@gmail.com>
---------------------------------------------------------------------------------------
```

### ElasticSearch API + PATH

Donde el path que continúa al subcomando api es un path de una consulta la api de elasticsearch.

```bash
$ escli api _cat/
=^.^=
/_cat/allocation
/_cat/shards
/_cat/shards/{index}
/_cat/master
/_cat/nodes
/_cat/tasks
/_cat/indices
/_cat/indices/{index}
/_cat/segments
/_cat/segments/{index}
/_cat/count
/_cat/count/{index}
/_cat/recovery
/_cat/recovery/{index}
/_cat/health
/_cat/pending_tasks
/_cat/aliases
/_cat/aliases/{alias}
/_cat/thread_pool
/_cat/thread_pool/{thread_pools}
/_cat/plugins
/_cat/fielddata
/_cat/fielddata/{fields}
/_cat/nodeattrs
/_cat/repositories
/_cat/snapshots/{repository}
/_cat/templates
```

### ElasticSearch Health

```bash
$ escli health
------------------------------------------------------------------------------
Elasticseach Health Report
------------------------------------------------------------------------------
epoch      timestamp cluster       status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1598726276 18:37:56  elasticsearch green           3         3     60  30    0    0        0             0                  -                100.0%
------------------------------------------------------------------------------
Nodes
------------------------------------------------------------------------------
ip          heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
10.131.4.10           49          62  13    0.65    0.44     0.45 mdi       -      elasticsearch-cdm-hgpaknao-2
10.130.2.12           62          71  13    0.41    0.47     0.66 mdi       -      elasticsearch-cdm-hgpaknao-3
10.128.4.9            38          70  13    0.88    0.57     0.53 mdi       *      elasticsearch-cdm-hgpaknao-1
------------------------------------------------------------------------------
Master
------------------------------------------------------------------------------
id                     host       ip         node
Rt-9WtoCR0CrlPGpfmNSOQ 10.128.4.9 10.128.4.9 elasticsearch-cdm-hgpaknao-1
```


### ElasticSearch diskspace

```bash
$ escli diskspace
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvdbb      147G  6.5G  141G   5% /elasticsearch/persistent
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvdbk      147G  6.5G  141G   5% /elasticsearch/persistent
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvdbf      147G  6.5G  141G   5% /elasticsearch/persistent
```

### ElasticSearch indices

```bash
$ escli indices
health status index                        uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   audit-000003                 eyo5I7vgSuaqGDy6b5USEw   3   1          0            0      1.5kb           783b
green  open   app-000001                   5bGQO9XvTzSQj91PaWdi6w   3   1      10638            0      8.6mb          4.3mb
green  open   audit-000001                 ZovBGO1bTX22IQ4kCmZ2mg   3   1          0            0      1.5kb           783b
green  open   audit-000002                 GJ5NnOjlQUOe_hFjHuhmQg   3   1          0            0      1.5kb           783b
green  open   .kibana_1                    r907cwJJStSwspa51f3lGw   1   1          0            0       522b           261b
green  open   .kibana_-377444158_kubeadmin _N9qKP7ZRE6TYnoAIMwiEg   1   1          2            0     34.1kb           17kb
green  open   infra-000001                 qhc4NL3NToent04ONjmrGg   3   1    3916786            0        5gb          2.5gb
green  open   .security                    Toe_vrHtRFG5mBLRj0d3qg   1   1          5            0     59.9kb         29.9kb
green  open   app-000002                   iQLqGeeZQn-KJM6GeaUi1w   3   1       5759            0      4.7mb          2.4mb
green  open   infra-000003                 lC3ha76cT4uEYPqsp2y2Pg   3   1    1010765            0      1.5gb        789.8mb
green  open   infra-000002                 gb6uikOFTIG4FXhqnO3d2g   3   1    3244336            0      4.4gb          2.2gb
green  open   app-000003                   Rdg4nwUETEyonPmwaZkxiw   3   1       2073            0      2.3mb          1.2mb
[gonzalo.acosta-semperti.com@clientvm 0 ~]$
```

### ElasticSearch Shards

```bash
$ escli shards
index                        shard prirep state      docs   store ip          node
.kibana_1                    0     r      STARTED       0    261b 10.128.4.9  elasticsearch-cdm-hgpaknao-1
.kibana_1                    0     p      STARTED       0    261b 10.130.2.12 elasticsearch-cdm-hgpaknao-3
app-000001                   1     r      STARTED    3519   1.4mb 10.131.4.10 elasticsearch-cdm-hgpaknao-2
app-000001                   1     p      STARTED    3519   1.3mb 10.130.2.12 elasticsearch-cdm-hgpaknao-3
app-000001                   2     p      STARTED    3610   1.4mb 10.128.4.9  elasticsearch-cdm-hgpaknao-1
app-000001                   2     r      STARTED    3610   1.4mb 10.131.4.10 elasticsearch-cdm-hgpaknao-2
app-000001                   0     p      STARTED    3509   1.4mb 10.128.4.9  elasticsearch-cdm-hgpaknao-1
app-000001                   0     r      STARTED    3509   1.4mb 10.130.2.12 elasticsearch-cdm-hgpaknao-3
infra-000001                 1     r      STARTED 1305678 865.3mb 10.128.4.9  elasticsearch-cdm-hgpaknao-1
infra-000001                 1     p      STARTED 1305678 866.7mb 10.130.2.12 elasticsearch-cdm-hgpaknao-3
infra-000001                 2     r      STARTED 1305097 866.4mb 10.128.4.9  elasticsearch-cdm-hgpaknao-1
infra-000001                 2     p      STARTED 1305097 867.1mb 10.131.4.10 elasticsearch-cdm-hgpaknao-2
infra-000001                 0     p      STARTED 1306011 865.5mb 10.131.4.10 elasticsearch-cdm-hgpaknao-2
infra-000001                 0     r      STARTED 1306011 868.4mb 10.130.2.12 elasticsearch-cdm-hgpaknao-3
audit-000002                 1     r      STARTED       0    261b 10.131.4.10 elasticsearch-cdm-hgpaknao-2
audit-000002                 1     p      STARTED       0    261b 10.130.2.12 elasticsearch-cdm-hgpaknao-3
audit-000002                 2     p      STARTED       0    261b 10.128.4.9  elasticsearch-cdm-hgpaknao-1
audit-000002                 2     r      STARTED       0    261b 10.131.4.10 elasticsearch-cdm-hgpaknao-2
audit-000002                 0     p      STARTED       0    261b 10.128.4.9  elasticsearch-cdm-hgpaknao-1
....
```

### ElasticSearch Shards Unassigned

```bash
$ escli shards
```

Para poder evaluar las razones de porque los indices se encuentran en UNASSIGNED ver las siguientes notas.

- [Troubleshooting ES on Openshift](https://access.redhat.com/articles/3136551)
- [Need to manually rebalance or reallocate primary shards on Elasticsearch nodes](https://access.redhat.com/solutions/4079301)

### ElasticSearch Info

~~~bash
$ escli info
~~~