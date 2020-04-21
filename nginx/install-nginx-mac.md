

# Nginx 安装配置---MAC
## 命令预览
```
sudo nginx (front)
sudo nginx -s reload|reopen|stop|quit
brew services start nginx (backend)
ps -ef| grep nginx

open /usr/local/var/www
open  /usr/local/etc/nginx/nginx.conf

/usr/local/Cellar/nginx/1.17.3_1/logs/access.log
```


#  Mac 安装 nginx 


## brew 安装nginx


```
brew install nginx
```

## 查看信息核心操作


```
brew info nginx
```

Docroot默认为 /usr/local/var/www, 在/usr/local/etc/nginx/nginx.conf 配置文件中默认的端口为8080， 且nginx将在/usr/local/etc/nginx/servers 目录中加载所有文件，  
日志：/usr/local/Cellar/nginx/1.17.3_1/logs/access.log。  
并且我们可以通过最简单的命令'nginx' 来启动nginx


## 启动nginx

```
sudo nginx (front)
sudo nginx -s reload|reopen|stop|quit
brew services start nginx (backend)
ps -ef| grep nginx
```

> Debug

 local 访问拒绝，ps -ef| grep nginx 找不到进程。brew services start nginx 命令启动错误不会主动提示。发现配置文件不存在, 卸载重新安装即可

打开日志后启动sudo nginx出错, 解决方案如下：
```
sudo mkdir /usr/local/Cellar/nginx/1.17.3_1/logs/
sudo touch /usr/local/Cellar/nginx/1.17.3_1/logs/access.log
```

## 配置nginx

打开日志要创建：/usr/local/Cellar/nginx/1.17.3_1/logs/access.log 参考上述debug


```
open /usr/local/var/www
open  /usr/local/etc/nginx/nginx.conf
```

