# RH KB
# https://docs.openshift.com/container-platform/3.11/admin_guide/pruning_resources.html#hard-pruning-registry

#Coloca la registry en ReadOnly (hay que darle unos minutos que levante los pods con ese cambio)
oc set env -n openshift-image-registry deployment/image-registry 'REGISTRY_STORAGE_MAINTENANCE_READONLY={"enabled":true}'

#Se le dan a la serviceaccount que el registry tiene configurada un par de permisos adicionales
oc adm policy add-cluster-role-to-user system:image-pruner system:serviceaccount:openshift-image-registry:registry

#Este comando te da un –dry-run de lo que vas a terminar borrando 
oc -n openshift-image-registry exec -i -t "$(oc -n openshift-image-registry get pods -l docker-registry=default -o jsonpath=$'{.items[0].metadata.name}\n')" -- /usr/bin/dockerregistry -prune=check

#Este es el mismo comando pero que borra lo que viste en el –dry-run
oc -n openshift-image-registry exec -i -t "$(oc -n openshift-image-registry get pods -l docker-registry=default -o jsonpath=$'{.items[0].metadata.name}\n')" -- /usr/bin/dockerregistry -prune=delete

#Con este comando volves la registry a ReadWrite
oc set env -n openshift-image-registry deployment/image-registry REGISTRY_STORAGE_MAINTENANCE_READONLY-
