#OCP Release
$ ansible localhost -m lineinfile -a 'path=$HOME/.bashrc regexp="^export OCP_RELEASE" line="export OCP_RELEASE=4.2.10"' $ source $HOME/.bashrc

#Download client
$ wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$OCP_RELEASE/openshift-client-linux-$OCP_RELEASE.tar.gz 

#Install Client
$ sudo tar xzf openshift-client-linux-$OCP_RELEASE.tar.gz -C /usr/local/sbin/ oc kubectl $ which oc 

#Bash Completion
$ oc completion bash | sudo tee /etc/bash_completion.d/openshift > /dev/null

#Total de consumo de pods
oc adm top pods --all-namespaces | grep -v NAME | awk 'a+=$4; END{print a}'

#Pods con errores
oc get pods --all-namespaces | egrep "CreateContainerError|Error"

#Clean Pods Error
oc get pods --all-namespaces | egrep "CreateContainerError|Error|Evicted" | awk '{print "oc delete pod -n "$1" "$2}' | sh

#Clan Pods Evicted
oc get pods --all-namespaces | egrep "Evicted" | awk '{print "oc delete pod -n "$1" "$2}' | sh

#Describe pod with error
oc get pods --all-namespaces | egrep "CreateContainerError|Error" | awk '{print "oc describe pod -n "$1" "$2}' | sh | less

#Clean docker images
for i in $(docker ps -a | grep Exited | awk '{print $1}') ; do docker stop $i ; docker rm $i ; done

#Eliminar pods 0/1
oc get pods --all-namespaces | grep "0/1" | awk '{print "oc delete pod -n "$1" "$2}' | sh

#Eliminar pods evicted
oc get pods --all-namespaces -o wide | grep -i evicted | awk '{print "oc delete pod -n "$1" "$2}' | sh

#Total de consumo de memoria de x cantidad de pods para los proyectos pandora y 60d
oc adm top pods --all-namespaces | egrep "pandora|60d" | awk 'b=b+1 ; a+=$4; END{print "Total de Consumo de Memoria " a "Mi para un total de " b " pods"}'

#Eliminar los pods Exited en un nodo de ocp4 con crictl
for i in $(crictl ps -a | grep -i Exited | awk '{print $1}'); do crictl rm $i ; done

for i in $(sudo crictl ps -a | grep -i Exited | awk '{print $1}'); do sudo crictl rm $i ; done

Ejecutar comando en pods
kubectl exec -it -n istio-system-a istio-ingressgateway-55d59664c7-lr6hj -- cat /etc/istio/ingressgateway-ca-certs/CA-Semperti.pem

Ejecucion de comandos remotos
for i in $(oc get nodes | grep -v NAME | awk '{print $1}') ; do echo ">>>> $i <<<<<" ; ssh -i id_ocprc01 core@$i -C 'cat /etc/containers/policy.json' ; done

for i in $(oc get nodes | grep -v NAME | awk '{print $1}') ; do echo ">>>> $i <<<<<" ; scp -i id_ocprc01 policy.json core@$i:~ ; done

for i in $(oc get nodes | grep -v NAME | awk '{print $1}') ; do echo ">>>> $i <<<<<" ; ssh -i id_ocprc01 core@$i -C 'sudo cp ~/policy.json /etc/containers/policy.json' ; done

for i in $(oc get nodes | grep -v NAME | awk '{print $1}') ; do echo ">>>> $i <<<<<" ; ssh -i id_ocprc01 core@$i -C 'sudo podman pull tuxtron/svc-busqueda-afiliados-rest-api:1.0' ; done

for i in $(oc get nodes | grep -v NAME | awk '{print $1}') ; do echo ">>>> $i <<<<<" ; ssh -i id_ocprc01 core@$i -C 'ls -ltr /etc/pki/ca-trust/source/anchors/ca-bundle.crt' ; done

#  Port-Forward
#  El puerto localhost:3000 reenvia el trafico al port 3000 del servicio
$ oc port-forward -n monitoring service/grafana-service 3000

# El puerto localhost:5000 reenvia el trafico el port 3000 del servicio
$ oc port-forward service/grafana-service 5000:3000

# Lister los containers en un pod
oc get pods -l app=<container-name> -o jsonpath='{.items[*].spec.containers[*].name}{"\n"}'

# Scraper Pods
oc run curl-scraper-1 -i --restart=Never --image=appropriate/curl --timeout=30s -- -v context-scraper:8080/scrape/custom_search?term==skynet

# Node Overcommitment
or i in $(oc get nodes | awk '/worker/ {print $1}') ; do oc describe node $i | tail -6 ; done

DNS Check
HOST=master.cftsit.com
dig +short $HOST ; host $HOST ; nslookup $(dig +short $HOST)
getent ahostsv4 $HOST | head -n 1 | awk '{ print $1 }'

# Listar imagenes a borrar
for i in $(oc adm prune images --keep-tag-revisions=10 | grep image | awk '{print $3}') ; do oc describe image $i | grep "Docker Image" ; done

# Listar todos los pods que estan corriendo ordenados por nodo
oc get pods --all-namespaces --field-selector status.phase=Running --sort-by spec.nodeName -o wide

# Networking statistics
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostanme)" ; oc exec $i -- ethtool -g ens192 ; oc exec $i -- ethtool -S ens192 ; oc exec $i -- ss -noemitaup ; done | tee -a cluster-networking-stat-$(date "+%Y%m%d%H%M").out

# Catch up the pid of the containers into RHCOS
chroot /host crictl inspect $(chroot /host crictl ps -a | awk '/swim/ {print $1}') | awk -F: '/pid/ {print $2}' | sed 's/[ ,\,]//g'
nsenter -t $PID tcpdump -nni any port 5000


# Cantidad de conexiones
netstat -plan|grep :<puerto> | awk {'print $5'} | cut -d: -f 1 | sort | uniq -c | sort -n

# Cambiar la politica de retencion de los persistent volume
for i in $(oc get pv | awk '/pvc-/ {print $1}') ; do oc patch pv $i  -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}' ; done

# Ver tags asociados a un imagestreams
oc get is python -n openshift --template='{{.metadata.name}}{{range .spec.tags}}{{" "}}{{.name}}{{end}}{{"\n"}}'

# Patch
oc patch clusterlogging -n openshift-logging instance -p  '{"spec":{"logStore":{"elasticsearch":{"resources":{"limits":{"cpu":"1500m"}}}}}}'

# oc adm top pods
oc adm top pods --all-namespaces | awk 'BEGIN{"date +'%Y-%m-%d-%H:%M:%S'"|getline d;} {if(NR>1) print d,","$1","$2","$3","$4}' | head -10

oc adm top pods --sort-by=cpu --all-namespaces | awk 'BEGIN{"date +'%Y-%m-%d-%H:%M:%S'"|getline d;} {if(NR>1) print d,","$1","$2","$3","$4}' | head -10