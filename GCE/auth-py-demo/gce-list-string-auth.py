'''
This program lists lists the Google Compute Engine Instances in one zone
'''

'''
{
  "type": "service_account",
  "project_id": "devopev",
  "private_key_id": "78bb1bab70d74c87c2d7fa04e6714a2023317757",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDqsSif2UMigPIj\nS9JqDm04FnV94yO4jrGKNXs1QixrlTl24zmwDJtILoR7LZCtSyuaPoPXA5cDzhF9\n58j14n6nqDpwHhrN89gJrejeZ9JpxYgQD4wcBIc0SsmLbxFw16SBAYfvdGkGS11x\n27iaGu0H9hvHg5ZRwunLW8vrAJkSXKCyV2o3iVesig1Te1pp3VFWXjqCK/VM+W4V\nbEij20li7qhiSG2qlfI/K99VLfs1qsJ8M2iZhuHTssa80Eg4/ocnIkI1lxrkxsZq\nvHf7/XzccRGBV3bCz8tErE60wfh9nzZC7bo12hd/un9kcr2GkKTYDFSYr+Uz1aV6\nVy78KZtbAgMBAAECggEABIFGEFtxSHZFL5xC+7ovKoZz1ujHRMGocsi4Bruwcpg4\ntCmEb/at/GK4NE0Zm9n3ikxs53GwMmiAOXR7jQy99aXrCT/qr81gdj8aWzqO9WzP\nQc+qltcXaU+OMtj88reQ9tD6tQP9CBvmPUtEbeDab+6vddL2zbb6Gec3MNmgFpQb\nL7+ssFDoCwd4ZAgxxMHkL5NmCaNYVJgpEc5KJWsqkIovVwsdAbqRZwSDSHP23J9U\ny6jJAeFz6Nq3fE8+tLux+gjsWBlXB2uV7ShrQoDFV0Xp2iz2RI4SlrxYlQz1bvUz\nppuKM+dNWU+m19WyqUtaTaKvxZCRNscPMXsHEYKQkQKBgQD7hTEDJxadnEXGIKis\nEuLIf6UTP02g0iyyeo+zS0fd+nDPQFaCY+jVwSnZd91XWaDKsmV0pPitZPJK4b6z\n3iULXRvikR4pO1tj2LzFW5ZKGmfeSxXc9Cghe0rmWumtxYv9kMvbkR0lPTa59dvk\nO+0TylzByL0zriAHkvOa2YFPfQKBgQDu3z0a9UMJCKIBS/AGdsshkgaPpeTZLCZX\nFX9kKLC6BKAPa4TViLIsCthyviEpPAzvcmLHDOGud/w+MMvG06U+Y0dqbF8S4XWx\nYEZuEFIQ9+k5tKqD7YRtyzmpL5xddTLX3qjTxJWes3SuVndowkrsbSDWurcdGjUD\nIsPswD09twKBgBvPGCIvGjMG6jgDuGJ+HBDq/Adqwlx7oHGDV4wNUL7cR8jCZk44\nWa/4kXX36MMVp8+BdfI1o0EYnillWD5u202sV77vKJSKeYpKlmSDwdQjo0RSrPIn\nFKDPDvL1Lk0GQHoinkeCfeR2JizdYBiV/5pmj2blmPWz1NrBhqmiTsfJAoGAJdgq\nZy36S+EZQZlVUsDZV905uuJuilWrUVqvjx+/OAlpjmfbaLU6fS3OswcaW90Os5Ts\nv1p0Gt8ZkITMlBiN8n9qHhtDSMt9iPeW0PM2/Uc5pRHRfgtQUtDCtuI7JLdfscGt\n/7cCeV03HDPIwUke86wqarq0LiEryu5kGgsu6KsCgYA58B4WC362Y5C7azqTYV/F\nsQBHgBxiYisj1lwtOb4n7VvSRASYhhnWLdvRhinboLtlEON23gH19z7MYa+lIaGp\nJWxc9eJnfjCwByNtNKGXqhM/xuDsq6B9Lyghlbb55F5hetN+KJqt+A7Y9fnmGEyh\nQMnDDbsQ49qaZfti6Wixwg==\n-----END PRIVATE KEY-----\n",
  "client_email": "service-account-gcs@devopev.iam.gserviceaccount.com",
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
