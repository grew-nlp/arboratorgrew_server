#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
print ('========== [ping]')
ping ()

project_id = "__gst__rewrite"
sample_id = "gsd_ud_dev_10"
sent_id = "fr-ud-dev_00004"
user_id = "ud"

expected = [
    {'name': 'gsd_ud_test_10', 'number_sentences': 6, 'number_tokens': 152, 'number_trees': 6, 'tree_by_user': {'ud': 6}, 'tags': {}}, 
    {'name': 'gsd_ud_dev_10', 'number_sentences': 10, 'number_tokens': 219, 'number_trees': 10, 'tree_by_user': {'ud': 10}, 'tags': {}}
]

print ('========== [getSamples] ')
print ('       ... project_id -> ' + project_id)
reply = send_request (
    'getSamples',
    data = {'project_id': project_id},
    files={},
)
check_reply(reply, expected)

