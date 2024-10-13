#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
print ('========== [ping]')
ping ()

project_id = "__gst__split_sentence"
sample_id = "gsd_ud_dev_10"
conll_file = "00002_split.conllu"
pivot_sent_id = 'fr-ud-dev_00002'

print ('========== [insertConll] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
print ('       ... conll_file -> ' + conll_file)
print ('       ... pivot_sent_id -> ' + pivot_sent_id)
with open(conll_file, 'rb') as f:
    reply = send_request (
        'insertConll',
        data = {'project_id': project_id, 'sample_id': sample_id, 'pivot_sent_id': pivot_sent_id },
        files={'conll_file': f},
    )
check_reply (reply, None)


print ('========== [getSentIds] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
reply = send_request (
    'getSentIds',
    data = {'project_id': project_id, 'sample_id': sample_id },
)
check_reply (reply, ['fr-ud-dev_00001', 'fr-ud-dev_00002', 'fr-ud-dev_00002a', 'fr-ud-dev_00002b', 'fr-ud-dev_00003', 'fr-ud-dev_00004', 'fr-ud-dev_00005', 'fr-ud-dev_00006', 'fr-ud-dev_00007', 'fr-ud-dev_00008', 'fr-ud-dev_00009', 'fr-ud-dev_00010']) 


sent_id = 'fr-ud-dev_00002'
print ('========== [eraseSentence] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
print ('       ... sent_id -> ' + sent_id)

reply = send_request (
    'eraseSentence',
    data = {'project_id': project_id, 'sample_id': sample_id , 'sent_id': sent_id },
)
check_reply (reply, None)

print ('========== [getSentIds] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
reply = send_request (
    'getSentIds',
    data = {'project_id': project_id, 'sample_id': sample_id },
)
check_reply (reply, ['fr-ud-dev_00001', 'fr-ud-dev_00002a', 'fr-ud-dev_00002b', 'fr-ud-dev_00003', 'fr-ud-dev_00004', 'fr-ud-dev_00005', 'fr-ud-dev_00006', 'fr-ud-dev_00007', 'fr-ud-dev_00008', 'fr-ud-dev_00009', 'fr-ud-dev_00010']) 

