#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
print ('========== [ping]')
ping ()

project_id = "__gst__multi_user"
sample_id = "sample"
sample_ids = "[\"sample\"]"

print ('========== [newProject]')
print ('       ... project_id -> ' + project_id)
reply = send_request ('newProject', data={'project_id': project_id})
check_reply (reply, None)

print ('========== [newSamples]')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_ids -> ' + sample_ids)
reply = send_request ('newSamples', data={'project_id': project_id, 'sample_ids': sample_ids })
check_reply (reply, None)

user_ids = ['alice', 'bob', 'charlie']
conll_file = "fr_gsd-ud-test_00006.conllu"

print ('========== [saveConll] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
print ('       ... user_id -> alice, bob & charlie')
print ('       ... conll_file -> ' + conll_file)
for user_id in user_ids:
    print (user_id)
    with open(conll_file+"_"+user_id, 'rb') as f:
        reply = send_request (
            'saveConll',
            data = {'project_id': project_id, 'sample_id': sample_id },
            files={'conll_file': f},
            )
        check_reply (reply, None)

