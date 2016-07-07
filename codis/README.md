# 在kubernetes部署codis

- 步骤是在vagrant部署3个coreos集群，通过配置cloud-config 把etcd2和flanneld启动。步骤[参考](https://coreos.com/os/docs/latest/booting-on-vagrant.html)
- 配置启动kubernetes集群，步骤按coreos.com的step-by-step文档进行(https://coreos.com/kubernetes/docs/latest/deploy-master.html)
	
	

### 制作image push到DockerHub
```
	docker build -t niexiaohu/codis-dashboard
	docker build -t niexiaohu/codis-server
	docker build -t niexiaohu/codis-proxy
```

### 部署codis zookeeper
    kubectl create -f zookeeper-rc.yaml
    kubectl create -f zookeeper-svc.yaml

### 部署 Codis Dashboard

```
kubectl get svc
NAME              CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
codis-zookeeper   10.3.0.216   <none>        2181/TCP   3m
kubernetes        10.3.0.1     <none>        443/TCP    12d
```

修改 dashboard-rc.yaml 里面 ```- name: ZOOKEEPER``` , value:为: ``` "10.3.0.216" ，PRODUCT 项目名称```
使用nodePort 为 30007提供Dashboard 访问端口。

```
kubectl create -f dashboard-rc.yaml
kubectl create -f dashboard-svc.yaml	
```

```
kubectl get ep
NAME              ENDPOINTS          AGE
codis-dashboard   10.1.91.3:18087    1h
codis-zookeeper   10.1.91.2:2181     2h
kubernetes        172.17.8.101:443   5d
```
初始化slots,进入 codis-bashboard 容器，执行初始化操作；
```
	$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini slot init
```
返回以下信息,表示成功；
```
{
  "msg": "OK",
  "ret": 0
}
```


### 创建codis-server

- 创建service
```
kubectl create -f codisserver-1-svc.yaml 
kubectl create -f codisserver-2-svc.yaml 
kubectl create -f codisserver-3-svc.yaml 
kubectl create -f codisserver-4-svc.yaml 
```
```
[root@controller codis]# kubectl get svc
NAME              CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
codis-server-1    10.3.0.249   <none>        6900/TCP              6d
codis-server-2    10.3.0.29    <none>        6900/TCP              6d
codis-server-3    10.3.0.220   <none>        6900/TCP              6d
codis-server-4    10.3.0.133   <none>        6900/TCP              6d
```
- 创建ReplicationControllers
```
kubectl create -f codisserver-1-rc.yaml 
kubectl create -f codisserver-2-rc.yaml 
kubectl create -f codisserver-3-rc.yaml 
kubectl create -f codisserver-4-rc.yaml 
```
```
[root@controller codis]# kubectl get svc
NAME              CLUSTER-IP   EXTERNAL-IP   PORT(S)               AGE
codis-server-1    10.3.0.249   <none>        6900/TCP              9d
codis-server-2    10.3.0.29    <none>        6900/TCP              9d
codis-server-3    10.3.0.220   <none>        6900/TCP              9d
codis-server-4    10.3.0.133   <none>        6900/TCP              9d
codis-zookeeper   10.3.0.216   <none>        2181/TCP              3d
```
### 添加 codis-server group
- 进入codis-dashboard容器 添加 codisserver的Service地址 
（将codis-server实例添加到codis集群中，每个Group 作为一个server服务组存在, 一组允许一个 master, 一个或多个slave。）
```
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini server add 1 10.3.0.249:6900 master
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini server add 1 10.3.0.29:6900 slave
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini server add 2 10.3.0.220:6900 master
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini server add 2 10.3.0.133:6900 slave
```
给server group分配slot,Codis 采用 Pre-sharding 的技术来实现数据的分片, 默认分成 1024 个 slots (0-1023)
```
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini slot range-set 0 511 1 online
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini slot range-set 512 1023 2 online
```
### 部署 codis-proxy

修改codis-proxy-rc.yaml 中的 DASHBOARD  ZOOKEEPER 只为 CLUSTER-IP 地址；PRODUCT 项目名同上面一致。
```
[root@controller codis]# kubectl get svc
NAME              CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
codis-dashboard   10.3.0.124   nodes         18087/TCP   2h
codis-server-1    10.3.0.249   <none>        6900/TCP    6d
codis-server-2    10.3.0.29    <none>        6900/TCP    6d
codis-server-3    10.3.0.220   <none>        6900/TCP    6d
codis-server-4    10.3.0.133   <none>        6900/TCP    6d
codis-zookeeper   10.3.0.216   <none>        2181/TCP    3h
kubernetes        10.3.0.1     <none>        443/TCP     12d

kubectl create -f codis-proxy-svc.yaml 
kubectl create -f codis-proxy-rc.yaml 

[root@controller codis]# kubectl get svc
NAME              CLUSTER-IP   EXTERNAL-IP   PORT(S)               AGE
codis-dashboard   10.3.0.124   nodes         18087/TCP             2h
codis-proxy       10.3.0.208   <none>        19000/TCP,11000/TCP   3m
codis-server-1    10.3.0.249   <none>        6900/TCP              6d
codis-server-2    10.3.0.29    <none>        6900/TCP              6d
codis-server-3    10.3.0.220   <none>        6900/TCP              6d
codis-server-4    10.3.0.133   <none>        6900/TCP              6d
codis-zookeeper   10.3.0.216   <none>        2181/TCP              3h
kubernetes        10.3.0.1     <none>        443/TCP               12d
```
使用 redis-cli 连接codis-proxy 的  CLUSTER-IP和端口测试,连续写入两次。
```
redis-cli -h 10.3.0.208 -p 19000
10.1.4.5:19000> set  /foo bar
OK
10.1.4.5:19000> set  /foo1 bar1
OK
```
连接 group_1 master:
```
./redis-cli -h 10.3.0.249 -p 6900 
10.1.4.3:6900> get /foo
"bar"
```
连接 group_2 master:
```
./redis-cli -h 10.3.0.220 -p 6900
10.1.4.3:6900> get /foo1
"bar1"
```
以上部署过程顺序和步骤集合人工去操作完成，有好的方法改进再更新。



