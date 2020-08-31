# Openshift Monitoring AlertManager

## Contexto

El stack de monitoreo se personaliza creando un configmap en el proyecto openshift-monitoring. En este configmap se pueden configurar lo que respecta a nodeSelectors, tolaration, persistentVolume, retención de datos y algunas pocas cosas más, no muchas. El servicio en si se hace vía configmaps, secrets u operadores específicos.


### Cluster Monitoring

Para la configuración del stack completo hay que crear un configmaps y este lo podemos ver en esta documentación.

[Configuring Alertmanger](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.3/html/monitoring/cluster-monitoring#configuring-alertmanager)

### Alermanager

Para el caso de las alertas hay dos vías. Para las versiones más nuevas de openshift, en teoría para las versión 4.3 en adelante, en la consola web hay un apartado de Alerting donde se pueden configurar alertmanager pasandole el archivo yaml de configuración que vamos a ver abajo y esto crear un secret en el proyecto `openshift-monitoring` con nombre `alergmanager-main` con toda la configuración de alertmanager. En caso que las opciones de la consola web no estén hay que hacerlo vía cli. Para esto hay que seguir los pasos que detallo debajo y están en el link. El link no dice mucho respecto a la configuración, solo los pasos para poder dar con el archivo y como posteriormente subirlo.

[Configuring Alertmanager](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.3/html/monitoring/cluster-monitoring#configuring-alertmanager)


### Conceptos previos

Unos conceptos previos, en Alertmanager vamos a tener alert `routing` (aca la alertas) y como destino de esas alertas vamos a enviarlas a un `reciever` (quien forwardea la alerta). Lo que nosotros tenemos que configurar principalmente para que nos lleguen las alertas son los `receivers` que es como le vamos a decir a Alertmanager donde enviar.

### Configuracion por CLI

```bash
oc -n openshift-monitoring get secret alertmanager-main --template='{{ index .data "alertmanager.yaml" }}' |base64 -d > alertmanager.yaml
```

el archivo por defecto tiene este formato. Editamos o creamos el archivo `alertmanager.yaml`

```yaml
global:
  resolve_timeout: 5m
receivers:
- name: null
route:
  group_by:
  - job
  group_interval: 5m
  group_wait: 30s
  receiver: null
  repeat_interval: 12h
  routes:
  - match:
      alertname: Watchdog
    receiver: null
```

Dejo un archivo de ejemplo donde uso distintos `recievers` de emails. Para poder hacer uso de esto, los nodos de infra que son los nodos donde vive alermanager en caso de que hayan sido fijados via `nodeSelecter`, debe tener permisos para poder usar un relay smtp que se indica en la sección global del archivo. 

El archivo modificado de `alertmanager.yaml` sería la siguiente.

```yaml
global:
  resolve_timeout: 5m
  smtp_from: 'OCP Prometheus <ocp-dev@semperti>'
  smtp_smarthost: smtp-relay.semperti.com:25
  smtp_hello: smtp-relay.semperti.com
  smtp_require_tls: false
receivers:
- name: team_ocpadmin_email
  email_configs:
    - to: ocpadmin@semperti.com
- name: team_devops_email
  email_configs:
    - to: devops@semperti.com
- name: team_app1_email
  email_configs:
    - to: teamapp1@semperti.com
- name: team_app2_email
  email_configs:
    - to: teamapp2@semperti.com
- name: null
route:
  group_by: ['alertname', 'cluster', 'service']
  group_interval: 5m
  group_wait: 30s
  repeat_interval: 12h
  receiver: null
  routes:
  - match:
      alertname: Watchdog
    receiver: team_ocpadmin_email
  - match_re:
      namespace: ^(openshift|kube)$
    receiver: team_ocpadmin_email
  - match_re:
      alertname: ^(Cluster|Cloud|Machine|Pod|Kube|MCD|Alertmanager|etcd|TargetDown|CPU|Node|Clock|Prometheus|Failing|Network|IPTable)$
    receiver: team_ocpadmin_email
  - match:
      severity: critical
    receiver: team_ocpadmin_email
  - match_re:
      namespace: ^(app1-dev|app1-test|app1-homo)$
    receiver: team_app1_email
  - match_re:
      namespace: ^(app2-dev|app2-test|app2-homo)$
    receiver: team_app2_email
```

Una vez que tiene el archivo configurado de manera deseada, lo debemos subir

```
oc -n openshift-monitoring create secret generic alertmanager-main --from-file=alertmanager.yaml --dry-run -o=yaml |  oc -n openshift-monitoring replace secret --filename=-
```

Los ejemplos que puse son justamente ejemplos y si quieren mas configuración, como por ejemplo integrarse con slack, hacer mejores filtros por servicios, etc hay que configurarlo segun la documentación oficial de alertmanager.

### Información Adicional

Les dejo un link con una configuración en un repo de github con ejemplos de emails y un ejemplo para usar channels de Microsoft Teams

* [Alertmanager ejemplo de configuración](ttps://github.com/prometheus/alertmanager/blob/master/doc/examples/simple.yml)
* [Alertmanager para MS Teams](https://github.com/prometheus-msteams/prometheus-msteams)

 

Cualquier cosa avísame y coordinamos meter mano.