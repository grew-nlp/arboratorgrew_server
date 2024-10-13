#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
print('===== 01 ===== [ping]')
ping()

project_id = "__gst__multi_user"
sample_id = "sample"

print('===== 02 ===== [searchRequestInGraphs]')
request = 'pattern { N[ lemma="match"] }'
print('       ... project_id -> %s' % project_id)
print('       ... request -> %s' % request)
reply = send_request(
    'searchRequestInGraphs',
    data={'project_id': project_id, 'request': request, 'user_ids': '"all"'}
)
check_reply_list(reply,3)

print('===== 03 ===== [searchRequestInGraphs]')
request = 'pattern { N[ lemma="match", upos="NOUN" ] }'
print('       ... project_id -> %s' % project_id)
print('       ... request -> %s' % request)
reply = send_request(
    'searchRequestInGraphs',
    data={'project_id': project_id, 'request': request, 'user_ids': '"all"'}
)
check_reply_list(reply,1)

print('===== 04 ===== [searchRequestInGraphs]')
request = 'global { sent_id = "fr-ud-test_00006" }'
print('       ... project_id -> %s' % project_id)
print('       ... request -> %s' % request)
reply = send_request(
    'searchRequestInGraphs',
    data={'project_id': project_id, 'request': request, 'user_ids': '"all"'}
)
check_reply_list(reply,3)

print('===== 05 ===== [searchRequestInGraphs]')
request = ''
print('       ... project_id -> %s' % project_id)
print('       ... request -> %s' % request)
reply = send_request(
    'searchRequestInGraphs',
    data={'project_id': project_id, 'request': request, 'user_ids': '{ "one": ["__last__"] }'}
)
check_reply_list(reply,1)
data = parse_reply(reply)[0]
check_value (data["user_id"], "charlie")
