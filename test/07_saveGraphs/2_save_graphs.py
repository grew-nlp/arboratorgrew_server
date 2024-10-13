#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
project_id = "__gst__saveGraphs"
sample_id = "dev"
conll_graphs = ["""
# sent_id = fr-ud-dev_00001
# text = Aviator, un film sur la vie de Hughes.
# user_id = github
1	Aviator	Aviator	PROPN	_	_	0	root	_	SpaceAfter=No
2	,	,	PUNCT	_	_	4	punct	_	_
3	un	un	XXX	_	Definite=Ind|Gender=Masc|Number=Sing|PronType=Art	4	det	_	_
4	film	film	NOUN	_	Gender=Masc|Number=Sing	1	conj:appos	_	_
5	sur	sur	ADP	_	_	4	udep	_	_
6	la	le	XXX	_	Definite=Def|Gender=Fem|Number=Sing|PronType=Art	7	det	_	_
7	vie	vie	NOUN	_	Gender=Fem|Number=Sing	5	comp:obj	_	_
8	de	de	ADP	_	_	7	udep	_	_
9	Hughes	Hughes	PROPN	_	_	8	comp:obj	_	SpaceAfter=No
10	.	.	PUNCT	_	_	1	punct	_	_

""","""
# sent_id = fr-ud-dev_00002
# text = Les études durent six ans mais leur contenu diffère donc selon les Facultés.
# user_id = github
1	Les	le	XXX	_	Definite=Def|Number=Plur|PronType=Art	2	det	_	wordform=les
2	études	étude	NOUN	_	Gender=Fem|Number=Plur|Shared=No	3	subj	_	_
3	durent	durer	VERB	_	Mood=Ind|Number=Plur|Person=3|Tense=Pres|VerbForm=Fin	0	root	_	_
4	six	six	NUM	_	Number=Plur	5	det	_	_
5	ans	an	NOUN	_	Gender=Masc|Number=Plur	3	comp:obj	_	_
6	mais	mais	CCONJ	_	_	9	cc	_	_
7	leur	son	XXX	_	Number=Sing|Number[psor]=Plur|Person[psor]=3|Poss=Yes|PronType=Prs	8	det	_	_
8	contenu	contenu	NOUN	_	Gender=Masc|Number=Sing	9	subj	_	_
9	diffère	différer	VERB	_	Mood=Ind|Number=Sing|Person=3|Tense=Pres|VerbForm=Fin	3	conj:coord	_	_
10	donc	donc	ADV	_	Shared=No	9	mod	_	_
11	selon	selon	ADP	_	Shared=No	9	mod	_	_
12	les	le	XXX	_	Definite=Def|Number=Plur|PronType=Art	13	det	_	_
13	Facultés	faculté	NOUN	_	Gender=Fem|Number=Plur	11	comp:obj	_	SpaceAfter=No|wordform=facultés
14	.	.	PUNCT	_	_	3	punct	_	_

""","""
# sent_id = fr-ud-dev_00003
# text = Mais comment faire dans un contexte structurellement raciste ?
# user_id = github
1	Mais	mais	CCONJ	_	_	3	cc	_	wordform=mais
2	comment	comment	ADV	_	PronType=Int	3	mod	_	_
3	faire	faire	VERB	_	VerbForm=Inf	0	root	_	Subject=Generic
4	dans	dans	ADP	_	_	3	mod	_	_
5	un	un	XXX	_	Definite=Ind|Gender=Masc|Number=Sing|PronType=Art	6	det	_	_
6	contexte	contexte	NOUN	_	Gender=Masc|Number=Sing	4	comp:obj	_	_
7	structurellement	structurellement	ADV	_	_	8	mod	_	_
8	raciste	raciste	ADJ	_	Gender=Masc|Number=Sing	6	mod	_	_
9	?	?	PUNCT	_	_	3	punct	_	_

""","""
# sent_id = fr-ud-dev_00834
# text = Son premier titulaire fut Henri Groulx.
# user_id = github
1	Son	son	XXX	_	Number=Sing|Number[psor]=Sing|Person[psor]=3|Poss=Yes|PronType=Prs	3	det	_	wordform=son
2	premier	premier	ADJ	_	Gender=Masc|Number=Sing	3	mod	_	_
3	titulaire	titulaire	NOUN	_	Gender=Masc|Number=Sing	4	subj	_	_
4	fut	être	AUX	_	Mood=Ind|Number=Sing|Person=3|Tense=Past|VerbForm=Fin	0	root	_	_
5	Henri	Henri	PROPN	_	_	4	comp:pred	_	_
6	Groulx	Groulx	PROPN	_	_	5	flat@name	_	SpaceAfter=No
7	.	.	PUNCT	_	_	4	punct	_	_

"""]
user_id = "github"

for conll_graph in conll_graphs:
    print ('===== 04 ===== [saveGraph] ')
    print ('       ... project_id -> ' + project_id)
    print ('       ... sample_id -> ' + sample_id)
    print ('       ... user_id -> ' + user_id)
    print ('       ... conll_graph -> …')
    reply = send_request ('saveGraph', data={'project_id': project_id, 'sample_id': sample_id, 'user_id': user_id, 'conll_graph': conll_graph})
    check_reply (reply, None)
    print(reply)
