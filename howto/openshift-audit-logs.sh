########################################################################################
# 
# Openshift Audit Logs
# 
########################################################################################

# Como ver los logs de auditorio de los nodos de Openshift

# Openshift API Server
oc adm node-logs --role=master --path=openshift-apiserver/
oc adm node-logs $NODENAME --path=openshift-apiserver/audit.log

# Kubernetes API Server
oc adm node-logs --role=master --path=kube-apiserver/
oc adm node-logs $NODENAME --path=kube-apiserver/audit.log

