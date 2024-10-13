#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
print ('========== [ping]')
ping ()

project_id = "__gst__big_request"
sample_ids = "[\"IBA_32_Tori-By-Samuel_MG\"]"

print ('========== [newProject]')
print ('       ... project_id -> ' + project_id)
reply = send_request ('newProject', data={'project_id': project_id})
check_reply (reply, None)

print ('========== [newSamples]')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_ids -> ' + sample_ids)
reply = send_request ('newSamples', data={'project_id': project_id, 'sample_ids': sample_ids })
check_reply (reply, None)

with open('big.json') as json_file:
    data = json.load(json_file)
    tree = data["trees"][0]
    conll_graph = tree["conll"]
    sample_id = tree["sample_name"]
    user_id = data["user_id"]
    print(sample_id)
    reply = send_request ('saveGraph', data={'project_id': project_id, 'sample_id': sample_id, 'user_id': user_id, 'conll_graph': conll_graph })
    print (reply)