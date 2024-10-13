#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
project_id = "__gst__eraseGraphs"
sample_id = "dev"

print ('========== [getSamples] ')
print ('       ... project_id -> ' + project_id)
reply = send_request (
    'getSamples',
    data = {'project_id': project_id},
    files={},
)
data = parse_reply(reply)[0]['tree_by_user']
check_value (len(data), 3)

print ('========== [eraseGraphs] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
reply = send_request (
    'eraseGraphs',
    data = {'project_id': project_id, 'sample_id': sample_id, 'sent_ids': '[]', 'user_id': 'charlie'},
    files={},
)

print ('========== [getSamples] ')
print ('       ... project_id -> ' + project_id)
reply = send_request (
    'getSamples',
    data = {'project_id': project_id},
    files={},
)

data = parse_reply(reply)[0]['tree_by_user']
check_value (len(data), 2)

print ('========== [eraseGraphs] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
reply = send_request (
    'eraseGraphs',
    data = {'project_id': project_id, 'sample_id': sample_id, 'sent_ids': '["S2"]', 'user_id': 'alice'},
    files={},
)

print ('========== [eraseGraphs] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
reply = send_request (
    'eraseGraphs',
    data = {'project_id': project_id, 'sample_id': sample_id, 'sent_ids': '["S1"]', 'user_id': 'alice'},
    files={},
)

print ('========== [getSamples] ')
print ('       ... project_id -> ' + project_id)
reply = send_request (
    'getSamples',
    data = {'project_id': project_id},
    files={},
)
data = parse_reply(reply)[0]['tree_by_user']
check_value (len(data), 1)
