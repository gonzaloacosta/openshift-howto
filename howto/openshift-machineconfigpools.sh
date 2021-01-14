#MachineConfigPools

Por defecto la instalacion de Openshift vienen con dos machine config workers e masters. Podemos agregar un nuevo machine config pool para los nodos de infra, esto quiere decir que podemos manejar la configuracion de los nodos con un solo templates de configuracion.

#Verificamos los machineconfigpool
oc get mcp
NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED
master   rendered-master-7053d8fc3619388accc12c7759f8241a   True      False      False
worker   rendered-worker-6db67f47c0b205c26561b1c5ab74d79b   True      False      False

#Creamos el machineconfigpool para los nodos de infra
cat << EOF > infra.mcp.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfigPool
metadata:
  name: infra
spec:
  machineConfigSelector:
    matchExpressions:
      - {key: machineconfiguration.openshift.io/role, operator: In, values: [worker,infra]}
  nodeSelector:
    matchExpressions:
      - {key: node-role.kubernetes.io/infra, operator: In, values: [apps,appl]}
EOF

oc create -f infra.mcp.yaml

# Chequeamos que se haya creado.
oc get machineconfig

#una vez creado podemos crear un machineconfig para poder aplicar a todos los nodos
cat << EOF > infra.mc.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: infra
  name: 51-infra
spec:
  config:
    ignition:
      version: 2.2.0
    storage:
      files:
      - contents:
          source: data:,infra
        filesystem: root
        mode: 0644
        path: /etc/infratest
EOF

oc create -f infra.mc.yaml
oc get machineconfig

#En caso que la configuración del machineconfig sea sensible podemos ofuscarla con 
echo "texto en nodo de infra" | base64 -w0


cat << EOF > infra.mc.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: infra
  name: 51-infra
spec:
  config:
    ignition:
      version: 2.2.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,cG9vbCAwLnJoZWwucG9vbC5udHAub3JnIGlidXJzdCAKZHJpZnRmaWxlIC92YXIvbGliL2Nocm9ueS9kcmlmdAptYWtlc3RlcCAxLjAgCnJ0Y3N5bmMKbG9nZGlyIC92YXIvbG9nL2Nocm9ueQo=
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/chrony.conf
      - contents:
          source: data:text/plain;charset=utf-8;base64,KiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAKU29sbyBsYXMgcGVyc29uYXMgYXV0b3JpemFkYXMgcHVlZGVuIGhhY2VyIHVzbyBkZSBlc3RlIGVxdWlwbyB5IGRlIGxvcyAKcHJvZ3JhbWFzIGFxdcOtIGluc3RhbGFkb3MsIGRlYmllbmRvIGluZ3Jlc2FyIHN1IHVzdWFyaW8geSBjbGF2ZSwgcXVlIGhhbiBzaWRvCmFkb3B0YWRvcyBwb3IgZWwgU2VtcGVydGkgY29tbyBmaXJtYSBkaWdpdGFsLCBzaWVuZG8gw6lzdGEgw7puaWNhIGUgaW50cmFuc2ZlcmlibGUuClN1IHV0aWxpemFjacOzbiBpbXBsaWNhIGVsIGNvbm9jaW1pZW50byB5IGFjZXB0YWNpw7NuIGRlIGxhIHBvbMOtdGljYSBxdWUgcmVndWxhCmxhIHV0aWxpemFjacOzbiBkZSBtZWRpb3MgdGVjbm9sw7NnaWNvcyBkZSBTZW1wZXJ0aSwgcG9yIGxvIGN1YWwgZXMgcmVzcG9uc2FibGUgCmRlIHRvZGFzIGxhcyBvcGVyYWNpb25lcyBxdWUgc2UgcmVhbGljZW4gY29uIHN1IHVzdWFyaW8geSBjbGF2ZS4KKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAqICogKiAK
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/issue.net
      - contents:
          source: data:text/plain;charset=utf-8;base64,KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKgoqICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAqICAgCiogICAgICAgICAgICAgRWwgaW5ncmVzbyBlc3TDoSBwZXJtaXRpZG8gc29sbyBhIHBlcnNvbmFsIGF1dG9yaXphZG8gICAgICAgICAgICAqICAgCiogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICogICAKKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKgo=
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/motd
EOF


## Docs

### Links para entender el funcionamiento de los MachineConfigPools y MachineConfig

* [OpenShift Container Platform 4: How does Machine Config Pool work?](https://www.redhat.com/en/blog/openshift-container-platform-4-how-does-machine-config-pool-work)

### Como crear MachineConfigPools Customs, por ejemplo para los Infra nodes.

* [Custom pools](https://github.com/openshift/machine-config-operator/tree/master/docs)
* [Custom Machine Config Pool in OpenShift 4](https://access.redhat.com/solutions/5688941)

### Primeros problemas con MachineConfigPools (y no los últimos)

* [Node in degraded state because of the use of a deleted machineconfig: machineconfig.machineconfiguration.openshift.io; rendered-$[custom-machine-config] not found.](https://access.redhat.com/solutions/4970731)

Esto pasa cuando un MachineConfig es eliminado, el MachineConfigController no reconoce un rollback a un render-xxxx previo, esto hace que el MachineConfigPool quede en `Degradated`. La solución setear a mano los render-xxxx MachineConfig existente en los annotations de los nodos, esto lo hacemos editando el nodo.


* [MachineConfigPool stuck in degraded after applying a modification in OpenShift Container Platform 4.x](https://access.redhat.com/solutions/5244121)
* [Managing SSH Keys with the MCD](https://github.com/openshift/machine-config-operator/blob/master/docs/Update-SSHKeys.md)
* [How to force validation of failing / stuck MachineConfigurations in Red Hat OpenShift Container Platform 4.x?](https://access.redhat.com/solutions/5414371)
