

# python_redis_cron镜像制作-prom监控kvm

## ubuntu

### 镜像部署

```shell
# 镜像名：get_kms_prom:v1
# 暴露端口: 5000
# 可替换容器内配置文件路径： /root/config
# 配置文件在容器中的绝对路径： /root/config/ip.conf
# 配置文件格式（逐行，每行一个ip，下为示例,： <<!...!为注释）：
: <<!
cat > /root/config/ip.conf << \EOF
xxx.xxx.xxx.xxx
xxx.xxx.xxx.xxx
EOF
!
# docker部署可以参考方式:
#docker run -d -p 8000:5000 -v ~/k4pconfig:/root/config --name=get_kms_prom get_kms_prom:v1 && docker logs -f get_kms_prom
#监控获取的url地址（ip、端口替换为部署主机和映射端口）
#curl http://127.0.0.1:8000/metrics
```



### 生成python3.8环境、单机版redis和定时任务的基础环境镜像 py_redis_cron:base（可复用，复用可参考get_kms_prom构建方法）

```shell
# 创建目录
mkdir -p ~/dockerfile/base/py_redis_cron
cd ~/dockerfile/base/py_redis_cron

# 下载pip下载脚本
curl -L -O https://bootstrap.pypa.io/get-pip.py

# 编辑pip.conf
cat << EOF > ~/dockerfile/base/py_redis_cron/pip.conf
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host = mirrors.aliyun.com
EOF

# 编写py_redis_cron主进程脚本
cat > ~/dockerfile/base/py_redis_cron/run.sh << \EOF
#!/bin/sh
/etc/init.d/cron start
/etc/init.d/rsyslog start
/etc/init.d/redis-server start
while [ true ]; do
  sleep 1
done
EOF

cat > ~/dockerfile/base/py_redis_cron/sources.list << \EOF
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
EOF

# 编写dockerfile文件
cat > ~/dockerfile/base/py_redis_cron/dockerfile << \EOF
FROM ubuntu:18.04
MAINTAINER sam@samz.site

#安装依赖组件

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
COPY sources.list /etc/apt/

#cron
RUN apt-get update && apt-get -y install apt-utils vim cron rsyslog tzdata lsof
#redis
RUN apt-get -y install redis-server
#python
RUN apt-get remove python3.6 -y && apt-get -y install python3.8 python3-setuptools

# 添加时区支持
RUN echo "Asia/Shanghai" > /etc/timezone
RUN rm -f /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

# 取消权限控制
RUN sed -i '/pam_loginuid.so/s%session%#session%g' /etc/pam.d/cron

# 对cron的日志记录
RUN sed -i '/cron.log/s%^#cron.%cron.%g' /etc/rsyslog.d/50-default.conf

# 对取消redis的ipv6的监听
RUN sed -i '/^bind 127.0.0.1/s% ::1%%g' /etc/redis/redis.conf

# 安装pip3.8
WORKDIR /root
COPY get-pip.py .
RUN python3.8 get-pip.py

# 配置pip为国内源
RUN mkdir -p /root/.pip
COPY pip.conf /root/.pip/

#拷贝运行文件
COPY run.sh .

CMD ["sh","/root/run.sh"]

EOF

#创建镜像
docker build -t py_redis_cron:base .

#实验
#docker run -it --rm --name=py_redis_cron py_redis_cron:base
#docker run -d --name=py_redis_cron py_redis_cron:base
#docker exec -it py_redis_cron /bin/bash

#docker rm py_redis_cron -f
# 删除退出的镜像
#for i in `docker ps -a|grep Exited|awk '{ print $1 }'`; do docker rm $i; done
# 删除过程生成的被替换的镜像
#for i in `docker images|grep "<none>                         <none>"|awk '{print $3}'`; do docker rmi $i; done
```

### 生成获取kvm数据并web展示的镜像 get_kms_prom:v1

```shell
mkdir -p ~/dockerfile/work/get4prom/get_kms_prom
cd ~/dockerfile/work/get4prom/get_kms_prom

# 编写定时任务的配置 get_kms_cron
cat > ~/dockerfile/work/get4prom/get_kms_prom/get_kms_cron << \EOF
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
*/1 * * * * /usr/bin/python3.8 /root/get_kms.py > /dev/null 2>&1
EOF

# 编写配置文件 逐行放置serverip
cat > ~/dockerfile/work/get4prom/get_kms_prom/ip.conf << \EOF
192.168.0.242
192.168.200.221
EOF

# 编写redis配置文件 必须含有127.0.0.1
cat > ~/dockerfile/work/get4prom/get_kms_prom/redis.conf << \EOF
127.0.0.1
192.168.0.221
EOF

# 编写kvm主进程脚本
cat > ~/dockerfile/work/get4prom/get_kms_prom/run.sh << \EOF
#!/bin/sh
/etc/init.d/cron start
/etc/init.d/rsyslog start
/etc/init.d/redis-server start
python3.8 /root/kms4prom.py
while [ true ]; do
  sleep 1
done
EOF
```
```shell
### python脚本
#
### 定时收集数据脚本 get_kms.py
cat > ~/dockerfile/work/get4prom/get_kms_prom/get_kms.py << \EOF
```
```python
#!/usr/bin/env python3
# -*- encoding: utf-8 -*-
'''
@File : get_kms.py.py
@Contact : 15130091299@139.com
@Modify Time     @Author  @Version  @Desciption
---------------  -------  --------  -----------
2020/10/28 14:28      Sam       1.0  None
'''

#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import asyncio
import json
import random
import time

import redis

import websockets
from jsonrpcclient.clients.websockets_client import WebSocketsClient

stats_report_key = 'KMS_STATS'
# released_report_key = 'KMS_RELEASED_PIPELINES'
# old_report_key = 'KMS_OLD_PIPELINES'
# zombies_key = 'KMS_ZOMBIES'

servers = []
redis_servers = []
url_pre = 'ws://'
url_post = ':8888/kurento'

f = open("d:/config/ip.conf")      # 返回一个文件对象
line = f.readline()         # 调用文件的 readline()方法

while line:
    servers.append("%s%s%s" % (url_pre,line.strip('\n'),url_post))
    line = f.readline()
f.close()

f = open("d:/config/redis.conf")      # 返回一个文件对象
line = f.readline()         # 调用文件的 readline()方法

while line:
    redis_servers.append(line.strip('\n'))
    line = f.readline()
f.close()

redis_yj = '192.168.200.221'

reports = {}

release_no_webrtc = False

# 30 minutes old
old_threshold = 30 * 60
# 60 minutes release
release_threshold = 60 * 60

zombie_pipelines = {}
old_pipelines = {}
released_pipelines = {}

all_pipelines = {}

# minutes
pipeline_max_alive = 30


def get_counter():
    return time.thread_time_ns() + random.randint(1000000, 9999999)


async def query_kurento():
    for url in servers:
        report = {'kurento_alive': 0,
                  'kurento_used_memory': 0,
                  'kurento_used_cpu': 0.0,
                  'kurento_total_pipelines': 0,
                  'kurento_total_endpoints': 0,
                  'kurento_total_alerts': 0,
                  'kurento_total_safeties': 0,
                  'kurento_total_emergencies': 0,
                  'kurento_total_players': 0,
                  'report_time': ''}
        server_old_pipelines = []
        server_released_pipelines = []
        try:
            async with websockets.connect(url) as ws:
                report['kurento_alive'] = 1
                report['report_time'] = time.strftime('%Y-%m-%d %H:%M:%S',
                                                      time.localtime(
                                                          time.time()))
                session_id = await get_session(ws)

                pipelines = await get_pipelines(ws, session_id)

                # check & release

                for pipeline in pipelines:
                    creation_time = await get_creation_time(ws, session_id, pipeline)
                    children = await get_children(ws, session_id, pipeline)

                    '''
                    if str(children).rfind('WebRtcEndpoint') == -1:
                        zombie_pipelines.append({'pipeline': pipeline,
                                                 'release_time': time.strftime('%Y-%m-%d %H:%M:%S',
                                                                               time.localtime(
                                                                                   time.time())),
                                                 'creation_time': time.strftime('%Y-%m-%d %H:%M:%S',
                                                                                time.localtime(
                                                                                    creation_time)),
                                                 'children': children})
                        if release_no_webrtc:
                            await release(ws, session_id, pipeline)
                            server_released_pipelines.append(
                                {'release_reason': 'NoWebRtcEndPoint', 'pipeline': pipeline,
                                 'release_time': time.strftime('%Y-%m-%d %H:%M:%S',
                                                               time.localtime(
                                                                   time.time())),
                                 'creation_time': time.strftime('%Y-%m-%d %H:%M:%S',
                                                                time.localtime(
                                                                    creation_time)),
                                 'children': children})
                            continue
                            '''

                    if (time.time() - creation_time) > release_threshold:
                        await release(ws, session_id, pipeline)

                        server_released_pipelines.append({'release_reason': 'TimeOut', 'pipeline': pipeline,
                                                          'release_time': time.strftime('%Y-%m-%d %H:%M:%S',
                                                                                        time.localtime(
                                                                                            time.time())),
                                                          'creation_time': time.strftime('%Y-%m-%d %H:%M:%S',
                                                                                         time.localtime(
                                                                                             creation_time)),
                                                          'children': children})

                    '''
                    if (time.time() - creation_time) > old_threshold:
                        server_old_pipelines.append(
                            {'pipeline': pipeline,
                             'check_time': time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time())),
                             'creation_time': time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(creation_time)),
                             'children': children})
                    print(pipeline, children)
                    '''
                report['kurento_used_memory'] = await get_used_memory(ws, session_id)
                report['kurento_used_cpu'] = await get_used_cpu(ws, session_id)

                # stats
                pipelines = await get_pipelines(ws, session_id)
                report['kurento_total_pipelines'] = len(pipelines)
                for pipeline in pipelines:
                    tags = await get_tags(ws, session_id, pipeline)

                    if pipeline in all_pipelines:
                        all_pipelines[pipeline]['tags'] = tags
                    '''
                    if pipeline in zombie_pipelines:
                        zombie_pipelines[pipeline]['tags'] = tags
                    '''

                    for tag in tags:
                        if tag['key'] != 'feature':
                            continue

                        if tag['value'] == 'ALERT':
                            report['kurento_total_alerts'] = report['kurento_total_alerts'] + 1
                        if tag['value'] == 'EMERGENCY':
                            report['kurento_total_emergencies'] = report['kurento_total_emergencies'] + 1
                        if tag['value'] == 'SAFETY':
                            report['kurento_total_safeties'] = report['kurento_total_safeties'] + 1
                        if tag['value'] == 'PLAYER':
                            report['kurento_total_players'] = report['kurento_total_players'] + 1

        except IOError as e:
            print('===>', e)

        finally:
            pass

        reports[url] = report
        '''
        old_pipelines[url] = json.dumps(server_old_pipelines)
        released_pipelines[url] = json.dumps(server_released_pipelines)
        '''


async def get_session(ws):
    res = await WebSocketsClient(ws).request('describe', object='manager_ServerManager',
                                             request_id=get_counter())
    return res.data.result['sessionId']


async def get_used_memory(ws, session_id):
    res = await WebSocketsClient(ws).request('invoke', object='manager_ServerManager',
                                             operation='getUsedMemory', sessionId=session_id,
                                             request_id=get_counter())
    return int(res.data.result['value']) / 1024 / 1024

async def get_used_cpu(ws, session_id):
    res = await WebSocketsClient(ws).request('invoke', object='manager_ServerManager',
                                             operation='getUsedCpu',operationParams={"interval": "50"}, sessionId=session_id,
                                             request_id=get_counter())
    return float(res.data.result['value'])


async def get_pipelines(ws, session_id):
    res = await WebSocketsClient(ws).request('invoke', object='manager_ServerManager',
                                             operation='getPipelines', sessionId=session_id,
                                             request_id=get_counter())
    return process_response(res)


async def get_tags(ws, session_id, media_object):
    res = await WebSocketsClient(ws).request('invoke', object=media_object,
                                             operation='getTags', sessionId=session_id,
                                             request_id=get_counter())
    return process_response(res)


async def release(ws, session_id, media_object):
    res = await WebSocketsClient(ws).request('release', object=media_object, sessionId=session_id,
                                             request_id=get_counter())
    print(media_object, ' has been released!')
    return res.data


async def get_creation_time(ws, session_id, pipeline):
    res = await WebSocketsClient(ws).request('invoke', object=pipeline,
                                             operation='getCreationTime', sessionId=session_id,
                                             request_id=get_counter())
    return process_response(res)


def process_response(res):
    if not res:
        return []

    if not res.data:
        return []

    if not res.data.result:
        return []

    if 'value' in res.data.result:
        return res.data.result['value']

    print(type(res.data.result), res.data.result)


async def get_children(ws, session_id, pipeline):
    res = await WebSocketsClient(ws).request('invoke', object=pipeline,
                                             operation='getChildren', sessionId=session_id,
                                             request_id=get_counter())
    return process_response(res)


asyncio.get_event_loop().run_until_complete(query_kurento())

def report_to_redis(redis_host, report_key, server, msg, expire=0):
    try:
        client = redis.Redis(host=redis_host,decode_responses=True)
        client.hset(report_key, server, json.dumps(msg))
        if expire > 0:
            client.expire(report_key, expire)
        client.close()
    except Exception as e:
        print(e)
    finally:
        pass


def do_report(kms_uri, report_key, msg, expire=0):
    print(msg)
    print(kms_uri)
    report_to_redis(redis_yj, report_key, kms_uri, msg, expire)

for k, v in reports.items():
    do_report(k, stats_report_key, v, 60 * 5)

'''
for k, v in released_pipelines.items():
    if len(eval(v)) > 0:
        do_report(k, released_report_key, eval(v), 60 * 60)

for k, v in old_pipelines.items():
    if len(eval(v)) > 0:
        do_report(k, old_report_key, eval(v), 60 * 60)

for k, v in zombie_pipelines.items():
    if len(eval(v)) > 0:
        do_report(k, zombies_key, eval(v), 60 * 60)
'''

```
```shell
EOF
### python脚本
#
### web查询脚本 kms4prom.py
cat > ~/dockerfile/work/get4prom/get_kms_prom/kms4prom.py << \EOF

```
```python
#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import prometheus_client
from prometheus_client.core import CollectorRegistry
from prometheus_client import Gauge
from flask import Response, Flask
import redis
import json

redis_host = '127.0.0.1'

stats_report_key = 'KMS_STATS'

servers = []
url_pre = 'ws://'
url_post = ':8888/kurento'

f = open("/root/config/ip.conf")             # 返回一个文件对象
line = f.readline()             # 调用文件的 readline()方法
while line:
    servers.append(line.strip('\n'))
    line = f.readline()
f.close()

default = {'kurento_alive': 0,
                  'kurento_used_memory': 0,
                  'kurento_total_pipelines': 0,
                  'kurento_total_endpoints': 0,
                  'kurento_total_alerts': 0,
                  'kurento_total_safeties': 0,
                  'kurento_total_emergencies': 0,
                  'kurento_total_players': 0,
                  'report_time': ''}

def redis_to_report(redis_host, report_key, server):
    try:
        client = redis.Redis(host=redis_host,decode_responses=True)
        url=("%s%s%s" % (url_pre ,server , url_post))
        print(client.hget(report_key,url))
        prom = json.loads(client.hget(report_key,url))
        return prom or default
    except Exception as e:
        print(e)
    finally:
        pass

app = Flask(__name__)

#### 定义路由
@app.route("/metrics")
def ApiResponse():
    # 如果返回多个metrics
    #### 定义一个仓库，存放数据
    REGISTRY = CollectorRegistry(auto_describe=False)
    for server in servers:
        report = {'kurento_alive': 0,
                  'kurento_used_memory': 0,
                  'kurento_total_pipelines': 0,
                  'kurento_total_endpoints': 0,
                  'kurento_total_alerts': 0,
                  'kurento_total_safeties': 0,
                  'kurento_total_emergencies': 0,
                  'kurento_total_players': 0,
                  'report_time': ''}

        kurento_alive = Gauge("kurento_alive"+"_"+server.replace('.','_'), "Api response stats is:", registry=REGISTRY)
        kurento_used_memory = Gauge("kurento_used_memory"+"_"+server.replace('.','_'), "Api response stats is:", registry=REGISTRY)
        kurento_total_pipelines = Gauge("kurento_total_pipelines"+"_"+server.replace('.','_'), "Api response stats is:", registry=REGISTRY)
        kurento_total_endpoints = Gauge("kurento_total_endpoints"+"_"+server.replace('.','_'), "Api response stats is:", registry=REGISTRY)
        kurento_total_alerts = Gauge("kurento_total_alerts"+"_"+server.replace('.','_'), "Api response stats is:", registry=REGISTRY)
        kurento_total_safeties = Gauge("kurento_total_safeties"+"_"+server.replace('.','_'), "Api response stats is:", registry=REGISTRY)
        kurento_total_emergencies = Gauge("kurento_total_emergencies"+"_"+server.replace('.','_'), "Api response stats is:", registry=REGISTRY)
        kurento_total_players = Gauge("kurento_total_players"+"_"+server.replace('.','_'), "Api response stats is:", registry=REGISTRY)

        report=redis_to_report(redis_host ,stats_report_key ,server)

        kurento_alive.set(report['kurento_alive'])
        kurento_used_memory.set(report['kurento_used_memory'])
        kurento_total_pipelines.set(report['kurento_total_pipelines'])
        kurento_total_endpoints.set(report['kurento_total_endpoints'])
        kurento_total_alerts.set(report['kurento_total_alerts'])
        kurento_total_safeties.set(report['kurento_total_safeties'])
        kurento_total_emergencies.set(report['kurento_total_emergencies'])
        kurento_total_players.set(report['kurento_total_players'])

    return Response(prometheus_client.generate_latest(REGISTRY),mimetype="text/plain")

if __name__ == "__main__":
    app.run(host="0.0.0.0")

```
```shell
EOF
# 编写dockerfile文件
# 构建此镜像 依赖下面的两个脚本
cat > ~/dockerfile/work/get4prom/get_kms_prom/dockerfile << \EOF
FROM py_redis_cron:base
MAINTAINER sam@samz.site

RUN pip3.8 install prometheus_client flask websockets jsonrpcclient redis

# 创建配置文件目录
RUN mkdir -p /root/config

COPY ip.conf /root/config/
COPY redis.conf /root/config/

# 拷贝定时任务配置
COPY get_kms_cron .

# 配置定时任务
RUN crontab /root/get_kms_cron

# 拷贝获取kvm信息的脚本
COPY get_kms.py .

# 拷贝为prom提供数据的脚本
COPY kms4prom.py .

#拷贝运行文件
COPY run.sh .

EXPOSE 5000

EOF

#创建镜像
docker build -t get_kms_prom:v3 . --no-cache

# 实验
# 宿主机创建一个目录  可以保存配置文件ip.conf 用于挂载 生效需重启docker实例
# mkdir -p ~/k4pconfig
: <<!
cat > ~/k4pconfig/ip.conf << \EOF
192.168.0.242
EOF
!

# docker部署
# docker rm get_kms_prom -f

# docker run -d -p 5000:5000 --name=get_kms_prom get_kms_prom:v3 && docker logs -f get_kms_prom

# docker run -d -p 5000:5000 --name=get_kms_prom -v /root/k4pconfig:/root/config get_kms_prom:v3 && docker logs -f get_kms_prom

# curl http://127.0.0.1:5000/metrics

# docker logs -f get_kms_prom

# docker exec -it get_kms_prom /bin/bash


# 删除过程生成的被替换的镜像
# for i in `docker images|grep "<none>                         <none>"|awk '{print $3}'`; do docker rmi $i; done 
# docker save -o get_kms_prom_v2.tar get_kms_prom:v2
# docker image load -i get_kms_prom_v2.tar
# docker image tag get_kms_prom:v2 harbor.video110.cn/op/monitor-server:kurento_v4
# docker push harbor.video110.cn/op/monitor-server:kurento_v4
```

---

---

### 生成基础镜像cron:base（只添加了对定时任务的支持，副产品没用到）

```shell
#创建目录
mkdir -p ~/dockerfile/base/cron
cd ~/dockerfile/base/cron

#编写cron主进程脚本
cat > ~/dockerfile/base/cron/run.sh << \EOF
#!/bin/sh
/etc/init.d/cron start
/etc/init.d/rsyslog start
while [ true ]; do
  sleep 1
done
EOF

cat > ~/dockerfile/base/cron/dockerfile << \EOF
FROM ubuntu:18.04
MAINTAINER sam@samz.site

#安装依赖组件
RUN apt-get update && apt-get -y install cron rsyslog tzdata

#添加时区支持
RUN echo "Asia/Shanghai" > /etc/timezone
RUN rm -f /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

#取消权限控制
RUN sed -i '/pam_loginuid.so/s%session%#session%g' /etc/pam.d/cron

#对cron的日志记录
RUN sed -i '/cron.log/s%^#cron.%cron.%g' /etc/rsyslog.d/50-default.conf

#拷贝运行文件
WORKDIR /root
COPY run.sh .

CMD ["sh","/root/run.sh"]

EOF

#创建镜像
docker build -t cron:base .

#实验
#docker run -it --rm --name=cron cron:base

#删除过程生成的被替换的镜像
#for i in `docker images|grep "<none>                         <none>"|awk '{print $3}'`; do docker rmi $i; done
```