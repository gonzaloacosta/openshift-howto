# Notas de referencia

# Nota en Red Hat por los valores "pkts rx OOB: 6223"
# https://access.redhat.com/solutions/1751293

# Nota donde como fijar persistir la configuracion
# https://access.redhat.com/solutions/2127401

# Nota que explica como setearlo y esta clarisimo.
# https://vswitchzero.com/2017/09/26/vmxnet3-rx-ring-buffer-exhaustion-and-packet-loss/

# HA Proxy Tunning
# https://medium.com/free-code-camp/load-testing-haproxy-part-1-f7d64500b75d


#
# Scale Up and Down app
NS=rh-test ; for i in $(oc get deploy -n $NS | awk '/v1/ { print $1 }') ; do oc scale deployment $i --replicas=1 -n $NS; done
NS=rh-test ; for i in $(oc get deploy -n $NS | awk '/v1/ { print $1 }') ; do oc scale deployment $i --replicas=3 -n $NS; done


# promql para monitoreo de haproxy
avg_over_time(haproxy_server_connections_total{exported_namespace="rh-test",exported_service="swim"}[30s])
haproxy_server_http_average_response_latency_milliseconds{exported_namespace="rh-test",exported_service="swim"}
haproxy_server_check_failures_total{exported_namespace="rh-test",exported_service="swim"}

# Colectar stado de ring buffer
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- ethtool -g ens192 ; oc exec $i -- ethtool -S ens192 ; oc exec $i -- ss -noemitaup ; done | tee -a cluster-networking-stat-$(date "+%Y%m%d%H%M").out

# Colectar estadisticas de interfaz
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- ethtool -S ens192 ; done | tee -a ethtool-S-ens192.out

# Colectar parametros de kernel
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- netstat -s ; done | tee -a netstat-s.out

# curl con pruebas iterativas tomando tiempos


# Tareas a completar.
# 1. Aumentar los valores de Ring Buffer en todos los nodos a 4096
# oc rsh sdn-x54n9
# ethtool -g ens192
# ethtool -G ens192 rx 4096 tx 4096
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- ethtool -g ens192 ; done | tee -a ethtool-g-ens192-$(date "+%Y%m%d%H%M").out
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- ethtool -G ens192 rx 4096 tx 4096 ; done | tee -a ethtool-G-ens192-rx-4096-tx-4096-$(date "+%Y%m%d%H%M").out

# 2. Chequear e incrementar el tamano de buffer a 4Mbi
#  sysctl -w net.core.wmem_max=4194304
#  sysctl -w net.core.rmem_max=4194304
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- sysctl -a | grep "net.core.*mem_max" ; done | tee -a sysctl-a-net.core.mem_max-$(date "+%Y%m%d%H%M").out
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- sysctl -w net.core.wmem_max=4194304 ; oc exec $i -- sysctl -w net.core.rmem_max=4194304; done | tee -a sysctl-w-net.core.w_rmem_max=4194304-$(date "+%Y%m%d%H%M").out

# 3. Verificar valores "collapsion and prunning"
# infra nodes
for i in $(oc get pods -o wide | egrep "swrk2002os|swrk2004os|swrk2006os" awk '/sdn-/ { print $1 }' | grep -v sdn-controller); do oc exec $i -- netstat -s | egrep "(collapse|prune)" ; done

# 4. Check the size read/write buffer
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- sysctl -a | egrep "tcp_(r|w)mem" ; done 

# Valores por defecto en credicoop, en algunas notas comentan que para picos intermitentes bajarlo a 2mb (ultimo valor)
# net.ipv4.tcp_rmem = 4096        87380   6291456
# net.ipv4.tcp_wmem = 4096        16384   4194304

# 5. Check Connection Tracking
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- sysctl -a | egrep "netfilter.nf_conntrack_(max|cou)" ; done 
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- cat /proc/sys/net/netfilter/nf_conntrack_max ; done

# 6. Verificar ulimit en los usuarios que corren los procesos de
# haproxy (externo ???)
# pod router (es 1.000.000 de Open Files)
# isorouter (es 1.000.000 de Open Files)
# /etc/sysctl.conf
fs.file-max = 1048576 

# /etc/security/limits.conf
* soft nofile 1048576 
* hard nofile 1048576 
root soft nofile 1048576 
root hard nofile 1048576 


# 7. Verificar la cantaidad de puertos efimeros que se pueden levantar (en haproxy externo y en infra pod routers)
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- sysctl net.ipv4.ip_local_port_range ; done 
# Default en todos los nodos
# net.ipv4.ip_local_port_range = 32768    60999

echo 1024 65535 > /proc/sys/net/ipv4/ip_local_port_range

Como openshift usa el 22623 vamos a subirlo desde el 

echo "32768 - 22623" | bc
net.ipv4.ip_local_port_range = 30000    60999

# Al momento de ejecutar el test
ss -tan 'sport = :443' | awk '{print $(NF)" "$(NF-1)}' | sed 's/:[^ ]*//g' | sort | uniq -c
ss -tan 'sport = :80' | awk '{print $(NF)" "$(NF-1)}' | sed 's/:[^ ]*//g' | sort | uniq -c

# 7. Aumentar la cantidad de puertos efimeros (haproxy)
echo 1024 65535 > /proc/sys/net/ipv4/ip_local_port_range

# 8. Reutilizar los socket en estado TIME_WAIT
vim /etc/sysctl.conf
# # Allow reuse of sockets in TIME_WAIT state for new connections
# only when it is safe from the network stack’s perspective.
net.ipv4.tcp_tw_reuse = 1
# Reload sysctl settings
sysctl -p