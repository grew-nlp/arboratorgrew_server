#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
ping()

project_id = "__gst__rewrite"
sample_ids = '["gsd_ud_dev_10"]'
user_ids = '{ "one": ["ud"] }'

rule1 = "rule r1 { pattern { e:X -[amod]-> Y } commands { del_edge e;  } } "
rule2 = "rule r2 { pattern { e:X -[advmod]-> Y } commands { del_edge e; } }"

package = "\n".join ([rule1, rule2])

print('========== [tryPackage]')
print('       ... project_id -> %s' % project_id)
print('       ... sample_ids -> %s' % sample_ids)
print('       ... user_ids -> %s' % user_ids)
print('       ... package -> %s' % package)
reply = send_request(
    'tryPackage',
    data = {
       'project_id': project_id,
       'sample_ids': sample_ids,
       'user_ids': user_ids,
       'package': package, 
    }
)

check_value(str(reply["data"]).count("mod"), 35)
