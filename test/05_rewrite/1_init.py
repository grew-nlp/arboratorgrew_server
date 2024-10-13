#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
print ('========== [ping]')
ping ()

project_id = "__gst__rewrite"
sample_id = "gsd_ud_dev_10"
sample_ids = "[\"gsd_ud_dev_10\"]"
conll_file = "gsd_ud_dev_10.conllu"
user_id = "ud"

print ('========== [newProject]')
print ('       ... project_id -> ' + project_id)
reply = send_request ('newProject', data={'project_id': project_id})
check_reply (reply, None)

print ('========== [newSamples]')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_ids -> ' + sample_ids)
reply = send_request ('newSamples', data={'project_id': project_id, 'sample_ids': sample_ids })
check_reply (reply, None)

print ('========== [saveConll] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
print ('       ... conll_file -> ' + conll_file)
with open(conll_file, 'rb') as f:
    reply = send_request (
        'saveConll',
        data = {'project_id': project_id, 'sample_id': sample_id },
        files={'conll_file': f},
    )
check_reply (reply, None)


sample_id = "gsd_ud_test_10"
sample_ids = "[\"gsd_ud_test_10\"]"
conll_file = "gsd_ud_test_10.conllu"
user_id = "ud"

print ('========== [newSamples]')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_ids -> ' + sample_ids)
reply = send_request ('newSamples', data={'project_id': project_id, 'sample_ids': sample_ids })
check_reply (reply, None)

print ('========== [saveConll] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
print ('       ... user_id -> ' + user_id)
print ('       ... conll_file -> ' + conll_file)
with open(conll_file, 'rb') as f:
    reply = send_request (
        'saveConll',
        data = {'project_id': project_id, 'sample_id': sample_id  },
        files={'conll_file': f},
    )
check_reply (reply, None)

