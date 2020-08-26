#####################################################################
#
# Como modificar la configuración de vsphere en Openshift 4
#
#####################################################################
# RH Note: https://access.redhat.com/solutions/4618011

# Environment
#####################################################################
# OCP 4 y vSphere

# Temas a tratar
#####################################################################
# 1. Cambio de contraseña
# 2. Agregado de un nuevo Datastore
# 3. Cambio de nombre de un nuevo Datastore


# 1. Cambio de contraseña
#####################################################################
# Las contraseñas de nuestras configuración se encuentran en un secret en el proyecto kube-system

$ oc get secret vsphere-creds -n kube-system -o yaml
apiVersion: v1
data:
  vcsa-ci.vmware.devcluster.openshift.com.password: cmVkaGF0Cg==
  vcsa-ci.vmware.devcluster.openshift.com.username: dGVzdHBhc3N3b3JkCg==
kind: Secret
metadata:
  creationTimestamp: "2019-11-20T07:17:11Z"
  name: vsphere-creds
  namespace: kube-system
  resourceVersion: "311"
  selfLink: /api/v1/namespaces/kube-system/secrets/vsphere-creds
  uid: c5241a4a-0b65-11ea-8fa4-005056b6e626
type: Opaque

# Editar y cambiar la contraseña previamente habiendo reconvertido el secreto a base64
oc edit secret vsphere-creds -n kube-system

# 1. Backup de la conf actual
oc get secret vsphere-creds -o yaml -n kube-system > creds_backup.yaml
oc get cm cloud-provider-config -o yaml -n openshift-config > cloud.yaml

# 2. Contraseña en base64
echo -n "Openshifttestpassword" | base64 -w0
T3BlbnNoaWZ0dGVzdHBhc3N3b3Jk

# 3. Guardar la configuración en un archivo
$ cp creds_backup.yaml creds.yaml
$ vi creds.yaml

    apiVersion: v1
    data:
      vcsa-ci.vmware.devcluster.openshift.com.password: T3BlbnNoaWZ0dGVzdHBhc3N3b3Jk    >>> copy your base64 encoded password here
      vcsa-ci.vmware.devcluster.openshift.com.username: YWRtaW5AdnNwaGVyZS5sb2NhbAo=
    kind: Secret
    metadata:

# 4. Reemplazar
$ oc replace -f creds.yaml

# 2. Actualización de Datastore
#####################################################################
# La información de los datos del datastore son guardados en un configmaps en el proyecto openshift-config
# Un ejemplo muesrta los datos en [Global] para las credenciales, [Workspace] los datos de conexión a vsphere

apiVersion: v1
data:
  config: |+
    [Global]
    secret-name      = vsphere-creds
    secret-namespace = kube-system
    insecure-flag    = 1

    [Workspace]
    server            = vsphere.openshift.example.com
    datacenter        = dc1
    default-datastore = nvme-ds1
    folder            = openshift

    [VirtualCenter "vsphere.openshift.example.com"]
    datacenters = dc1



kind: ConfigMap
metadata:
  creationTimestamp: "2019-11-20T07:17:06Z"
  name: cloud-provider-config
  namespace: openshift-config
  resourceVersion: "34674"
  selfLink: /api/v1/namespaces/openshift-config/configmaps/cloud-provider-config
  uid: c2252e19-0b65-11ea-8fa4-005056b6e626

# 3. Agregar datastore adicionales
#####################################################################
# Para poder agregar un datastore nuevo hay que crear un nuevo storageclass para poder relacionarlo.

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  name: new-thin-sc
  ownerReferences:
  - apiVersion: v1
    kind: clusteroperator
    name: storage
parameters:
  datastore: datastore1
  diskformat: thin
provisioner: kubernetes.io/vsphere-volume
reclaimPolicy: Delete
volumeBindingMode: Immediate
