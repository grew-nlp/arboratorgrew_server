#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
print('===== 01 ===== [ping]')
ping()

project_id = "__gst__multi_user"
sample_id = "sample"
sent_id = "fr-ud-dev_00001"
user_id = "bob"

conll_graph = """
# sent_id = fr-ud-dev_00001
# timestamp = 123
1	Aviator	XXX	PROPN	_	_	0	root	_	SpaceAfter=No
2	,	,	PUNCT	_	_	4	punct	_	_
3	un	un	DET	_	Definite=Ind|Gender=Masc|Number=Sing|PronType=Art	4	det	_	_
4	film	film	NOUN	_	Gender=Masc|Number=Sing	1	appos	_	_
5	sur	sur	ADP	_	_	4	udep	_	_
6	la	le	DET	_	Definite=Def|Gender=Fem|Number=Sing|PronType=Art	7	det	_	_
7	vie	vie	NOUN	_	Gender=Fem|Number=Sing	5	comp:obj	_	_
8	de	de	ADP	_	_	7	udep	_	_
9	Hughes	Hughes	PROPN	_	_	8	comp:obj	_	SpaceAfter=No
10	.	.	PUNCT	_	_	1	punct	_	_

"""
print ('===== 02 ===== [saveGraph] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
print ('       ... user_id -> ' + user_id)
print ('       ... sent_id -> ' + sent_id)
print ('       ... conll_graph -> …')
reply = send_request ('saveGraph', data={'project_id': project_id, 'sample_id': sample_id, 'user_id': user_id, 'conll_graph': conll_graph})
check_reply (reply, None)

print('===== 03 ===== [searchRequestInGraphs]')
request = ''
print('       ... project_id -> %s' % project_id)
print('       ... request -> %s' % request)
reply = send_request(
    'searchRequestInGraphs',
    data={'project_id': project_id, 'request': request, 'user_ids': '{ "one": ["__last__"] }'}
)
check_reply_list(reply,2)
