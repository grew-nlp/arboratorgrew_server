#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
project_id = "__gst__eraseGraphs"
sample_id = "dev"
sample_ids = "[\"dev\"]"

print('===== 01 ===== [newProject]')
print('       ... project_id -> ' + project_id)
reply = send_request('newProject', data={'project_id': project_id})
check_reply(reply, None)

print('===== 02 ===== [newSamples]')
print('       ... project_id -> ' + project_id)
print('       ... sample_ids -> ' + sample_ids)
reply = send_request(
    'newSamples', data={'project_id': project_id, 'sample_ids': sample_ids})
check_reply(reply, None)



conll_graphs = { "alice": ["""
# sent_id = S1
# text = Aviator, un film sur la vie de Hughes.
1	Aviator	Aviator	PROPN	_	_	0	root	_	SpaceAfter=No

""", """
# sent_id = S2
# text = Les études durent six ans mais leur contenu diffère donc selon les Facultés.
1	Les	le	XXX	_	Definite=Def|Number=Plur|PronType=Art	0	root	_	wordform=les

"""], 
  "bob": ["""
# sent_id = S1
# text = Aviator, un film sur la vie de Hughes.
1	Aviator	Aviator	PROPN	_	_	0	root	_	SpaceAfter=No

""", """
# sent_id = S2
# text = Les études durent six ans mais leur contenu diffère donc selon les Facultés.
1	Les	le	XXX	_	Definite=Def|Number=Plur|PronType=Art	0	root	_	wordform=les

""", """
# sent_id = S3
# text = Mais comment faire dans un contexte structurellement raciste ?
1	Mais	mais	CCONJ	_	_	0	root	_	wordform=mais

"""], 
  "charlie": ["""
# sent_id = S1
# text = Aviator, un film sur la vie de Hughes.
1	Aviator	Aviator	PROPN	_	_	0	root	_	SpaceAfter=No

""", """
# sent_id = S2
# text = Les études durent six ans mais leur contenu diffère donc selon les Facultés.
1	Les	le	XXX	_	Definite=Def|Number=Plur|PronType=Art	0	root	_	wordform=les

""", """
# sent_id = S3
# text = Mais comment faire dans un contexte structurellement raciste ?
1	Mais	mais	CCONJ	_	_	0	root	_	wordform=mais

""", """
# sent_id = S4
# text = Son premier titulaire fut Henri Groulx.
1	Son	son	XXX	_	Number=Sing|Number[psor]=Sing|Person[psor]=3|Poss=Yes|PronType=Prs	0	root	_	wordform=son

"""]}

for user_id in ['alice', 'bob', 'charlie']:
  for conll_graph in conll_graphs[user_id]:
    print ('===== 04 ===== [saveGraphs] ')
    print ('       ... project_id -> ' + project_id)
    print ('       ... sample_id -> ' + sample_id)
    print ('       ... user_id -> ' + user_id)
    print ('       ... conll_graph -> …')
    reply = send_request ('saveGraph', data={'project_id': project_id, 'sample_id': sample_id, 'user_id': user_id, 'conll_graph': conll_graph})
    check_reply (reply, None)
    print(reply)
