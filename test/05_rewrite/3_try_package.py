#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
ping()

project_id = '__gst__rewrite'
sample_ids = '["gsd_ud_dev_10"]'
user_ids = '{ "one": ["ud"] }'

rule1 = "rule r1 { pattern { N [upos=VERB] } commands { N.upos=V } }"
rule2 = "rule r2 { pattern { e: N -[nsubj]-> M } commands { del_edge e; add_edge N -[NSUBJ]-> M } }"

package = "\n".join ([rule1, rule2])

print('========== [tryPackage]')
print('       ... project_id -> %s' % project_id)
print('       ... sample_ids -> %s' % sample_ids)
print('       ... user_ids -> %s' % user_ids)
print('       ... package -> %s' % package)
reply = send_request(
    'tryPackage',
    data={'project_id': project_id, 'package': package, 'sample_ids': sample_ids, 'user_ids': user_ids}
)

# 8 of the 10 sentences are rewritten
check_reply_list (reply, 8)

# print (json.dumps(reply, indent=4, sort_keys=True))
