#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
print('========== [ping]')
ping()

project_id = "__gst__config"
sample_id = "zaar"
sample_ids = f'["{sample_id}"]'
conll_file = "zaar.conllu"

# create project
print('========== [newProject]')
print('       ... project_id -> ' + project_id)
reply = send_request('newProject', data={'project_id': project_id})
check_reply(reply, None)

# update config
config_file = 'config1.json'
print('========== [updateProjectConfig]')
print('       ... project_id -> ' + project_id)
print('       ... config_file -> ' + config_file)
with open(config_file) as f:
  config = f.read()
  reply = send_request('updateProjectConfig', data={ 'project_id': project_id, 'config': config})
  check_reply(reply, None)

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

