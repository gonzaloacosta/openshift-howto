#!/bin/bash
##############################################################
#
# Elasticsearch para Openshift
#
##############################################################

# Variables

ARG1=$1
ARG2=$2
ARG3=$3
es_ns="openshift-logging"
es_pod=$(oc get po -l component=elasticsearch -n $es_ns --no-headers -o jsonpath='{range .items[?(@.status.phase=="Running")]}{.metadata.name}{"\n"}{end}' | head -n1)


# Functions

get_help() { 

    echo "---------------------------------------------------------------------------------------"
    echo "ElasticSearch Command Help for Openshift Cluster"
    echo "---------------------------------------------------------------------------------------"
    echo "Params:"
    echo "         escli.sh <subcommand> <argument1> <argument2>"
    echo ""
    echo "Sub Commands:"
    echo ""
    echo "         help"
    echo "         info"
    echo "         health"
    echo "         indices"
    echo "         deleteindice <indice>"
    echo "         shards"
    echo "         shardsunassigned"
    echo "         start"
    echo "         stop"
    echo "         pendingtasks"
    echo "         api <string>"
    echo "         replicas <num_replica> <indice>"
    echo ""
    echo "For more informacion RH KB:"
    echo "- Troubleshooting ES on Openshift: "
    echo "  	https://access.redhat.com/articles/3136551"
    echo "- Need to manually rebalance or reallocate primary shards on Elasticsearch nodes"
    echo "	https://access.redhat.com/solutions/4079301"
    echo ""
    echo "---------------------------------------------------------------------------------------"
    echo "Gonzalo Acosta <gonzaloacostapeiro@gmail.com>"
    echo "---------------------------------------------------------------------------------------"
}


get_info() {

    echo "---------------------------------------------------------------------------------------"
    echo "ElasticSearch Command Help for Openshift Cluster"
    echo "---------------------------------------------------------------------------------------"
    echo ""
    echo "Indices"
    echo ""
    echo "- RED state means that at least one index is in RED state (it's primary shard has not" 
    echo "  been recovered) or that the minimum amount of Elasticsearch nodes has not reached "
    echo "  (i.e. CUORUM). Writes are not allowed, cluster is not accessible."
    echo "- YELLOW state means that all indices are at least in this same state, which means "
    echo "  that at least one replica shard is not assigned/recovered."
    echo "- GREEN: All ES nodes are running and all indices are fully recovered."
    echo ""
    echo "  The health query will show things like the pending tasks in case it is recovering, the "
    echo "  number of shards, the percent of active shards and the unassigned shards."
    echo ""
    echo "Indice Standard Name"
    echo ""
    echo "Indices. By default the indices API query will show the health, status, documents and"
    echo "size data about each index. It is useful to know what to expect here. Some relevant index"
    echo "names are:"
    echo "- .kibana - Contains user information like predefined searches, dashboards and other settings"
    echo "- .searchguard.<pod_name> - Contains security information regarding SearchGuard initialization."
    echo "  It MUST contain 5 documents"
    echo "- .operations.YYYY.MM.DD - Logs coming from operations projects like default. This will only "
    echo "  appear on logging-ops cluster if it exists"
    echo "  project.<project_name>.<uuid>.YYYY.MM.DD - Project related index created by day containing"
    echo "  all logs related to that project for that day"
    echo "" 
    echo "Nodes Status"
    echo ""
    echo "Will show basic information about all the nodes forming the cluster, who is the master"
    echo "(marked with *), their name and also the percent of RAM used out of the total available"
    echo "along with the HEAP percent used out of the total RAM used. Dont get confused when you "
    echo "see high values of RAM percent because this is the maximum available to be used by the HEAP."
    echo "An indicator of being low in memory is having a high HEAP percent close to the ram.percent "
    echo "which will require allocating more RAM"
    echo ""
    echo "For more informacion RH KB:"
    echo "- Troubleshooting ES on Openshift: "
    echo "  	https://access.redhat.com/articles/3136551"
    echo "- Need to manually rebalance or reallocate primary shards on Elasticsearch nodes"
    echo "	https://access.redhat.com/solutions/4079301"
    echo "" 
    echo "---------------------------------------------------------------------------------------"
    echo "Gonzalo Acosta <gonzaloacostapeiro@gmail.com>"
    echo "---------------------------------------------------------------------------------------"
}


# Main

if [[ $ARG1 == "api" ]] ; then
    
    oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca https://localhost:9200/${ARG2}

elif [[ $ARG1 == "stop" ]] ;  then

    # Patch operator from Managed to Unmanaged
    oc patch clusterlogging  instance --type=merge --patch='{"spec":{"managementState":"Unmanaged"}}'

    # Scale down to 0 all the DCs
    for deployment in $(oc get deployment -o=name -l component=elasticsearch -n $es_ns); do oc scale $deployment --replicas=0 -n $es_ns; done

    # Confirm all logging-es pods are terminated
    oc get po --selector=component=es -n openshift-logging

elif [[ $ARG1 == "start " ]] ; then

    for deployment in $(oc get deployment -o=name -l component=elasticsearch -n $es_ns); do oc scale $deployment --replicas=1 -n $es_ns; done

    #oc patch clusterlogging  instance --type=merge --patch='{"spec":{"managementState":"Managed"}}'

    oc get po --selector=component=es -n openshift-logging

elif [[ $ARG1 == "indices" ]] ; then

    oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca https://localhost:9200/_cat/indices?v

elif [[ $ARG1 == "shards" ]] ; then

    oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca https://localhost:9200/_cat/shards?v

elif [[ $ARG1 == "shardsunassigned" ]] ; then
    
    oc exec $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca https://localhost:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason,node | grep UNASSIGNED

elif [[ $ARG1 == "imageversion" ]] ; then

    oc get po -n $es_ns -o 'go-template={{range $pod := .items}}{{if eq $pod.status.phase "Running"}}{{range $container := $pod.spec.containers}}oc exec -n openshift-logging -c {{$container.name}} {{$pod.metadata.name}} -- find /root/buildinfo 
-name Dockerfile-openshift* | grep -o logging.* {{"\n"}}{{end}}{{end}}{{end}}' | bash -

elif [[ $ARG1 == "deleteindice" ]] ; then

    echo -n "Proceed to delete indice: $ARG2? [y/n]: "
    
    read ans

    if [[ $ans == "y" || $ans == "yes" ]]; then
        
        oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca -XDELETE https://localhost:9200/$ARG2

    else

        echo "Do not delete any indice with name: $ARG2"

    fi

#elif [[ $ARG1 == "replicas" ]] ; then

    # One Indice
    #oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca -XPUT https://localhost:9200/$ARG3/_settings -d '{ "index" : { "number_of_replicas" : 2 } }'
    #oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca -XPUT https://localhost:9200/$ARG3/_settings -d "'"{ "index" : { "number_of_replicas" : $ARG2 } }"'"

    # Change number of replicas to ALL indices
    #oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca -XPUT https://localhost:9200/*/_settings -d '{ "index" : { "number_of_replicas" : 2 } }

elif [[ $ARG1 == "health" ]] ; then

    echo "------------------------------------------------------------------------------"
    echo "Elasticseach Health Report"
    echo "------------------------------------------------------------------------------"
    oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca https://localhost:9200/_cat/health?v

    echo "------------------------------------------------------------------------------"
    echo "Nodes"
    echo "------------------------------------------------------------------------------"
    oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca https://localhost:9200/_cat/nodes?v
    
    echo "------------------------------------------------------------------------------"
    echo "Master"
    echo "------------------------------------------------------------------------------"
    oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca https://localhost:9200/_cat/master?v    

elif [[ $ARG1 == "pendingtasks" ]] ; then

    oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca https://localhost:9200/_cluster/pending_tasks?v

#elif [[ $ARG1 == "threadpool" ]] ; then

#    oc exec -n $es_ns $es_pod -c elasticsearch -- curl -s --key /etc/elasticsearch/secret/admin-key --cert /etc/elasticsearch/secret/admin-cert --cacert /etc/elasticsearch/secret/admin-ca https://localhost:9200/_cluster/thread_pool?v

elif [[ $ARG1 == "info" ]] ; then

    get_info

elif [[ $ARG1 == "help" ]] ; then

    get_help

else 

    get_help

fi

