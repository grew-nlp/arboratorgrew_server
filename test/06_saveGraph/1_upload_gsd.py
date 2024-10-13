#!/usr/bin/env python3
import sys
import json

sys.path.append('..')
from gs_utils import *
project_id = "__gst__saveGraph"

print('===== 01 ===== [newProject]')
print('       ... project_id -> ' + project_id)
reply = send_request('newProject', data={'project_id': project_id})
check_reply(reply, None)

sample_ids = '["dev", "test", "train_A", "train_B", "train_C", "train_D", "train_E"]'

print('===== 02 ===== [newSamples]')
print('       ... project_id -> ' + project_id)
print('       ... sample_ids -> ' + sample_ids)
reply = send_request(
    'newSamples', data={'project_id': project_id, 'sample_ids': sample_ids})
check_reply(reply, None)


for sample_id in json.loads(sample_ids):

    conll_file = "../GSD/fr_gsd-sud-%s.conllu" % sample_id

    print('===== 03 ===== [saveConll]')
    print('       ... project_id -> ' + project_id)
    print('       ... sample_id -> ' + sample_id)
    print('       ... conll_file -> ' + conll_file)
    with open(conll_file, 'rb') as f:
        reply = send_request(
            'saveConll',
            data={'project_id': project_id,
                  'sample_id': sample_id},
            files={'conll_file': f},
        )
    check_reply(reply, None)

