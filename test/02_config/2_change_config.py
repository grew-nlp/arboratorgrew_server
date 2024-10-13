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


# update config
config_file = 'config2.json'
print('========== [updateProjectConfig]')
print('       ... project_id -> ' + project_id)
print('       ... config_file -> ' + config_file)
with open(config_file) as f:
  config = f.read()
  reply = send_request('updateProjectConfig', data={ 'project_id': project_id, 'config': config})
  check_reply(reply, None)

sent_id = "SAY_BC_CONV_01_001-001"
user_id = "bob"
print ('========== [getConll]')
print ('       ... project_id -> %s' % project_id)
print ('       ... sample_id -> %s' % sample_id)
print ('       ... sent_id -> %s' % sent_id)
print ('       ... user_id -> %s' % user_id)
reply = send_request ('getConll', data={'project_id': project_id, 'sample_id': sample_id, 'sent_id': sent_id, 'user_id': user_id})
conll = reply['data']
line5 = conll.split("\n")[3]
# Check that "Gloss" is now in the FEATS column
check_value(line5, "1	tòː	tòː	PART	_	Gloss=well	0	root	_	AlignBegin=902|AlignEnd=1054")

