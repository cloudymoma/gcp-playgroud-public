# GCP 平台原生告警发送到微信、钉钉和飞书

由于日志系统的告警格式等等细节无法直接调整，所以需要先把GCP原生告警通知配置到Pubsub。再Pubsub下触发一个Cloud Function来整理国内各个平台要求的数据报文格式。
最后发送至平台各个Endpoint/Webhook。

[GCP详细文档](https://cloud.google.com/functions/docs/tutorials/pubsub)

## Python

```python
import base64
import functions_framework
import requests
import json
import time
import os

feishu_endpoint = os.environ.get("FEISHU","")
wechat_webhook = os.environ.get("WECHAT", "")
dingtalk_webhook = os.environ.get("DINGTALK", "")

def send_feishu_msg(alert_msg):
  values = {
    "msg_type": "text",
    "content": {
      "text": alert_msg
    }
  }

  headers={'Content-Type': 'application/json'}
  r = requests.post(feishu_endpoint, json=values, headers=headers)
  r.encoding = 'utf-8'
  return (r.text)

def send_wechat_msg(alert_msg):
  values = {
    "msgtype":"text",
    "text":{
      "content": alert_msg
    }
  }
  headers={'Content-Type': 'application/json'}
  r = requests.post(wechat_webhook, json=values, headers=headers)
  r.encoding = 'utf-8'
  return (r.text)

def send_dingtalk_msg(alert_msg):
  values = {
    "msgtype":"text",
    "text":{
      "content": alert_msg
    }
  }
  headers={'Content-Type': 'application/json'}
  r=requests.post(dingtalk_webhook,data=json.dumps(values),headers=headers)
  r.encoding = 'utf-8'
  return (r.text)

# Triggered from a message on a Cloud Pub/Sub topic.
@functions_framework.cloud_event
def dingo_alert(cloud_event):
  # 这里检查下消息是不是在这样一个json结构里，做相应调整
  msg_decode = base64.b64decode(cloud_event.data["message"]["data"]).decode('utf-8')
  print("Pubsub msg is: ")
  print(msg_decode)

  msg = json.loads(msg_decode)
  print("msg json is : ")
  print(msg)

  status = msg['incident']['state']
  summary = msg['incident']['summary']
  started_at = time.ctime(msg['incident']['started_at'])
  ended_at = time.ctime(msg['incident']['ended_at'])
  project_id = msg['incident']['resource']['labels']['project_id']
  threshold_value = msg['incident']['threshold_value']
  observed_value = msg['incident']['observed_value']
  resource_display_name = msg['incident']['resource_display_name']
  policy_name = msg['incident']['policy_name']

  alert_msg = "Google Alarm Details:\n" + "Current State:" + status + "\n" \
  "started_at:" + started_at + "\n" \
  "ended_at:" + ended_at + "\n" \
  "Reason for State Change:" + summary + "\n" \
  "alert_policy:" + policy_name + "\n" \
  "threshold:" + threshold_value + "\n" \
  "observed_value:" + observed_value + "\n" \
  "resource_display_name:" + resource_display_name

  print(resource_display_name)

  print("Alert Message: ")
  print(alert_msg)

  if wechat_webhook != "":
    res = send_wechat_msg(alert_msg)
    print(res)

  if dingtalk_webhook != "":
    res = send_dingtalk_msg(alert_msg)
    print(res)

  if feishu_endpoint != "":
    res = send_feishu_msg(alert_msg)
    print(res)
```

## `requirements.txt`

```
functions-framework==3.*
requests==2.20.0
```