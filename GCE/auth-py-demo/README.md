# Python Google Cloud 认证
## Run Code

### gce-list-string-auth   
环境配置
```
pip3 install PyJWT
pip3 install requests
```
```
python3 gce-list-string-auth.py

junsong-macbookpro:auth-py-demo junsong$ python3 gce-list-string-auth.py

Buckets
----------------------------------------
artifacts.devopev.appspot.com
brazil-bucket-test
vmdemo
Compute instances in zone us-central1-a
------------------------------------------------------------
costomize-hostname-dns
firebase-host
nginx-1
```
----
### gce-list-string-auth-v2.py   
[函数参考doc](https://google-auth.readthedocs.io/en/latest/reference/google.oauth2.service_account.html)   
[list all zone code](https://cloud.google.com/compute/docs/reference/rest/v1/zones/list#examples)
```
python3 gce-list-string-auth-v2.py

costomize-hostname-dns
firebase-host
gke-private-same-vpc
gke-privatecluster-test
```