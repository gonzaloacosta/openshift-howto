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
    matchLabels:
      node-role.kubernetes.io/infra: ""
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

