#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
ping()

project_id = '__gst__lexicon'
sample_ids = '["test"]'
user_ids = '"all"'
features = '["form", "lemma", "upos", "Gender", "Number"]'

print('========== [getLexicon]')
print('       ... project_id -> %s' % project_id)
print('       ... user_ids -> %s' % user_ids)
print('       ... sample_ids -> %s' % sample_ids)
print('       ... features -> %s' % features)
reply = send_request(
    'getLexicon',
    data={'project_id': project_id, 'user_ids': user_ids, 'sample_ids': sample_ids, 'features': features}
)

print (json.dumps(reply,indent = 2))
check_reply_list (reply, 5)
prune = 3

print('========== [getLexicon]')
print('       ... project_id -> %s' % project_id)
print('       ... user_ids -> %s' % user_ids)
print('       ... sample_ids -> %s' % sample_ids)
print('       ... features -> %s' % features)
print('       ... prune -> %d' % prune)
reply = send_request(
    'getLexicon',
    data={'project_id': project_id, 'user_ids': user_ids, 'sample_ids': sample_ids, 'features': features, 'prune': prune }
)

print (json.dumps(reply,indent = 2))
check_reply_list (reply, 4)
