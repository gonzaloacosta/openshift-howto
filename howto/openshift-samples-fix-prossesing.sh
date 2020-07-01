# Openshift Samples Operator PROSESSING
# https://access.redhat.com/solutions/5127951
oc delete configs.samples.operator.openshift.io cluster
oc patch configs.samples.operator.openshift.io/cluster --patch '{"spec":{"managementState": "Removed" }}' --type merge
oc patch configs.samples.operator.openshift.io/cluster --patch '{"spec":{"managementState": "Managed" }}' --type merge
oc delete configs.samples.operator.openshift.io cluster
