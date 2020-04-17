# iperf 网络测试
## install iperf3
客户端 Mac
```
wget http://downloads.es.net/pub/iperf/iperf-3-current.tar.gz
tar zxvf iperf-3-current.tar.gz

cd iperf-3.6/
./configure
make
make install
```
版本验证
```
junsong-macbookpro:iperf-3.6 junsong$ iperf3 -v
iperf 3.6 (cJSON 1.5.2)
Darwin junsong-macbookpro.roam.corp.google.com 18.7.0 Darwin Kernel Version 18.7.0: Mon Feb 10 21:08:45 PST 2020; root:xnu-4903.278.28~1/RELEASE_X86_64 x86_64
Optional features available: sendfile / zerocopy
```

服务端VM
junsong@jp
```
sudo apt-get install iperf3
```

## 生成网络测试报告
### 服务端启动
```
iperf3 -s
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```

### 模拟客户端测试
```
iperf3 -c 34.85.92.222  -p 5201
```

### 网络测试报告
双向网络性能
mac 连接vm 上行测试
```
junsong-macbookpro:iperf-3.6 junsong$ iperf3 -c 34.85.92.222  -p 5201
Connecting to host 34.85.92.222, port 5201
[  5] local 172.19.0.115 port 56955 connected to 34.85.92.222 port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec   651 KBytes  5.31 Mbits/sec                  
[  5]   1.00-2.00   sec  3.38 MBytes  28.3 Mbits/sec                  
[  5]   2.00-3.00   sec  0.00 Bytes  0.00 bits/sec                  
[  5]   3.00-4.00   sec  0.00 Bytes  0.00 bits/sec                  
[  5]   4.00-5.00   sec   277 KBytes  2.27 Mbits/sec                  
[  5]   5.00-6.00   sec  1.15 MBytes  9.60 Mbits/sec                  
[  5]   6.00-7.00   sec  27.4 KBytes   225 Kbits/sec                  
[  5]   7.00-8.00   sec  1.10 MBytes  9.21 Mbits/sec                  
[  5]   8.00-9.00   sec  1.21 MBytes  10.2 Mbits/sec                  
[  5]   9.00-10.00  sec  1.31 MBytes  10.9 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-10.00  sec  9.08 MBytes  7.61 Mbits/sec                  sender
[  5]   0.00-10.00  sec  8.86 MBytes  7.43 Mbits/sec                  receiver

iperf Done.
```
vm -> mac 下行数据
```
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 203.208.61.208, port 38198
[  5] local 10.146.0.2 port 5201 connected to 203.208.61.208 port 40767
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-1.00   sec   221 KBytes  1.81 Mbits/sec                  
[  5]   1.00-2.00   sec  1.80 MBytes  15.1 Mbits/sec                  
[  5]   2.00-3.00   sec  90.6 KBytes   743 Kbits/sec                  
[  5]   3.00-4.00   sec  1.36 MBytes  11.4 Mbits/sec                  
[  5]   4.00-5.00   sec   425 KBytes  3.48 Mbits/sec                  
[  5]   5.00-6.00   sec  1.19 MBytes  9.99 Mbits/sec                  
[  5]   6.00-7.00   sec   259 KBytes  2.12 Mbits/sec                  
[  5]   7.00-8.00   sec  1.05 MBytes  8.78 Mbits/sec                  
[  5]   8.00-9.00   sec  1.22 MBytes  10.3 Mbits/sec                  
[  5]   9.00-10.00  sec  1.26 MBytes  10.6 Mbits/sec                  
[  5]  10.00-10.28  sec  5.18 KBytes   153 Kbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-10.28  sec  0.00 Bytes  0.00 bits/sec                  sender
[  5]   0.00-10.28  sec  8.86 MBytes  7.23 Mbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201
```

## 参数说明
```
-f [k|m|K|M] 分别表示以Kbits, Mbits, KBytes, MBytes显示报告，默认以Mbits为单位,eg:iperf -c 222.35.11.23 -f K 
-i sec 以秒为单位显示报告间隔，eg:iperf -c 222.35.11.23 -i 2
-l 缓冲区大小，默认是8KB,eg:iperf -c 222.35.11.23 -l 16 -m 显示tcp最大mtu值 
-o 将报告和错误信息输出到文件eg:iperf -c 222.35.11.23 -o c:\iperflog.txt 
-p 指定服务器端使用的端口或客户端所连接的端口eg:iperf -s -p 9999;iperf -c 222.35.11.23 -p 9999 
-u 使用udp协议 
-w 指定TCP窗口大小，默认是8KB 
-B 绑定一个主机地址或接口（当主机有多个地址或接口时使用该参数）
-C 兼容旧版本（当server端和client端版本不一样时使用）
-M 设定TCP数据包的最大mtu值
-N 设定TCP不延时
-V 传输ipv6数据包   server专用参数 
-D 以服务方式运行ipserf，eg:iperf -s -D -R 停止iperf服务，针对-D，eg:iperf -s -R  
client端专用参数 
-d 同时进行双向传输测试 
-n 指定传输的字节数，eg:iperf -c 222.35.11.23 -n 100000
-r 单独进行双向传输测试 
-t 测试时间，默认10秒,eg:iperf -c 222.35.11.23 -t 5
-F 指定需要传输的文件
-T 指定ttl值 
```