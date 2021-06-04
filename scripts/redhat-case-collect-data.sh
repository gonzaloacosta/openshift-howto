# Data for Red Hat Case
####################################################################################

# Esto si se responde el cluster, sino no
oc describe pod <pod_name>
oc get events
oc adm inspect clusteroperator/network
oc adm inspect clusteroperator/kube-apiserver
oc adm inspect clusteroperator/kube-controller-manager
oc adm inspect clusteroperator/etcd

# Journal logs of kubelet where pod is scheduled:
# oc get pods -o wide
# oc debug node/<node_name>   OR 	SSH to node
# chroot /host

# Esto en cada nodo master clavaddo
sudo journalctl --no-pager -u kubelet &> /tmp/$(hostname)_kubelet.logs
sudo journalctl --no-pager -u crio &> /tmp/$(hostname)_crio.logs

# Logs del pod en estado Running y en Exited de kube-apiserver
sudo crictl ps -a | grep kube-apiserver
sudo crictl logs <id_pod_running> &> /tmp/$(hostname)-kubeapiserver-running.log
sudo crictl logs <id_pod_exited> &> /tmp/$(hostname)-kubeapiserver-exited.log

### Collect CoreDump CriIO.
####################################################################################

# Try to run below command.
crictl ps

If it is unresponsive then it may give errors like: failed to connect: failed to connect: context deadline exceeded.

If you experience issues with `crictl` and/or still suspect the runtime is hung, please collect a coredump while the issue is still occurring(without rebooting the node when node is in not ready status). A coredump of an asymptomatic node does not likely provide any useful debugging information.

To Gather a cri-o Coredump from Red Hat CoreOS:
------------------------------------------------
Gathering a cri-o coredump requires command-line access to the node, in the form of SSH access or `oc node debug` access.
Prior to proceeding, make sure to note the exact version of cri-o in use.  Once you have node access, query the cri-o package:
# rpm -qa cri-o
cri-o-1.14.11-6.dev.rhaos4.2.git627b85c.el8

# podman login registry.redhat.io
# podman pull registry.redhat.io/rhel8/support-tools
# podman container runlabel RUN registry.redhat.io/rhel8/support-tools

Install gcore tools in the container:
# yum install gdb procps-ng -y

Produce the core using `gcore` which is provided by `gdb`:
# gcore -o crio $(pidof crio)

Copy the resulting file labeled with `core.$PID` where $PID is the process number for the core to another system and attach it to the case.

It is also prudent to immediately collect an sosreport of a node after collecting the core, for `lsof` information and any output of `crictl` commands that can be obtained.  While still in the container of that support-tools, run:
# sosreport

If the sosreport hangs, you may re-run the sosreport command without the `crio` plugin like so:
# sosreport -n crio
------------------------------------------------

Let us know if you have any concerns pertaining to the same.