#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
project_id = "__gst__saveGraphs"

print('===== 01 ===== [newProject]')
print('       ... project_id -> ' + project_id)
reply = send_request('newProject', data={'project_id': project_id})
check_reply(reply, None)


sample_ids = '["dev"]'

print('===== 02 ===== [newSamples]')
print('       ... project_id -> ' + project_id)
print('       ... sample_ids -> ' + sample_ids)
reply = send_request(
    'newSamples', data={'project_id': project_id, 'sample_ids': sample_ids})
check_reply(reply, None)

for sample_id in ["dev"]:

    conll_file = "../GSD_with_user_id/fr_gsd-sud-%s.conllu" % sample_id

    print('===== 03 ===== [saveConll]')
    print('       ... project_id -> ' + project_id)
    print('       ... sample_id -> ' + sample_id)
    print('       ... conll_file -> ' + conll_file)
    with open(conll_file, 'rb') as f:
        reply = send_request(
            'saveConll',
            data={'project_id': project_id,
                  'sample_id': sample_id },
            files={'conll_file': f},
        )
    check_reply(reply, None)

