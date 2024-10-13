#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
print ('========== [ping]')
ping ()

project_id = "__gst__searchRequestInGraphs"
sample_ids = '["sample_1"]'
sample_id = "sample_1"

print ('========== [newProject]')
print ('       ... project_id -> ' + project_id)
reply = send_request ('newProject', data={'project_id': project_id})
check_reply (reply, None)

print ('========== [newProject]')
print ('       ... project_id -> ' + project_id)
reply = send_request ('newProject', data={'project_id': project_id})
check_error (reply)

print ('========== [newSamples]')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_ids -> ' + sample_ids)
reply = send_request ('newSamples', data={'project_id': project_id, 'sample_ids': sample_ids })
check_reply (reply, None)

print ('========== [newSamples]')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_ids -> ' + sample_ids)
reply = send_request ('newSamples', data={'project_id': project_id, 'sample_ids': sample_ids })
check_error (reply)

conll_file = "data/file1.conllu"

print ('========== [saveConll]')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
print ('       ... conll_file -> ' + conll_file)
with open(conll_file, 'rb') as f:
    reply = send_request (
        'saveConll',
        data = {'project_id': project_id, 'sample_id': sample_id },
        files={'conll_file': f},
    )
check_reply (reply, None)

conll_file = "data/file2.conllu"

print ('========== [saveConll]')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
print ('       ... conll_file -> ' + conll_file)
with open(conll_file, 'rb') as f:
    reply = send_request (
        'saveConll',
        data = {'project_id': project_id, 'sample_id': sample_id },
        files={'conll_file': f},
    )
check_reply (reply, None)

user_id = "alice"

conll_graph = """# text = Les spéculations autour du match sont à leur paroxysme.
# sent_id = fr-ud-test_00006
1	Les	le	DET	_	Definite=Def|Gender=Fem|Number=Plur|PronType=Art	2	det	_	wordform=les
2	spéculations	spéculation	NOUN	_	Gender=Fem|Number=Plur	7	subj	_	_
3	autour	autour	ADV	_	_	2	mod	_	_
4-5	du	_	_	_	_	_	_	_	_
4	de	de	ADP	_	_	3	comp:obl	_	_
5	le	le	DET	_	Definite=Def|Gender=Masc|Number=Sing|PronType=Art	6	det	_	_
6	match	match	AUX	_	Gender=Masc|Number=Sing	4	comp:obj	_	_
7	sont	être	AUX	_	Mood=Ind|Number=Plur|Person=3|Tense=Pres|VerbForm=Fin	0	root	_	_
8	à	à	ADP	_	_	7	comp:pred	_	_
9	leur	son	DET	_	Gender=Masc|Number=Sing|Poss=Yes|PronType=Prs	10	det	_	_
10	paroxysme	paroxysme	NOUN	_	Gender=Masc|Number=Sing	8	comp:obj	_	SpaceAfter=No
11	.	.	PUNCT	_	_	7	punct	_	_
"""

print ('========== [saveGraph] ')
print ('       ... project_id -> ' + project_id)
print ('       ... sample_id -> ' + sample_id)
print ('       ... conll_graph -> …')
reply = send_request ('saveGraph', data={'project_id': project_id, 'sample_id': sample_id, 'user_id': user_id, 'conll_graph': conll_graph})
check_reply (reply, None)

print ('========== [getProjects]')
reply = send_request ('getProjects', data={})
short_list = [x for x in parse_reply(reply) if x["name"] == project_id]
check_value (
    short_list,
    [{'name': project_id, 'number_samples': 1, 'number_sentences': 1, 'number_tokens': 12, 'number_trees': 3, 'users': ['alice', 'bob', 'toto']}]
)

print('========== [searchRequestInGraphs]')
request = 'pattern { N[ lemma="match"] }'
user_ids = '"all"'
print('       ... project_id -> %s' % project_id)
print('       ... user_ids -> %s' % user_ids)
print('       ... request -> %s' % request)
reply = send_request(
    'searchRequestInGraphs',
    data={'project_id': project_id, 'user_ids': user_ids, 'request': request}
)
check_reply_list(reply,3)

print('========== [searchRequestInGraphs]')
clusters = 'N.upos'
print('       ... project_id -> %s' % project_id)
print('       ... user_ids -> %s' % user_ids)
print('       ... request -> %s' % request)
print('       ... clusters -> %s' % clusters)
reply = send_request(
    'searchRequestInGraphs',
    data={'project_id': project_id, 'user_ids': user_ids, 'request': request, 'clusters': clusters}
)
data = parse_reply (reply)

if len(data['VERB']) == 1 and len(data['AUX']) == 1 and len(data['NOUN']) == 1:
    print_ok ("VERB:1, AUX:1; NOUN:1")
else:
    print_ko ("VERB:1, AUX:1; NOUN:1")

time.sleep (5)

print_ok ('Go on')