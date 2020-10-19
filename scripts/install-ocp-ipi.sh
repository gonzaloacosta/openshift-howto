#!/bin/bash

# Instalacion del cluster de Openshift [IPI Mode]
# Crear el archivo pull_secret.json con el contenido del pull secret creado en cloud.redhat.com para una instalacion IPI en AWS.

echo "Install Openshift Cluster IPI"

export GUID=74d2
export SUBDOMAIN=sandbox460.opentlc.com
export CLUSTER_NAME=cluster-$GUID
export SSH_KEY_PUB_FILE=id_rsa_$GUID
export PULL_SECRET=$(cat pull_secret.json)


mkdir -p ${CLUSTER_NAME}

ssh-keygen -t rsa -b 4096 -N '' -f ${HOME}/.ssh/${SSH_KEY_PUB_FILE}

export SSH_KEY_PUB=$(cat $HOME/.ssh/SSH_KEY_PUB_FILE)

cat << EOF > ${CLUSTER_NAME}/install-config.yaml
apiVersion: v1
baseDomain: ${SUBDOMAIN}
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 3
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
metadata:
  creationTimestamp: null
  name: ${CLUSTER_NAME}
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 10.0.0.0/16
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  aws:
    region: us-east-2
publish: External
pullSecret: ${PULL_SECRET}
sshkey: ${SSH_KEY_PUB}
EOF

openshift-install create cluster --dir ${CLUSTER_NAME}