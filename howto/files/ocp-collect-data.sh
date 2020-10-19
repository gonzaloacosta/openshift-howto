#!/bin/bash

DATE=$(date --utc +'%d-%M-%Y-%H%m')
FOLDER=/tmp/ocp-logs-$DATE

mkdir $FOLDER -p

echo "Collect logs etcd"
for i in $(oc get pods -n openshift-etcd | awk '/etcd/ {print $1}') ; do oc logs $i -n openshift-etcd -c etcd > $FOLDER/$i.out ; done

echo "Collect logs kube-apiserver"
for i in $(oc get pods -n openshift-kube-apiserver | awk '/kube-apiserver/ {print $1}') ; do oc logs $i -n openshift-kube-apiserver  > $FOLDER/$i.out ; done

echo "Collect logs kube-controller-manager"
for i in $(oc get pods -n openshift-kube-controller-manager | awk '/kube-controller/ {print $1}') ; do oc logs $i -n openshift-kube-controller-manager > $FOLDER/$i.out ; done

echo "Collect logs openshift-apiserver"
for i in $(oc get pods -n openshift-apiserver| awk '/apiserver/ {print $1}') ; do oc logs $i -n openshift-apisever > $FOLDER/$i.out ; done

echo "Collect logs openshift-authentication"
for i in $(oc get pods -n openshift-authentication | awk '/oauth/ {print $1}') ; do oc logs $i -n openshift-authentication > $FOLDER/$i.out ; done

echo "Collect logs openshift-sdn"
for i in $(oc get pods -n openshift-sdn | awk '{print $1}' | grep -v NAME) ; do oc logs $i -n openshift-authentication > $FOLDER/$i.out ; done

tar xvzf $FOLDER.tar.gz $FOLDER
