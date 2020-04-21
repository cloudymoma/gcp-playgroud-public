

# Nginx TCP 代理配置
## nginx.conf 配置
### mac


```
vim  /usr/local/etc/nginx/nginx.conf  
```



### GCE


```
vim  /etc/nginx/nginx.conf 
```

```
events {
  worker_connections  4096;  ## Default: 1024
}

stream{
   
   upstream testproxy{
        server  34.107.169.196:80 max_fails=3 fail_timeout=10s;  
    }
    server{
        listen 8082;
        proxy_connect_timeout 20s;
        proxy_timeout 5m;
        proxy_pass testproxy;
    }
}
```


## 启动测试


### Mac


```
sudo nginx (front)
sudo nginx -s reload|reopen|stop|quit
brew services start nginx (backend)
```



### GCE


```
sudo service nginx start
sudo service nginx stop
```



## 访问测试


```
curl -I  localhost:8082
HTTP/1.1 200 OK
Server: nginx/1.10.3
Date: Tue, 21 Apr 2020 16:02:55 GMT
Content-Type: text/html
Content-Length: 616
Last-Modified: Sun, 29 Sep 2019 08:04:27 GMT
ETag: "5d90658b-268"
Accept-Ranges: bytes
Via: 1.1 google
Age: 18
Cache-Control: public, max-age=120
```
