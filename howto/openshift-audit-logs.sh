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

# Cada uno de las entradas en los logs se guardan de esta manera

{
  "kind": "Event",
  "apiVersion": "audit.k8s.io/v1",
  "level": "Metadata",
  "auditID": "a1104bd6-5abc-4e5d-b14c-f1062a1539be",
  "stage": "ResponseComplete",
  "requestURI": "/api/v1/namespaces/cluster-test/secrets/django-psql-persistent",
  "verb": "get",
  "user": {
    "username": "kube:admin",
    "groups": [
      "system:cluster-admins",
      "system:authenticated"
    ],
    "extra": {
      "scopes.authorization.openshift.io": [
        "user:full"
      ]
    }
  },
  "sourceIPs": [
    "172.18.32.35",
    "10.129.2.1"
  ],
  "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.135 Safari/537.36",
  "objectRef": {
    "resource": "secrets",
    "namespace": "cluster-test",
    "name": "django-psql-persistent",
    "apiVersion": "v1"
  },
  "responseStatus": {
    "metadata": {},
    "code": 200
  },
  "requestReceivedTimestamp": "2020-08-26T12:13:43.646410Z",
  "stageTimestamp": "2020-08-26T12:13:43.654157Z",
  "annotations": {
    "authorization.k8s.io/decision": "allow",
    "authorization.k8s.io/reason": "RBAC: allowed by ClusterRoleBinding \"cluster-admins\" of ClusterRole \"cluster-admin\" to Group \"system:cluster-admins\""
  }
}

Donde se definene usuario, grupo, sourceIPs, etc. Con esta información se puede evidenciar quién y cuando se ha modificado.