#!/bin/bash -ex

__create_topic() {
  gcloud pubsub topics create projects/du-hast-mich/topics/log-alert-topic 
}

__deploy() {
  gcloud functions deploy log_alert_py \
    --gen2 \
    --region=us-central1 \
    --runtime=python312 \
    --source=. \
    --entry-point=dingo_alert \
    --trigger-topic=projects/du-hast-mich/topics/log-alert-topic \
    --retry
    #--source=gs://my-bucket/my_function_source.zip \
}
 
__send_msg() {
  gcloud pubsub topics publish \
    projects/du-hast-mich/topics/log-alert-topic \
    --message="from cloudfunctions"
}

__send_msg_curl() {
  curl -m 70 -X POST https://us-central1-du-hast-mich.cloudfunctions.net/log_alert_py \
    -H "Authorization: bearer $(gcloud auth print-identity-token)" \
    -H "Content-Type: application/json" \
    -H "ce-id: 1234567890" \
    -H "ce-specversion: 1.0" \
    -H "ce-type: google.cloud.pubsub.topic.v1.messagePublished" \
    -H "ce-time: 2020-08-08T00:11:44.895529672Z" \
    -H "ce-source: //pubsub.googleapis.com/projects/du-hast-mich/topics/log-alert-topic" \
    -d '{
      "message": {
        "_comment": "data is base64 encoded string of '\''Hello World'\''",
        "data": "SGVsbG8gV29ybGQ="
      }
    }'
}

__log() {
  gcloud functions logs read \
    --gen2 \
    --region=us-central1 \
    --limit=5 \
    log_alert_py
}

#__crerate_topic
#__deploy
#__send_msg
__send_msg_curl
#__log

