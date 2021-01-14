=== Manage OpenShift Nodes

=== Machines config

MachineConfig representan un "Kubernetes Machine" que puede correr workload del cluster.

----
$ oc get machines -n openshift-machine-api
NAME                                         PHASE     TYPE        REGION      ZONE         AGE
cluster-41bf-fbs46-master-0                  Running   m4.xlarge   us-east-2   us-east-2a   90m
cluster-41bf-fbs46-master-1                  Running   m4.xlarge   us-east-2   us-east-2b   90m
cluster-41bf-fbs46-master-2                  Running   m4.xlarge   us-east-2   us-east-2c   90m
cluster-41bf-fbs46-worker-us-east-2a-kczzl   Running   m4.large    us-east-2   us-east-2a   84m
cluster-41bf-fbs46-worker-us-east-2b-nvqkj   Running   m4.large    us-east-2   us-east-2b   84m
cluster-41bf-fbs46-worker-us-east-2c-plb4w   Running   m4.large    us-east-2   us-east-2c   84m
----

Listamos todas las maquinas agrupadas por tipo de instanacia

----
oc get machines -n openshift-machine-api -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{"\t"}{.spec.providerSpec.value.instanceType}{end}{"\n"}'
----

Listamos las maquinas del control plane

----
oc get machines -l machine.openshift.io/cluster-api-machine-type=master -n openshift-machine-api 
----

Listamos las maquinas por region

----
oc get machines -l machine.openshift.io/cluster-api-machine-type=master -n openshift-machine-api -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.providerSpec.value.placement.region}{"\n"}{end}'
----

==== Explorar Machinesets

Openshift crear pools de maquinas worker. El proceso de instalación crea un machineset por cada zona de disponibilidad y una maquina en cada machinesets.

----
$ oc get machinesets -n openshift-machine-api
NAME                                   DESIRED   CURRENT   READY   AVAILABLE   AGE
cluster-41bf-fbs46-worker-us-east-2a   1         1         1       1           101m
cluster-41bf-fbs46-worker-us-east-2b   1         1         1       1           101m
cluster-41bf-fbs46-worker-us-east-2c   1         1         1       1           101m
----
 
----
oc get machinesets -n openshift-machine-api -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{"\t"}{.spec.replicas}{end}{"\n"}'
----

==== Cambiando el type machine de un machinesets

Para la provisión de una nueva maquina puede crear un nuevo _resource machine_, es una manear facil de crear una nueva maquina y poder escalar sus replicas a la cantidad deseada.

Cambiamos el type machine a m5.2xlarge. Importante, el cambio no reemplaza el nodo existente!. 

----
oc patch machineset cluster-41bf-fbs46-worker-us-east-2a --type='merge' --patch='{"spec": { "template": { "spec": { "providerSpec": { "value": { "instanceType": "m5.2xlarge"}}}}}}' -n openshift-machine-api
----

==== Scale up machinesets

----
oc scale machineset cluster-41bf-fbs46-worker-us-east-2a --replicas=0 -n openshift-machine-api
---- 

El cambio elimina la maquina del machinesets

----
$ oc get machines
NAME                                         PHASE      TYPE        REGION      ZONE         AGE
cluster-41bf-fbs46-master-0                  Running    m4.xlarge   us-east-2   us-east-2a   106m
cluster-41bf-fbs46-master-1                  Running    m4.xlarge   us-east-2   us-east-2b   106m
cluster-41bf-fbs46-master-2                  Running    m4.xlarge   us-east-2   us-east-2c   106m
cluster-41bf-fbs46-worker-us-east-2a-kczzl   Deleting   m4.large    us-east-2   us-east-2a   100m
cluster-41bf-fbs46-worker-us-east-2b-nvqkj   Running    m4.large    us-east-2   us-east-2b   100m
cluster-41bf-fbs46-worker-us-east-2c-plb4w   Running    m4.large    us-east-2   us-east-2c   100m
---- 


==== Como Configurar machineset en vsphere 6.7 y ocp 4.5+
https://access.redhat.com/solutions/5307621