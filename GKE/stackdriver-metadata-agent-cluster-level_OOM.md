# stackdriver-metadata-agent-cluster-level OOM 解决方案

1. 更改`metadata-agent`分配充足的内存

```
kubectl edit cm -n kube-system metadata-agent-config
```

```yaml
apiVersion: v1
data:
  NannyConfiguration: |-
    apiVersion: nannyconfig/v1alpha1
    kind: NannyConfiguration
    **baseMemory: 50Mi**
kind: ConfigMap
```

如果问题依旧存在，可以尝试`100Mi`甚至`200Mi`

2. 重启部署

```
kubectl delete deployment -n kube-system stackdriver-metadata-agent-cluster-level
```
