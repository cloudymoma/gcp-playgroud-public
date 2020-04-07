# GCE Add SSH Key Hands-on
官方参考文档    
[Managing SSH keys in metadata | Compute Engine Documentation](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys)


# Mac 生成ssh key pair
mac 本地生成普通用户(junsong)和root用户key pair
```
ssh-keygen -t rsa -f ~/.ssh/ssh-key-gce -C junsong
ssh-keygen -t rsa -f ~/.ssh/ssh-key-gce-root -C root
```
查看生成的public key, 密钥格式：ssh-rsa [KEY_VALUE] [USERNAME]    
```
cat ~/.ssh/ssh-key-gce.pub

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCas6wmBz/FJzaTEcQfdCku/iLQT26roxUMa775ofTNepKpgDl50k3fkMltWMcMmeXRiZjAJX9ygMy+6/zU/pjQhpSpZbO8frcPljIj6TfmIZVe4mnNMWNRHi0v8GDw41nt1ZRKo78oRMC9eoxNMX9aO6TE/gERWwPHfVzgC24RvOr0iGUMJw8M1Glb0bsNPFXEz******* junsong
```

```
cat ~/.ssh/ssh-key-gce-root.pub

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIVOY1pkhrXch9Vm3GkWhqdD0esFJATBhZTEcNnVZ0qw2OrRMS5mOgo5E5nrjGyBYD4aNps7Zl3LHn0v5/ha2FzTOGRytsDcsjS4NyfoArgJbrGdGzDoh1irV3fnf6Sh9xTsgWGMo2XGMkuDOgYmHhTEx6cS+y+Ng17fYs6CMP7mKAkM5o9I6QRRxm8rR3mzOI3PoRNrCVoABgH3cV******* root
```

# GCE 配置SSH Public Key
检查GCE TCP 22 端口是否打开  
![image](https://github.com/JunHash/gcp-playgroud-public/blob/master/GCE/pics/22%20port.png)  

编辑GCE,添加ssh pub key : junsong key 和 root key  
![image](https://github.com/JunHash/gcp-playgroud-public/blob/master/GCE/pics/add%20ssh%20key.png)  


# SSH 连接测试
## junsong 用户登陆 （普通用户）
```
ssh -i ssh-key-gce junsong@35.223.69.207

junsong-macbookpro:.ssh junsong$ ssh -i ssh-key-gce junsong@35.223.69.207
The authenticity of host '35.223.69.207 (35.223.69.207)' can't be established.
ECDSA key fingerprint is SHA256:gVGGL/TWOafHxuGFoW6Hl8yj48DYn2CMB45BAcIlAAM.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '35.223.69.207' (ECDSA) to the list of known hosts.
Linux ssh-key-test 4.9.0-11-amd64 #1 SMP Debian 4.9.189-3+deb9u2 (2019-11-11) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
``` 
验证普通用户root 权限
```
sudo su

root@ssh-key-test:/home/junsong# ls
``` 
## root 用户ssh连接
```
ssh -i ssh-key-gce-root root@35.223.69.207

junsong-macbookpro:.ssh junsong$ ssh -i ssh-key-gce-root root@35.223.69.207
Linux ssh-key-test 4.9.0-11-amd64 #1 SMP Debian 4.9.189-3+deb9u2 (2019-11-11) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
root@ssh-key-test:~# 

``` 
### 注意：ssh 默认不允许root用户直接登陆。

修改配置如下：
```
sudo vim /etc/ssh/sshd_config

PermitRootLogin no #允许root登录，修改为yes
``` 
重启服务
```
sudo /etc/init.d/ssh restart
``` 
