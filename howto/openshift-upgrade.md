## Upgrade Openshfit v4.x

* Consultar listado de versiones sobre la cual podemos actualizar

```
oc adm upgrade
```

* Actualizar cluster a una version especifica

```
oc adm upgrade --to=4.3.21
```

* Actualizar el cluster a una version especifica de modo forzado

```
oc adm upgrade --to=4.3.21 --force
```

* Controlar que el upgrade progrese de manera correcta

```
watch -n 2 'oc get co'
```

* En caso de deseemos ver el detalle de un cluster operator

```
export CLUSTEROPERATOR=<cluster_operator_name>
oc describe co $CLUSTEROPERATOR
```
