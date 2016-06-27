## WebApp Demo

### 说明
这个例子尝试发布一个基于Http协议的web应用，基于Nginx Ingress Controller，通过7层反向代理在集群外部访问我们的服务，
[Nginx Ingress Controller](https://github.com/kubernetes/contrib/tree/master/ingress/controllers/nginx)。



### 部署流程

* 发布**Nginx Ingress Controller**

发布ingress controller的 rc

```
kubectl create -f rc-ingress-controller.yaml
```

发布default-http-backend，用于处理404的请求

```
kubectl create -f rc-default-backend.yaml
kubectl expose rc default-http-backend --port=80 --target-port=8080 --name=default-http-backend
```

* 发布web服务
这个web服务会返回一个```Hello World```的字符串。

```
kubectl create -f rc-hello.yaml
```

* 发布Service

```
kubectl create -f service-hello.yaml
```

* 发布Ignress规则，选择相应的Service

```
kubectl create -f ingress.yaml
```

* 查看Ingress Rule

```
NAME      RULE            BACKEND   ADDRESS        AGE
hello     -                         172.17.8.102   1h
          hello.bar.com
          /               hellos:8080
```

* 通过域名访问hellos服务

```
curl 172.17.8.102 -H 'Host: hello.bar.com'
```

### 关于Ingress
* **Ingress**:一般来说集群内部的服务之间可以通过Service的虚拟IP地址进行访问，当集群外部的程序想要访问集群内部的程序时，就需要通过Ingress来访问了。详见[Ingress](http://kubernetes.io/docs/user-guide/ingress/#what-is-ingress)。

```
    internet
        |
   [ Ingress ]
   --|-----|--
   [ Services ]

```

* **Ingress Controller**:Ingress Controller是Ingress的一种实现，通常是一种Loadbalancer。它会监听ApiServer的/ingresses接口的变化从而将外部的请求转发至集群内部的地址。详见[说明1](https://github.com/kubernetes/contrib/tree/master/ingress/controllers)和[说明2](http://kubernetes.io/docs/user-guide/ingress/#ingress-controllers)。




