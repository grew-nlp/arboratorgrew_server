#!/usr/bin/env python3

from termcolor import colored
import json
import sys
import requests
import time

def print_ok(msg):
    print(colored(msg, 'green'))

def print_ko(msg):
    print(colored(msg, 'red'))

if (len(sys.argv) > 1 and sys.argv[1] == "prod"):
    server = 'http://arborator.grew.fr'
elif (len(sys.argv) > 1 and sys.argv[1] == "dev"):
    server = 'http://arborator-dev.grew.fr'
else:
    server = 'http://localhost:8080'

last_duration = 0

def send_request(fct_name, data={}, files={}):
    global last_duration
    init = time.time()
    try:
        r = requests.post(
            "%s/%s" % (server,fct_name),
            files = files,
            data = data
        )
        last_duration = time.time() - init
        if r.status_code == 200:
            return r.json()
        else:
            print (colored ("[utils.send_request] Error %d in request %s" % (r.status_code, fct_name), "red"))
            exit (1)
    except requests.ConnectionError:
        print (colored ("[utils.send_request] Cannot connect to: %s" % server, "red"))
        exit (1)
    except Exception as e:
        print ("[utils.py] Uncaught exception, please report %s" % e)

def check_error(reply):
    if reply['status'] == "ERROR":
        print(colored('+++++ OK +++++ (error as expected)', 'green'))
    else:
        print(colored('----- KO -----', 'yellow'))
        print ("==================== Expected ====================")
        print ("ERROR")
        print ("==================== Reply =======================")
        print(colored(json.dumps(reply['data'], indent=4, sort_keys=True),'yellow'))
        print ("==================================================")

def parse_reply(reply):
    if reply['status'] == "ERROR":
        print(colored("[utils.parse_reply] ERROR: %s" % reply['message'], 'red'))
        exit (1)
    elif reply['status'] == "OK":
        return (reply['data'])
    else:
        print(colored("Cannot parse reply:", 'red'))
        print(colored(reply, 'red'))
        exit(1)

def check_value (observed, expected):
    if observed == expected:
        print(colored('+++++ OK +++++ [%fs]' % last_duration, 'green'))
    else:
        print(colored('----- KO ----- [%fs]' % last_duration, 'yellow'))
        print ("==================== Expected ====================")
        print (expected)
        print ("==================== Observed =======================")
        print (observed)
        print ("==================================================")

def check_reply (reply, expected):
    out=parse_reply (reply)
    if out == expected:
        print(colored('+++++ OK +++++ [%fs]' % last_duration, 'green'))
    else:
        print(colored('----- KO -----[%fs]' % last_duration, 'yellow'))
        print ("==================== Expected ====================")
        print (expected)
        print ("==================== Reply =======================")
        print(colored(json.dumps(reply['data'], indent=4, sort_keys=True),'yellow'))
        print ("==================================================")

def check_reply_list (reply, expected_length):
    out=parse_reply (reply)
    if isinstance(out, list) and len(out) == expected_length:
        print(colored('+++++ OK: |reply|=%s +++++' % expected_length, 'green'))
    else:
        if isinstance(out, list):
            print(colored('----- KO ----- [%fs]' % last_duration, 'yellow'))
            print ("List length is %d instead of %d" % (len(out),expected_length))
        else:
            print(colored('----- KO ----- [%fs]' % last_duration, 'yellow'))
            print ("Expected a list but got a %s" % type(out))
def check_reply_dict (reply, expected_length):
    out=parse_reply (reply)
    if isinstance(out, dict) and len(out) == expected_length:
        print(colored('+++++ OK: |reply|=%s +++++ [%fs]' % (expected_length, last_duration), 'green'))
    else:
        print(colored('----- KO ----- [%fs]' % last_duration, 'yellow'))
        print ("==================== Reply =======================")
        print(colored(json.dumps(out, indent=4, sort_keys=True),'yellow'))
        print ("==================================================")


def ping():
    x = send_request ('ping')
    print (colored ("[utils.ping] Connection ok to: %s" % server, "green"))


