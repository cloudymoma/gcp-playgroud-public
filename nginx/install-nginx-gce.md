

# Nginx 安装配置---GCE
## 命令预览：

```
sudo service nginx start
sudo service nginx stop
ps -ef|grep nginx
vim  /etc/nginx/nginx.conf 
vim  /var/www/html/index.html

/var/log/nginx/access.log
/var/log/nginx/error.log
```
# GCE Install nginx
## apt-get 包依赖安装
```
sudo apt-get update
sudo apt-get install -y nginx
```


## 基本操作


```
sudo service nginx start
sudo service nginx stop
ps -ef|grep nginx
```



## Nginx 配置


```
vim  /etc/nginx/nginx.conf 
vim  /var/www/html/index.html
```


## 日志文件
```
/var/log/nginx/access.log
/var/log/nginx/error.log
```
