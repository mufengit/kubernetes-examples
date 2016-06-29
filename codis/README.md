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
kubectl get ep
NAME              ENDPOINTS          AGE
codis-zookeeper   10.1.91.3:2181     5h
kubernetes        172.17.8.101:443   5d
```

修改 dashboard-svc.yaml 里面 ```- name: ZOOKEEPER``` , value:为: ``` "10.1.91.3" ```

```
kubectl create -f dashboard-rc.yaml
kubectl create -f dashboard-svc.yaml	
```

```
kubectl get ep
NAME              ENDPOINTS          AGE
codis-dashboard   10.1.4.2:18087     5m
codis-zookeeper   10.1.91.3:2181     9h
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
codis-server-1    10.3.0.249   <none>        6900/TCP    16m
codis-server-2    10.3.0.29    <none>        6900/TCP    4m
codis-server-3    10.3.0.220   <none>        6900/TCP    3m
codis-server-4    10.3.0.133   <none>        6900/TCP    2m
```
- 创建ReplicationControllers
```
kubectl create -f codisserver-1-rc.yaml 
kubectl create -f codisserver-2-rc.yaml 
kubectl create -f codisserver-3-rc.yaml 
kubectl create -f codisserver-4-rc.yaml 
```
```
[root@controller codis]# kubectl get ep
NAME              ENDPOINTS          AGE
codis-server-1    10.1.4.3:6900      2h
codis-server-2    10.1.91.2:6900     2h
codis-server-3    10.1.4.4:6900      2h
codis-server-4    10.1.91.5:6900     2h
```
### 添加 codis-server group
- 进入codis-dashboard容器
（将codis-server实例添加到codis集群中，每个Group 作为一个server服务组存在, 一组允许一个 master, 一个或多个slave。）
```
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini server add 1 10.1.4.3:6900 master
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini server add 1 10.1.91.2:6900 slave
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini server add 2 10.1.4.4:6900 master
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini server add 2 10.1.91.5:6900 slave
```
给server group分配slot,Codis 采用 Pre-sharding 的技术来实现数据的分片, 默认分成 1024 个 slots (0-1023)
```
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini slot range-set 0 511 1 online
$CODIS_HOME/bin/codis-config -c $CODIS_HOME/codisconf/config.ini slot range-set 512 1023 2 online
```
### 部署 codis-proxy

修改codis-proxy-rc.yaml  DASHBOARD  ZOOKEEPER pod ip 地址；
```
codis-proxy-svc.yaml 
codis-proxy-rc.yaml 

[root@controller codis]# kubectl get ep
NAME              ENDPOINTS                       AGE
codis-dashboard   10.1.4.2:18087                  22h
codis-proxy       10.1.4.5:19000,10.1.4.5:11000   17h
codis-server-1    10.1.4.3:6900                   1d
codis-server-2    10.1.91.2:6900                  1d
codis-server-3    10.1.4.4:6900                   1d
codis-server-4    10.1.91.5:6900                  1d
codis-zookeeper   10.1.91.4:2181                  2d
kubernetes        172.17.8.101:443                7d
```
使用 redis-cli 连接codis-proxy 的 ip和端口测试：
```
redis-cli -h 10.1.4.5 -p 19000
10.1.4.5:19000> set  /foo bar
OK
```
连接 group_1 master:
```
./redis-cli -h 10.1.4.3 -p 6900 
10.1.4.3:6900> get /foo
"bar"
```
连接 group_1 slave:
```
./redis-cli -h 10.1.91.2 -p 6900
10.1.4.3:6900> get /foo
"bar"
```
以上部署过程顺序和步骤集合人工去操作完成，有好的方法改进再更新。



