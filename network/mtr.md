# mtr 网络测试
结合ping 和traceroute
## install mtr
```
brew install mtr

$ mtr -v
mtr 0.93
```

## 生成网络测试报告
### 模拟客户端测试
```
sudo mtr -r www.baidu.com

Start: 2020-04-17T14:58:59+0800
HOST: junsong-macbookpro.roam.cor Loss%   Snt   Last   Avg  Best  Wrst StDev
  1.|-- us-mtv-43-wmc1-vlan-250.n  0.0%    10    7.8  12.5   6.3  61.1  17.1
  2.|-- 192.168.110.17             0.0%    10    7.1  10.9   6.4  22.3   6.5
  3.|-- 103.104.153.252            0.0%    10    6.5  13.0   6.5  21.8   6.1
  4.|-- pr01-xe-4-2-0-521.pek10.n  0.0%    10    8.2  29.9   6.5 155.8  45.5
  5.|-- ar01-ae10.pek12.net.googl  0.0%    10   31.4  45.7   7.0 230.0  71.0
  6.|-- 219.142.13.141            90.0%    10    9.6   9.6   9.6   9.6   0.0
  7.|-- bj141-147-230.bjtelecom.n  0.0%    10  219.5 211.4  17.4 431.9 101.5
  8.|-- 202.97.48.206             10.0%    10  266.6 178.8  98.4 266.6  48.7
  9.|-- 202.97.58.94              10.0%    10  210.6 136.9  47.5 313.4  80.3
 10.|-- xe-1-0-4.r27.tokyjp05.jp. 20.0%    10  156.2 166.9 141.4 255.8  39.9
 11.|-- ae-1.r30.tokyjp05.jp.bb.g 10.0%    10  199.5 150.4 130.8 200.2  28.4
 12.|-- ae-4.r24.tkokhk01.hk.bb.g 40.0%    10  166.0 203.6 163.9 369.7  81.8
 13.|-- ae-1.r02.tkokhk01.hk.bb.g  0.0%    10  254.4 244.1 141.1 278.8  39.2
 14.|-- ae-2.a01.newthk03.hk.bb.g 40.0%    10  193.8 223.9 181.2 366.6  71.0
 15.|-- 203.131.254.138           10.0%    10  176.2 191.5 173.1 266.4  31.0
 16.|-- 103.235.45.2              20.0%    10  329.3 329.2 319.7 349.1   8.7
 17.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 18.|-- 103.235.46.39             10.0%    10  217.2 219.5 216.5 221.8   1.9
```
```
sudo mtr -r 34.85.92.222

Start: 2020-04-17T15:18:28+0800
HOST: junsong-macbookpro.roam.cor Loss%   Snt   Last   Avg  Best  Wrst StDev
  1.|-- 172.19.0.129               0.0%    10   49.8  63.4  19.0 140.1  41.5
  2.|-- 192.168.110.17             0.0%    10   52.2  31.6   6.2  88.3  28.6
  3.|-- 103.104.153.252            0.0%    10   13.1  28.7   6.4  87.0  27.0
  4.|-- pr01-xe-4-2-0-521.pek10.n  0.0%    10    7.9  17.0   6.7  54.9  15.8
  5.|-- pr01-ae4.hkg07.net.google  0.0%    10   47.8  91.7  45.4 250.7  66.4
  6.|-- bb04-ae2.hkg08.net.google  0.0%    10   47.5  77.0  47.5 196.5  47.7
  7.|-- bx05-be13.hkg07.net.googl  0.0%    10   48.6  76.9  45.9 143.3  33.3
  8.|-- bx03-be12.hnd12.net.googl  0.0%    10  277.2 271.1  96.9 355.5  87.6
  9.|-- bx01-be8.nrt13.net.google  0.0%    10  329.1 282.3  96.9 364.2  76.1
 10.|-- bb02-ae11.nrt13.net.googl  0.0%    10  272.9 291.4 162.1 373.5  54.6
 11.|-- cx02-vl100.nrt17.net.goog  0.0%    10  215.3 240.6 149.8 316.7  43.7
 12.|-- me02-pc5.nrt17.net.google  0.0%    10  159.8 184.6  94.1 260.4  43.9
 13.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 14.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 15.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 16.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 17.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 18.|-- ???                       100.0    10    0.0   0.0   0.0   0.0   0.0
 19.|-- 222.92.85.34.bc.googleuse  0.0%    10  173.9 162.7  93.3 221.3  36.5
```
