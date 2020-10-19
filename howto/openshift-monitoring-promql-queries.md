# Openshift Monitoring

## PromQL Query

* APIServer

```
cluster:apiserver_request_duration_seconds:mean5m
cluster_quantile:apiserver_request_duration_seconds:histogram_quantile

rate(apiserver_request_duration_seconds_sum[5m])
histogram_quantile(0.99, rate(apiserver_request_duration_seconds_bucket[5m]))

rate(apiserver_request_total[5m])
```