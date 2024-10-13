#!/usr/bin/env python3
import sys
sys.path.append('..')
from gs_utils import *
print ('========== [ping]')
ping ()

project_id = "__gst__big_request"

print ('========== [eraseProject]')
print ('       ... project_id -> ' + project_id)
reply = send_request ('eraseProject', data={'project_id': project_id})
check_reply (reply, None)

