import requests

url = "http://localhost:8080/upl"

payload = {}
files=[
  ('files',('file_A',open('file_A','rb'),'application/octet-stream')),
  ('files',('file_B',open('file_B','rb'),'application/octet-stream'))
]
headers = {}

response = requests.request("POST", url, headers=headers, data=payload, files=files)

print(response.text)
