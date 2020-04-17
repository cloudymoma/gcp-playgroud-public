from googleapiclient import discovery
from google.oauth2 import service_account
import json

zone = 'us-central1-a'
project_id = 'devopev' # Project ID, not Project Name

# dict service_account_info
service_account_info = {
  "private_key_id": "78bb1bab70d74c87c2d7fa04e6714a20233***",
  "private_key": "******",
  "client_email":"service-accoun****@devopev.iam.gserviceaccount.com",
  "token_uri": "https://oauth2.googleapis.com/token",
}

credentials = service_account.Credentials.from_service_account_info(service_account_info)
# Create the Cloud Compute Engine service object
service = discovery.build('compute', 'v1', credentials=credentials)

request = service.instances().list(project=project_id, zone=zone)
while request is not None:
    response = request.execute()

    for instance in response['items']:
        # TODO: Change code below to process each `instance` resource:
        print(instance['name'])

    request = service.instances().list_next(previous_request=request, previous_response=response)