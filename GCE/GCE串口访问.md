

# GCE 串口登陆

参考文档：[https://cloud.google.com/compute/docs/instances/interacting-with-serial-console#standardssh](https://cloud.google.com/compute/docs/instances/interacting-with-serial-console#standardssh)

实验机器：ssh-key-test



---



# Enable 串口访问权限


## 添加GCE Metadata 启用串口


### 目标为整个项目级别

gcloud 命令


```
gcloud compute project-info add-metadata --metadata serial-port-enable=TRUE
```


Console Metadata UI 添加Key Value

![image](https://github.com/JunHash/gcp-playgroud-public/blob/master/pics/project-metadata.png)

# 目标为单个实例

gcloud 命令


```
gcloud compute instances add-metadata instance-name \
        --metadata serial-port-enable=TRUE
```


Console 启用串口

编辑GCE Enable 串口

![image](https://github.com/JunHash/gcp-playgroud-public/blob/master/pics/%E5%90%AF%E5%8A%A8%E4%B8%B2%E5%8F%A3.png)

# 设置连接用户Password


## SSH 可以登陆的情况


### SSH 连接GCE，创建用户和口令


```
sudo passwd  [username]
```



## SSH 无法登陆


### 重启脚本新建用户口令

通过metadata 添加 GCE 启动脚本，并且reset重启生效(否则不会重载metadata)

替换username 和password


```
gcloud compute instances add-metadata instance-name \
        --metadata startup-script=#! /bin/bash
adduser username
echo 'username:password' | chpasswd
usermod -aG google-sudoers password
```


串口Log


```
Apr 29 05:44:09 ssh-key-test GCEGuestAgent[659]: 2020-04-29T05:44:09.9838Z GCEGuestAgent Info: Updating keys for user gke-473db88ad1cb03b3ac0b.
Apr 29 05:44:10 ssh-key-test GCEMetadataScripts[662]: 2020/04/29 05:44:10 GCEMetadataScripts: startup-script: adduser: The user `junsong' already exists.
```


Console UI 方式

编辑并reset GCE

![image](https://github.com/JunHash/gcp-playgroud-public/blob/master/pics/%E5%90%AF%E5%8A%A8%E8%84%9A%E6%9C%AC.png)


## 连接串口


## GCP Console 连接方式

点击连接至串口按钮，自动生成ssh 登陆至串口.输入之前创建好的username password


```
Debian GNU/Linux 9 ssh-key-test ttyS0

ssh-key-test login: junsong
Password: 
```



### 查看ssd 进程的状态    

```
ps -ef|grep ssh

root       683     1  0 05:44 ?        00:00:00 /usr/sbin/sshd -D
root       909   683  0 05:44 ?        00:00:00 sshd: junsong [priv]
junsong    915   909  0 05:44 ?        00:00:00 sshd: junsong@pts/0
junsong    918   915  0 05:44 ?        00:00:00 /usr/lib/openssh/sftp-server
junsong    955   931  0 05:58 ttyS0    00:00:00 grep ssh
```


如果处于dead状态，可以手动star sshd进程

```
sudo service sshd status

 ssh.service - OpenBSD Secure Shell server
   Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enab
led)
   Active: active (running) since Wed 2020-04-29 05:44:08 UTC; 16min 
ago
  Process: 661 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
 Main PID: 683 (sshd)
    Tasks: 5 (limit: 4915)
   CGroup: /system.slice/ssh.service
           ├─683 /usr/sbin/sshd -D
           ├─909 sshd: junsong [priv]
           ├─915 sshd: junsong@pts/0
           ├─916 -bash
           └─918 /usr/lib/openssh/sftp-server

Apr 29 05:44:08 ssh-key-test systemd[1]: Starting OpenBSD Secure Shell server...
Apr 29 05:44:08 ssh-key-test systemd[1]: Started OpenBSD Secure Shell server.
Apr 29 05:44:08 ssh-key-test sshd[683]: Server listening on 0.0.0.0 port 22.
Apr 29 05:44:08 ssh-key-test sshd[683]: Server listening on :: port 22.
Apr 29 05:44:32 ssh-key-test sshd[909]: Accepted publickey for junsong from 173.
194.93.****  port 55220 ssh2: ECDSA SHA256:NM7wO6NKbs1v5pd+tpV93oNhfuK4PCbx******
HOY
Apr 29 05:44:32 ssh-key-test sshd[909]: pam_unix(sshd:session): session opened f
or user junsong by (uid=0)
```



## sshd 操作


```
sudo service sshd start|restart|stop
sudo service sshd status
```



## SSH Key 连接方式



*   project-id：此实例的项目 ID。
*   zone：实例的地区。
*   instance-name：实例的名称。
*   username：您用于连接实例的用户名。通常是本地机器上的用户名。
*   options：您可以为此连接指定的其他选项。例如，您可以指定某个串行端口并指定任何[高级选项](https://cloud.google.com/compute/docs/instances/interacting-with-serial-console#advanced_options)。端口号可以是 1 到 4（包括 1 和 4）。如需详细了解端口号，请参阅[了解串行端口编号](https://cloud.google.com/compute/docs/instances/interacting-with-serial-console#understanding_serial_port_numbering)。如果忽略该选项，您将连接到串行端口 1

    ```
ssh -i private-ssh-key-file -p 9600 myproject.us-central1-f.example-instance.jane@ssh-serialport.googleapis.com
```



<!-- Docs to Markdown version 1.0β22 -->
