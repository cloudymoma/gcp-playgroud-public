from googleapiclient import discovery
from google.oauth2 import service_account

scopes = ['https://www.googleapis.com/auth/cloud-platform']
sa_file = 'service-account.json'
zone = 'us-central1-a'
project_id = 'my_project_id' # Project ID, not Project Name

credentials = service_account.Credentials.from_service_account_file(sa_file, scopes=scopes)

# Create the Cloud Compute Engine service object
service = discovery.build('compute', 'v1', credentials=credentials)

request = service.instances().list(project=project_id, zone=zone)
while request is not None:
    response = request.execute()

    for instance in response['items']:
        # TODO: Change code below to process each `instance` resource:
        print(instance)

    request = service.instances().list_next(previous_request=request, previous_response=response)