## Como colectar un must gater y un sosreport de un nodo para Openshift 4.x

# Must Gather

# Logueados como cluster-admin ejecutar el proceso de colección de datos
oc adm must-gather

# Una vez colectados los datos quedaron en un archivo que empaquetamos y subimos 
# a Red Hat para que sea analizado.
tar cvzf $(hostname)-must-gather.tar.gz must-gater*

# Una vez colectado subirlo a Red Hat, los must-gather suelen ser archivos pesados 
# por lo que conviene subirlos con la tool redhat-support-tool
# RH Case ID: 02722809
redhat-support-tool addattachment -c 02722809 $(hostname)-must-gather.tar.gz

# SOSREPORT

# Si necesitamos colectar información de un nodo especifico de Openshift debemos
# Debemos colectar un sosreport, para esto seguir los siguientes pasos

# Entramos en modo debug al nodo
oc debug node/infra-03.dominio.com

# Con esto veremos que estamos dentro del pod de rhel7
sh-4.2# cat /etc/redhat-release
Red Hat Enterprise Linux Server release 7.8 (Maipo)
sh-4.2# 

# Ingresamo con chroot al nodo como root
sh-4.2# chroot /host bash
[root@infra-03 /]# cat /etc/redhat-release
Red Hat Enterprise Linux CoreOS release 4.3

# Descargamos toolbox que contine sosreport
[root@infra-03 /]# toolbox
Trying to pull registry.redhat.io/rhel8/support-tools...
Getting image source signatures
Copying blob 77c58f19bd6e skipped: already exists
Copying blob 47db82df7f3f skipped: already exists
Copying blob cdc5441bd52d done
Copying config 5ef2aab094 done
Writing manifest to image destination
Storing signatures
5ef2aab094514cc5561fa94b0bb52d75379ecf8a36355e891017f3982bac278c
Spawning a container 'toolbox-' with image 'registry.redhat.io/rhel8/support-tools'
Detected RUN label in the container image. Using that as the default...
command: podman run -it --name toolbox- --privileged --ipc=host --net=host --pid=host -e HOST=/host -e NAME=toolbox- -e IMAGE=registry.redhat.io/rhel8/support-tools:latest -v /run:/run -v /var/log:/var/log -v /etc/machine-id:/etc/machine-id -v /etc/localtime:/etc/localtime -v /:/host registry.redhat.io/rhel8/support-tools:latest


# Ejecutamos el sosreport
[root@infra-03 /]# sosreport -k crio.all=on -k crio.logs=on

sosreport (version 3.8)

This command will collect diagnostic and configuration information from
this Red Hat Enterprise Linux system and installed applications.

An archive containing the collected information will be generated in
/host/var/tmp/sos.t0y59fr0 and may be provided to a Red Hat support
representative.

Any information provided to Red Hat will be treated in accordance with
the published support policies at:

  https://access.redhat.com/support/

The generated archive may contain data considered sensitive and its
content should be reviewed by the originating organization before being
passed to any third party.

No changes will be made to system configuration.

Press ENTER to continue, or CTRL-C to quit.

Please enter the case id that you are generating this report for []: 02722809

 Setting up archive ...
 Setting up plugins ...
[plugin:networking] skipped command 'ip -s macsec show': required kernel modules or services not present (kmods=[macsec] services=[]). Use '--allow-system-changes' to enable collection.
[plugin:networking] skipped command 'ss -peaonmi': required kernel modules or services not present (kmods=[tcp_diag,udp_diag,inet_diag,unix_diag,netlink_diag,af_packet_diag] services=[]). Use '--allow-system-changes' to enable collection.
 Running plugins. Please wait ...

  Starting 76/85 system          [Running: logs podman selinux system]                    [plugin:system] _copy_dir: Too many levels of symbolic links copying '/host/proc/sys/fs'
[plugin:system] _copy_dir: Too many levels of symbolic links copying '/host/proc/sys/fs'
  Finishing plugins              [Running: logs]
  Finished running plugins
Creating compressed archive...

Your sosreport has been generated and saved in:
  /host/var/tmp/sosreport-infra-03-02722809-2020-08-08-bhuiswi.tar.xz >>>> ARCHIVO QUE HAY QUE SUBIR AL CASO

The checksum is: 506dcf594d4c051bd40583583b0a798a




