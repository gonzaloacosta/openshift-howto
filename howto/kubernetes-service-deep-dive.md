
Openshift Core Services | Kubernetes Service Deep Dive
======================================================

Revision de los servicios de Kubernetes Service en profundidad

# Tabla de Contenido

- 1. [Kubernetes Service Deep Dive](#1)
  + 1.1. [Como se definen?](#1.a)
  + 1.2. [Que criterio de seleccion utilizan?](#1.b)
  + 1.3. [Con que tecnologia hacen este balanceo?](#1.c)
  + 1.4. [Revision de la definicion de un servicio con iptables.](#1.d)

#### 1. Kubernetes Service Deep Dive

Es un poco confuso responder a las preguntas de como esta constituido un servicio dentro de kubernetes, muchos confunden el servicio de balanceo dado por los ingress controller con los servicios que Kubernetes ofrece para poder comunicar las aplicaciones dentro del cluster. Estos servicios NO ESTAN HECHOS CON UN LOAD BALANCER. Las preguntas que surgen a esto son:

- 1.1. Como se definen?.
Se definen por medio de un manifiesto YAML.

```
oc get svc -n openshift-dns -o yaml
apiVersion: v1
kind: Service
metadata:
  name: dns-default                 >> [1]
  namespace: openshift-dns          >> [2]
spec:
  clusterIP: 172.30.0.10            >> [3]
  ports:                            >> [4]    
  - name: dns
    port: 53
    protocol: UDP
    targetPort: dns
  - name: dns-tcp
    port: 53
    protocol: TCP
    targetPort: dns-tcp
  - name: metrics
    port: 9153
    protocol: TCP
    targetPort: metrics
  selector:                         >> [5]
    dns.operator.openshift.io/daemonset-dns: default    >> [6]
  sessionAffinity: None
  type: ClusterIP
```

[1] name: identificador del servicio.
[2] namespaces: namespaces donde esta creado el servicio.
[3] clusterIP: Ip con la que es identificado el servico dentro del cluster.
[4] ports: Listado de puertos que atendera el servicio y a los que redirge el trafico.
[5] selector: El selector es el apartado dentro de la definicion que indica que pods van a atender la peticion del servicio. EndPoints destino.
[6] label: etiqueta con al que identificara a los pods.

- 1.2. Que criterio de seleccion utilizan?.
El criterio de seleccion queda definido en el selector del ejemplo del punto 1.[5].
```
  selector:
    dns.operator.openshift.io/daemonset-dns: default
```

Si nostros listamos los pods y filtramos por este selector nos daran los pods que van a atender la peticion.
```
> oc get pods -l dns.operator.openshift.io/daemonset-dns=default                                                                                                     (⎈ admin@openshift-dns)
NAME                READY   STATUS    RESTARTS   AGE
dns-default-hn4b8   2/2     Running   0          2d2h
dns-default-hpj4h   2/2     Running   0          2d2h
dns-default-j9qsv   2/2     Running   0          2d2h
dns-default-jdqrp   2/2     Running   0          2d2h
dns-default-x6srm   2/2     Running   0          2d2h
dns-default-xmhww   2/2     Running   0          2d2h
```

- 1.3. Con que tecnologia se resuelve el balanceo?.
Reglas de `iptables` dentro de los nodos del cluster aplicadas por el agente de `KubeProxy`

- 1.4. Revision de la definicion de un servicio con iptables.
Las reglas las podes ver logueandote a uno de los nodos del cluster de kuberntes y realizando un `iptables-save`

Queremos revisar las reglas de iptables en uno de los nodos. Primero accedemos por ssh.

Una vez logueados ejecutamos el siguiente comando donde `dns-default` es el nombre del servicio.
```
[root@worker1 ~]# iptables-save | grep dns-default
-A KUBE-SERVICES ! -s 10.254.0.0/16 -d 172.30.0.10/32 -p udp -m comment --comment "openshift-dns/dns-default:dns cluster IP" -m udp --dport 53 -j KUBE-MARK-MASQ 
-A KUBE-SERVICES -d 172.30.0.10/32 -p udp -m comment --comment "openshift-dns/dns-default:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-BGNS3J6UB7MMLVDO >> [1]
-A KUBE-SERVICES ! -s 10.254.0.0/16 -d 172.30.0.10/32 -p tcp -m comment --comment "openshift-dns/dns-default:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 172.30.0.10/32 -p tcp -m comment --comment "openshift-dns/dns-default:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-SVC-6BRQXW4I6ZZ3LHZH >> [2]
-A KUBE-SERVICES ! -s 10.254.0.0/16 -d 172.30.0.10/32 -p tcp -m comment --comment "openshift-dns/dns-default:metrics cluster IP" -m tcp --dport 9153 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 172.30.0.10/32 -p tcp -m comment --comment "openshift-dns/dns-default:metrics cluster IP" -m tcp --dport 9153 -j KUBE-SVC-P2RWE722QPZ5K3VW >> [3]
```

Vemos que el servicio tiene dos reglas principales.
[1] Todo el trafico que tenga como destino (-d 172.30.0.10/32) protocolo udp (-p udp) y port destino 53 (--dport 53) lo remita (-j) a KUBE-SVC-BGNS3J6UB7MMLVDO
[2] idem [1] pero port tcp 53
[3] idem [1] pero port 9153

Si vemos la regla `KUBE-SVC-BGNS3J6UB7MMLVDO` encontramos que todo el trafico a la 172.30.0.10/3 lo remita a  los endpoint `KUBE-SEP-XXXXXXXXXXXXX` de manera random pero con un peso por probabilidad (--probability)
```
[root@worker1 ~]# iptables-save | grep KUBE-SVC-BGNS3J6UB7MMLVDO
:KUBE-SVC-BGNS3J6UB7MMLVDO - [0:0]
-A KUBE-SERVICES -d 172.30.0.10/32 -p udp -m comment --comment "openshift-dns/dns-default:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-BGNS3J6UB7MMLVDO
-A KUBE-SVC-BGNS3J6UB7MMLVDO -m statistic --mode random --probability 0.16666666651 -j KUBE-SEP-RM5SOZAKVKA2GMP7 >> 1 
-A KUBE-SVC-BGNS3J6UB7MMLVDO -m statistic --mode random --probability 0.20000000019 -j KUBE-SEP-E7N2MVG6CMQUL637 >> 2
-A KUBE-SVC-BGNS3J6UB7MMLVDO -m statistic --mode random --probability 0.25000000000 -j KUBE-SEP-AYFHHMJUNNRZIILG >> 3
-A KUBE-SVC-BGNS3J6UB7MMLVDO -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-HRC6S4KWPIYWMKVP >> 4
-A KUBE-SVC-BGNS3J6UB7MMLVDO -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-2GYGZVZWX5UVIMQH >> 5
-A KUBE-SVC-BGNS3J6UB7MMLVDO -j KUBE-SEP-W6CIFXBQ6YMGCIIX >> 6
```

Detalle de cada uno de los endpoints
```
[root@worker1 ~]# iptables-save | grep KUBE-SEP-RM5SOZAKVKA2GMP7
:KUBE-SEP-RM5SOZAKVKA2GMP7 - [0:0]
-A KUBE-SVC-BGNS3J6UB7MMLVDO -m statistic --mode random --probability 0.16666666651 -j KUBE-SEP-RM5SOZAKVKA2GMP7    >> 1
-A KUBE-SEP-RM5SOZAKVKA2GMP7 -s 10.254.0.92/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-RM5SOZAKVKA2GMP7 -p udp -m udp -j DNAT --to-destination 10.254.0.92:5353
[root@worker1 ~]# iptables-save | grep KUBE-SEP-2GYGZVZWX5UVIMQH
:KUBE-SEP-2GYGZVZWX5UVIMQH - [0:0]
-A KUBE-SVC-BGNS3J6UB7MMLVDO -m statistic --mode random --probability 0.20000000019 -j KUBE-SEP-E7N2MVG6CMQUL637    >> 2
-A KUBE-SEP-E7N2MVG6CMQUL637 -s 10.254.1.115/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-E7N2MVG6CMQUL637 -p udp -m udp -j DNAT --to-destination 10.254.1.115:5353
[root@worker1 ~]# iptables-save | grep KUBE-SEP-AYFHHMJUNNRZIILG
:KUBE-SEP-AYFHHMJUNNRZIILG - [0:0]
-A KUBE-SVC-BGNS3J6UB7MMLVDO -m statistic --mode random --probability 0.25000000000 -j KUBE-SEP-AYFHHMJUNNRZIILG    >> 3
-A KUBE-SEP-AYFHHMJUNNRZIILG -s 10.254.2.131/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-AYFHHMJUNNRZIILG -p udp -m udp -j DNAT --to-destination 10.254.2.131:5353
[root@worker1 ~]# iptables-save | grep KUBE-SEP-HRC6S4KWPIYWMKVP
:KUBE-SEP-HRC6S4KWPIYWMKVP - [0:0]
-A KUBE-SVC-BGNS3J6UB7MMLVDO -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-HRC6S4KWPIYWMKVP    >> 4
-A KUBE-SEP-HRC6S4KWPIYWMKVP -s 10.254.3.114/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-HRC6S4KWPIYWMKVP -p udp -m udp -j DNAT --to-destination 10.254.3.114:5353
[root@worker1 ~]# iptables-save | grep KUBE-SEP-2GYGZVZWX5UVIMQH
:KUBE-SEP-2GYGZVZWX5UVIMQH - [0:0]
-A KUBE-SVC-BGNS3J6UB7MMLVDO -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-2GYGZVZWX5UVIMQH    >> 5 >> nodo worker que tiene mayor probabilidad.
-A KUBE-SEP-2GYGZVZWX5UVIMQH -s 10.254.4.74/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-2GYGZVZWX5UVIMQH -p udp -m udp -j DNAT --to-destination 10.254.4.74:5353
[root@worker1 ~]# iptables-save | grep KUBE-SEP-W6CIFXBQ6YMGCIIX                                                    >> 6
:KUBE-SEP-W6CIFXBQ6YMGCIIX - [0:0]
-A KUBE-SVC-BGNS3J6UB7MMLVDO -j KUBE-SEP-W6CIFXBQ6YMGCIIX                                           
-A KUBE-SEP-W6CIFXBQ6YMGCIIX -s 10.254.6.95/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-W6CIFXBQ6YMGCIIX -p udp -m udp -j DNAT --to-destination 10.254.6.95:5353
[root@worker1 ~]#
```

Si miramos los pods sobre los que balanceo el servicio tenemos:
```
Pod Name            Pod IP         Node IP        Status    Node
dns-default-hn4b8   10.254.2.131   10.252.7.234   Running   master2.ocp4.labs.semperti.local
dns-default-hpj4h   10.254.6.95    10.252.7.237   Running   worker2.ocp4.labs.semperti.local
dns-default-j9qsv   10.254.1.115   10.252.7.233   Running   master1.ocp4.labs.semperti.local
dns-default-jdqrp   10.254.4.74    10.252.7.236   Running   worker1.ocp4.labs.semperti.local >> iptables-save
dns-default-x6srm   10.254.0.92    10.252.7.232   Running   master0.ocp4.labs.semperti.local
dns-default-xmhww   10.254.3.114   10.252.7.235   Running   worker0.ocp4.labs.semperti.local
```

El parametros `random --probability` asigna un valor numero decime a cada regla y el chequeo es secuencial top down. 

- 1ra regla indica el 16% de las consultas caeran en esta regla el resto (84%) seguira a la segunda regla.
- 2da regla indica que el 20% de los 84% que no cayeron en la regla 1ra caeran en esta regla el resto seguira.
- 3ra regla indica que el 25% de del trafico que no ha cadido en las reglas anteriores caera en esta regla, el resto seguira.
- 4ta regla indica que el 30% de del trafico que no ha cadido en las reglas anteriores caera en esta regla, el resto seguira.
- 5ta regla indica que el 50% de del trafico que no ha cadido en las reglas anteriores caera en esta regla, el resto seguira.
- 6ta regla registrara todo el remanente.


Notas Utiles:
- Iptables random --probability
    https://scalingo.com/blog/iptables

- TcpDump en Openshift
    https://access.redhat.com/solutions/4537671