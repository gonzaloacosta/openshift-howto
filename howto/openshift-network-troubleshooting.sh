# Notas de referencia
Nota en Red Hat por los valores "pkts rx OOB: 6223"
https://access.redhat.com/solutions/1751293

Nota donde como fijar persistir la configuracion
https://access.redhat.com/solutions/2127401

Nota que explica como setearlo y esta clarisimo.
https://vswitchzero.com/2017/09/26/vmxnet3-rx-ring-buffer-exhaustion-and-packet-loss/

#
# Scale Up and Down app
NS=rh-test ; for i in $(oc get deploy -n $NS | awk '/v1/ { print $1 }') ; do oc scale deployment $i --replicas=1 -n $NS; done
NS=rh-test ; for i in $(oc get deploy -n $NS | awk '/v1/ { print $1 }') ; do oc scale deployment $i --replicas=3 -n $NS; done

# Infra nodes
oc get pods -o wide | egrep "swrk2002os|swrk2004os|swrk2006os"


# promql para monitoreo de haproxy
avg_over_time(haproxy_server_connections_total{exported_namespace="esb-atm-prep",exported_service="isorouter-ms-router"}[30s])
haproxy_server_http_average_response_latency_milliseconds{exported_namespace="rh-test",exported_service="swim"}
haproxy_server_check_failures_total{exported_namespace="rh-test",exported_service="swim"}


# oc debug all nodes
for i in $(oc get nodes | awk '/swrk/ {print $1}') ; do oc debug node/$i --image=rhel7/rhel-tools ; done

# Copy netstat from debug mode to fabri bastion
netstat -s > $(cat /etc/hostname)-netstat.out ; scp $(cat /etc/hostname)-netstat.out frossi@sbst2002lx.cltrnoprod.bancocredicoop.coop:/home/frossi/ocp-prep/netstat

# tcpdump

# Catch up the pid of the containers into RHCOS
chroot /host crictl inspect $(chroot /host crictl ps -a | awk '/swim/ {print $1}') | awk -F: '/pid/ {print $2}' | sed 's/[ ,\,]//g'
nsenter -t $PID tcpdump -nni any port 5000

# ConfigDNS
oc patch deployment bike-v1 -p '{"spec":{"template":{"spec":{"dnsConfig":{"options":[{"name": "single-request"}]}}}}}'


# Colectar stado de ring buffer [1]
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
# Original
# ethtool -G ens192 rx 1024 tx 512

# ethtool -G ens192 rx 4096 tx 4096
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- ethtool -g ens192 ; done | tee -a ethtool-g-ens192-$(date "+%Y%m%d%H%M").out

for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- ethtool -G ens192 rx 4096 tx 4096 ; done | tee -a ethtool-G-ens192-rx-4096-tx-4096-$(date "+%Y%m%d%H%M").out

# rollback
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- ethtool -G ens192 rx 1024 tx 512 ; done | tee -a ethtool-G-ens192-rx-1024-tx-512-$(date "+%Y%m%d%H%M").out

# 2. Chequear e incrementar el tamano de buffer a 4Mbi
# Default
# net.core.rmem_max = 212992
# net.core.wmem_max = 212992

#  sysctl -w net.core.wmem_max=4194304
#  sysctl -w net.core.rmem_max=4194304
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- sysctl -a | grep "net.core.*mem_max" ; done | tee -a sysctl-a-net.core.mem_max-$(date "+%Y%m%d%H%M").out

for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- sysctl -w net.core.wmem_max=4194304 ; oc exec $i -- sysctl -w net.core.rmem_max=4194304; done | tee -a sysctl-w-net.core.w_rmem_max=4194304-$(date "+%Y%m%d%H%M").out

# Rollback
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- sysctl -w net.core.wmem_max=212992 ; oc exec $i -- sysctl -w net.core.rmem_max=212992; done | tee -a sysctl-w-net.core.w_rmem_max=212992-$(date "+%Y%m%d%H%M").out


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

# 7. Verificar la cantaidad de puertos efimeros que se pueden levantar (en haproxy externo y en infra pod routers)
for i in $(oc get pods -n openshift-sdn | awk '/sdn-/ { print $1 }' | grep -v sdn-controller) ; do echo ">>>>> $(oc exec $i -- hostname)" ; oc exec $i -- sysctl net.ipv4.ip_local_port_range ; done 
# Default en todos los nodos
# net.ipv4.ip_local_port_range = 32768    60999

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


####### Rount Trip Time of 0.1s, the BDP=(0.1 * 10^9)/8
sh-4.2# sysctl net.core.rmem_max
net.core.rmem_max = 212992
sh-4.2# sysctl net.core.wmem_max
net.core.wmem_max = 212992
sh-4.2# sysctl net.ipv4.tcp_rmem
net.ipv4.tcp_rmem = 4096        87380   6291456
sh-4.2# sysctl net.core.netdev_max_backlog
net.core.netdev_max_backlog = 1000
sh-4.2# sysctl net.ipv4.tcp_max_syn_backlog
net.ipv4.tcp_max_syn_backlog = 1024
sh-4.2#

# Chequear los parametros con netstat
packets pruned from receive queue because of socket buffer overrun
times the listen queue of a socket overflowed
SYNs to LISTEN sockets ignored
packets collapsed in receive queue due to low socket buffer
TCPBacklogDrop

# Chequeo de ring buffer habiendo corrido [1]
for i in $(oc get nodes | awk '/cltr/ {print $1}') ; do egrep ">>>|ring full" cluster-networking-stat-20200722* | grep -A4 $i ; done | less
