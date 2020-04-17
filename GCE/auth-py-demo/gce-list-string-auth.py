'''
This program lists lists the Google Compute Engine Instances in one zone
'''

'''
{
  "type": "service_account",
  "project_id": "devopev",
  "private_key_id":
  "private_key": "-
  "client_email": 
  "client_id": "106820067785346742139",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/service-account-gcs%40devopev.iam.gserviceaccount.com"
}
'''




import time
import json
import jwt
import requests
import httplib2
def load_json_credentials(filename):
    ''' Load the Google Service Account Credentials from Json file '''

    with open(filename, 'r') as f:
        data = f.read()

    return json.loads(data)


def load_private_key(json_cred):
    ''' Return the private key from the json credentials '''

    return json_cred['private_key']


def create_signed_jwt(pkey, pkey_id, email, scope):
    '''
    Create a Signed JWT from a service account Json credentials file
    This Signed JWT will later be exchanged for an Access Token
    '''

    # Google Endpoint for creating OAuth 2.0 Access Tokens from Signed-JWT
    auth_url = "https://www.googleapis.com/oauth2/v4/token"

    issued = int(time.time())
    expires = issued + expires_in   # expires_in is in seconds

    # Note: this token expires and cannot be refreshed. The token must be recreated

    # JWT Headers
    additional_headers = {
        'kid': pkey_id,
        "alg": "RS256",
        "typ": "JWT"    # Google uses SHA256withRSA
    }

    # JWT Payload
    payload = {
        "iss": email,       # Issuer claim
        "sub": email,       # Issuer claim
        "aud": auth_url,    # Audience claim
        "iat": issued,      # Issued At claim
        "exp": expires,     # Expire time
        "scope": scope      # Permissions
    }

    # Encode the headers and payload and sign creating a Signed JWT (JWS)
    #sig = jwt.JWT().encode(payload, pkey,optional_headers=additional_headers)
    sig = jwt.encode(payload, pkey, algorithm="RS256",
                     headers=additional_headers)

    return sig


def exchangeJwtForAccessToken(signed_jwt):
    '''
    This function takes a Signed JWT and exchanges it for a Google OAuth Access Token
    '''

    auth_url = "https://www.googleapis.com/oauth2/v4/token"

    params = {
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": signed_jwt
    }

    r = requests.post(auth_url, data=params)

    if r.ok:
        return(r.json()['access_token'], '')

    return None, r.text


def gcs_list(accessToken):

    # Create the HTTP url for the Google Storage REST API
    url = "https://www.googleapis.com/storage/v1/b?project=" + project

    # One of the headers is "Authorization: Bearer $TOKEN"
    headers = {
        "Host": "www.googleapis.com",
        "Authorization": "Bearer " + accessToken,
        "Content-Type": "application/json"
    }
    h = httplib2.Http()
    resp, content = h.request(uri=url, method="GET", headers=headers)
    s = content.decode('utf-8').replace('\n', '')
    j = json.loads(s)
    print('')
    print('Buckets')
    print('----------------------------------------')
    for item in j['items']:
        print(item['name'])



def gce_list_instances(accessToken,zone):
    
    #This functions lists the Google Compute Engine Instances in one zone
   

    # Endpoint that we will call
    url = "https://www.googleapis.com/compute/v1/projects/" + \
        project + "/zones/" + zone + "/instances"

    # One of the headers is "Authorization: Bearer $TOKEN"
    headers = {
        "Host": "www.googleapis.com",
        "Authorization": "Bearer " + accessToken,
        "Content-Type": "application/json"
    }

    h = httplib2.Http()

    resp, content = h.request(uri=url, method="GET", headers=headers)

    status = int(resp.status)
    
    if status < 200 or status >= 300:
        print('Error: HTTP Request failed\n')
        print(status)
        return

    j = json.loads(content.decode('utf-8').replace('\n', ''))

    print('Compute instances in zone', zone)
    print('------------------------------------------------------------')
    for item in j['items']:
        print(item['name'])


if __name__ == '__main__':

    private_key = ""
    private_key_id = ""
    client_email = "service-accou******@devopev.iam.gserviceaccount.com"

    project = 'd***'
    zone = 'us-central1-a'
    scopes = "https://www.googleapis.com/auth/cloud-platform"
    expires_in = 3600   # Expires in 1 hour

    s_jwt = create_signed_jwt(
        private_key,
        private_key_id,
        client_email,
        scopes)

    token, err = exchangeJwtForAccessToken(s_jwt)

    if token is None:
        print('Error:', err)
        exit(1)
    #gcs_list(token)
    gce_list_instances(token,zone)
