#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
project_id = "__gst__saveGraph"

print('========== [eraseProject]')
print('       ... project_id -> ' + project_id)
reply = send_request('eraseProject', data={'project_id': project_id})
check_reply(reply, None)

