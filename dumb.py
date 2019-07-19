# this file is just to experiment with the non-http communication patterns of the solrj query server I ported to 9111. My original traffic_gen implementation spoke http directly with the running solr instances. Now that I am talking with the solrj instance, I need to replace the http protocol with simple byte transfer, therefore I need to add a socket object pool in place of the http one in traffic_gen.py.

import socket
import threading
import time

def query(request):

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect(("128.110.153.106", 9111))
        s.sendall(request)
        # s.send(b'')
        # time.sleep(1)
        result = s.recv(1024)
        # s.close()


    print("received", repr(result))

for i in range(10):
    request = b'some overall:5.0 some\n'
    threading.Thread(target = query, args = (request,)).start()
