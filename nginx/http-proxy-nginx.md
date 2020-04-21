

# Nginx 配置L7 HTTP 代理
## Mac 本地生成HTTPS 密钥
### 生成私钥key


```
openssl genrsa -out server.key 2048
```

### 生成自签名证书

```
openssl req -new -sha256 -x509 -days 365 -key server.key -out server.crt
```
```
junsong-macbookpro:~ junsong$ openssl req -new -sha256 -x509 -days 365 -key server.key -out server.crt
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:china
string is too long, it needs to be less than  2 bytes long
```



### 证书copy至nginx配置目录

```
cp server.key server.crt  /usr/local/etc/nginx/
```

## nginx.conf 配置
### mac


```
vim  /usr/local/etc/nginx/nginx.conf  
```
### GCE


```
vim  /etc/nginx/nginx.conf 
```


完整的配置文件


```
events {
  worker_connections  4096;  ## Default: 1024
}

http {
	log_format   main '$remote_addr - $remote_user [$time_local]  $status '
	    '"$request" $body_bytes_sent "$http_referer" '
	    '"$http_user_agent" "$http_x_forwarded_for"';
	  access_log   logs/access.log  main;
	  
  
   #设定实际的服务器列表，负载均衡模式
     upstream back_server{
         server 34.107.169.196:80;
     }
	  
	  server { # simple reverse-proxy
	     listen       80;
	     server_name  localhost;
	     access_log   logs/localhost.access.log  main;

	     # pass requests for dynamic content to rails/turbogears/zope, et al
	     location / {
	       proxy_pass      http://back_server/;
	     }
	   }

	   
	   server{
           listen  443 ssl;
           server_name localhost;

           ssl_certificate      /usr/local/etc/nginx/server.crt;
           ssl_certificate_key /usr/local/etc/nginx/server.key;
           ssl_session_timeout 5m;
           ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
           ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
           ssl_prefer_server_ciphers on;

           location / {
               proxy_pass  http://back_server/;
		   }
	     }
   

}
```

# 启动测试


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

80端口


```
curl -I  localhost:80
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


443端口，注意浏览器对自签名证书的屏蔽

[https://localhost](https://localhost)
