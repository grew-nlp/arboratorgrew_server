#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
print('===== 01 ===== [ping]')
ping()

project_id = "__gst__multi_user"

print('===== 02 ===== [getSamples]')
print('       ... project_id -> %s' % project_id)
reply = send_request(
    'getSamples',
    data={'project_id': project_id }
)

print (json.dumps (reply["data"]))

#check_value(reply["data"], [{'name': 'sample', 'number_sentences': 1, 'number_tokens': 12, 'number_trees': 3, 'users': ['alice', 'bob', 'charlie'], 'tree_by_user': {'charlie': 1, 'bob': 1, 'alice': 1}}])
