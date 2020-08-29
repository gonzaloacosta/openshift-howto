# Openshfit ElasticSerach CLI

## Contexto
Un simple script para poder consultar elasticsearch desplegado dentro de openshift.

## Instalación

```bash
curl -O https://raw.githubusercontent.com/gonzaloacosta/openshift-howto/master/howto/files/escli.sh
sudo mv escli.sh /usr/loca/bin/escli
sudo chmod +x /usr/local/bin/escli
```

## Sintaxis

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
         tasks
         threadpools
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

