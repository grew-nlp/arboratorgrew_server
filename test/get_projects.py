#!/usr/bin/env python3

import json

from gs_utils import *
print ('========== [getProjects]')
reply = send_request ('getProjects')
print (json.dumps(reply, indent=2))
