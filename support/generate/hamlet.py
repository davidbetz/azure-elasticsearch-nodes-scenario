# MIT License

# Copyright(c) 2015-2016 David Betz

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import datetime
import sys, os
from random import randint
from time import time
import requests
import json
import socket
import fcntl
import struct

from random import randrange, randint

with open(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'hamlet_vocabulary.txt'), 'r') as f:
    hamlet_all = f.read()

genData = hamlet_all.split(' ')

def hamlet(count):
    return genData[randint(1, len(genData) - 1)] + ('' if count == 1 else ' ' + hamlet(count - 1))

interface = b'eth0'
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
address = socket.inet_ntoa(fcntl.ioctl(s.fileno(), 0x8915, struct.pack('256s', interface[:15]))[20:24])

endpoint = 'http://{}:9200/librarygen'.format(address)

print(endpoint)

def call(verb, endpoint, obj = None):
    headers = {
        "Accept": "application/json",
    }
    endpoint = endpoint.lower()

    verb = verb.lower()

    jsonData = json.dumps(obj)

    if verb == 'get':
        response = requests.get(endpoint, headers=headers)
    elif verb == 'post':
        response = requests.post(endpoint, headers=headers, data=jsonData)
    elif verb == 'put':
        response = requests.put(endpoint, headers=headers, data=jsonData)
    elif verb == 'delete':
        response = requests.delete(endpoint, headers=headers)

    return response

def create_date():
    return '{}-{:02}-{:02}T{:02}:{:02}:{:02}Z'.format(randint(2006, 2016), randint(1, 12), randint(1, 28), randint(0, 23), randint(0, 59), randint(0, 59))

call('POST', endpoint, {
    "settings": {
        "index": {
            "number_of_shards": 6
        }
    }
})

def run():
    then = time()
    count = 0
    while True:
        try:
            item = {
                "title": hamlet(4),
                "authors": [hamlet(_) for _ in range(1, randrange(2,4))],
                "editor": hamlet(1) if randrange(4) == 0 else None,
                "abstract": hamlet(randrange(100, 400)),
                "metadata": {
                    "pages": randrange(1,400),
                    "isbn": '9780' + str(randrange(100000000, 999999999)),
                    "genre": hamlet(1),
                },
                "created": create_date(),
                "modified": create_date(),
            }
            call('POST', '{}/book'.format(endpoint), item)
            count = count + 1
        except KeyboardInterrupt:
            now = time()
            print('Stopped ({})'.format(count / (now - then)))
            sys.exit(0)


if __name__ == '__main__':
    run()