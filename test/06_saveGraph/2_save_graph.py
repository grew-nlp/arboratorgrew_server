#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
project_id = "__gst__saveGraph"
sample_id = "train_A"
user_id= "alice"
conll_graph = """
# text = je reviendrais avec plaisir !
# sent_id = fr-ud-train_00006
1	je	il	PRON	_	Number=Sing|Person=1|PronType=Prs	2	subj	_	_
2	reviendrais	revenir	VERB	_	Mood=Cnd|Number=Sing|Person=1|Tense=Pres|VerbForm=Fin	0	root	_	_
3	avec	avec	ADP	_	_	2	mod	_	_
4	plaisir	plaisir	ADV	_	Gender=Masc|Number=Sing	3	comp:obj	_	_
5	!	!	PUNCT	_	_	2	punct	_	_

"""
print ('===== 04 ===== [saveGraph] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
print ('       ... user_id -> ' + user_id)
print ('       ... conll_graph -> …')
reply = send_request ('saveGraph', data={'project_id': project_id, 'sample_id': sample_id, 'user_id': user_id, 'conll_graph': conll_graph})
check_reply (reply, None)
print(reply)
