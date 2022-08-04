# How to generate a pod to test

- Launch simple pod based in nginx + simple tools.

```
$ oc new-project devops
$ oc run --generate=run-pod/v1 --image=gonzaloacosta/tools
```

- Connect to run-pod

```
oc rsh tools -n devops
$ curl ifconfig.me
```

Test connection with curl

```bash
$ oc run --generate=run-pod/v1 --image=gonzaloacosta/tools -- curl ifconfig.me
```

Test connection with netcat

```bash
$ oc exec -it tools -n devops -- nc -zv 172.30.0.1 443
Connection to 172.30.0.1 443 port [tcp/https] succeeded!
```

Even if you have a friend called Nicolas C. that needs to test connection with a external database, could you test with the follow command.

```
$ export DB_HOST=172.20.10.10
$ export DB_PORT=3306
$ oc exec -it tools -n devops -- nc -zv $DB_HOST $DB_PORT 
Connection to 172.20.10.10 3306 port [tcp/mysql] succeeded!
```

> NOTE: you could choose with a nginx images, however I've added other tools detailes [here](https://github.com/gonzaloacosta/docker-nginx-awscli-python3.git)
