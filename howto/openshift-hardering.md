# Openshift Hardering

## Hardening RHCOS

```
A key feature of OpenShift Container Platform and its Kubernetes engine is to be able to quickly scale applications and infrastructure up and down as needed. Unless it is unavoidable, you do not want to make direct changes to RHCOS by logging into a host and adding software or changing settings. You want to have the OpenShift Container Platform installer and control plane manage changes to RHCOS so new nodes can be spun up without manual intervention.
```

### Choosing what to harden in RHCOS

The RHEL 8 Security Hardening guide describes how you should approach security for any RHEL system.

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/security_hardening/index#scanning-container-and-container-images-for-vulnerabilities_scanning-the-system-for-security-compliance-and-vulnerabilities

There are opportunities for modifying RHCOS before installation, during installation, and after the cluster is up and running.

- **Hardening before installation**
For example, you can add kernel options when you boot the RHCOS installer to turn security features on or off, such as SELinux or various low-level settings, such as symmetric multithreading

- **Hardening during installation**
You can also make some basic security-related changes to the install-config.yaml file used for installation. Contents added in this way are available at each node’s first boot.

- **Hardening after the cluster is running**
After the OpenShift Container Platform cluster is up and running, there are several ways to apply hardening features to RHCOS

    - **DaemonSet:** If you need a service to run on every node, you can add that service with a Kubernetes DaemonSet.
    
    - **MachineConfig:** MachineConfig objects contain a subset of Ignition configs in the same format. By applying MachineConfigs to all worker or control plane nodes, you can ensure that the next node of the same type that is added to the cluster has the same changes applied.

        - [MachineConfig](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.5/html-single/nodes/index#nodes-nodes-kernel-arguments_nodes-nodes-working)
        