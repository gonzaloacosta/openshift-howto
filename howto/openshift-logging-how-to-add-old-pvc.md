# Openshift Cluster Logging

## How to add old pvc to new deployment of stack cluster logging.

The goal is to add old pvc to new deployment of clusterlogging operator, but when we try to follow the steps [1] the operator didn't  permited to add they. In a Red Hat case we queried how to follow the steps and they responsed was:

[1] [OpenShift 4 Logging operator creates multiple PersistentVolumeClaim (PVC) after upgrade and how to replace the new PVCs with the old ones](https://access.redhat.com/solutions/5323141)

Please follow the steps below and let me know the results:

1.  Take a backup of the elasticsearch instance:

```
oc get elasticsearch elasticsearch -o yaml | tee elasticsearch-old.yaml
cp elasticsearch-old.yaml elasticsearch.yaml
```

2. Open the file elasticsearch.yaml and take out the "condition" section. Maybe or Maybe not have any data on it. 

3. Move the genUUID from zqullfrm to rsh30v80 (Those you have in your cluster)

```
From:
nodes:
  - genUUID: zqullfrm
    nodeCount: 3
    resources: {}
...
To:
nodes:
  - genUUID: rsh30v80
    nodeCount: 3
    resources: {}	
...
```

4. Remove anything from the "nodes" section:

```
clusterHealth: ""
  conditions: [] <-- You removed this section in previous steps
  nodes: <!-- From here
  - deploymentName: elasticsearch-cdm-zqullfrm-1
    upgradeStatus: {}
  - deploymentName: elasticsearch-cdm-zqullfrm-2
    upgradeStatus: {}
  - deploymentName: elasticsearch-cdm-zqullfrm-3
    upgradeStatus: {}
--> To here
```

5. Save the file

6. Edit the ClusterLogging object

Get the ClusterLogging object:

```
# oc get ClusterLogging
```

Edit it. In this example, we're considering the ClusterLogging object with the name "instance"

```
# oc edit ClusterLogging/instance
```

7. Move the ManagementState variable from Managed to Unmanaged

8. Delete the previous CR using the backup created in previous steps. If there're Pending PVC's with a genUUID other than rsh30v80, please remove it. Please keep only PVC's with the genUUID rsh30v80.

9. Create the CR from the modified file:

```
# oc create -f elasticsearch.yaml
```

10. Wait until you can see new pods with the genUUID rsh30v80 consuming the old PVC's

11. Check if the pods attached to the old PVC's:

```
# oc describe pod -l component=elasticsearch | grep -i -E "^Name: pvc"
```

12: If the old PVC's are with the status "Bound"

```
# oc get pvc -n openshift-logging
``` 

The newly created pods must have rsh30v80 as genUUID and be attached to the matching PVC's.
Once this is working, please keep the ClusterLogging instance in the Unmanaged state until a final fix is released.
