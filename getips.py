import os
import sys
import paramiko
import base64
import time

from jinja2 import Template



if len(sys.argv) != 4:
    print("\nusage: getips.py <username> <clouddnsfile> <path_to_private_rsa_key>\n")
    exit()

user = sys.argv[1]
node_dict={}

with open(sys.argv[2], 'r') as domainfile:
    i=0
    for line in domainfile:
        node_dict[str(i)] = line[:-1]
        i+=1

k = paramiko.RSAKey.from_private_key_file(sys.argv[3])
zoo_dict={}
nodes_dict={}
load_dict={}

open('hostsIps','w').close()

for hostname in node_dict.values():
    time.sleep(2)
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    print("attempting to connect to %s" % hostname)
    ssh.connect(hostname,username=user,pkey=k)
    print("Connected to %s" % hostname)
    # get global IP
    stdin, stdout, stderr = ssh.exec_command("ifconfig | awk '/inet/ {print $2}' | head -n 1")
    stdin2, stdout2, stderr2 = ssh.exec_command("ifconfig | awk '/inet 10.10/ {print $2}'")
    subnet = str(stdout2.readlines().pop())
    [print(line) for line in stderr and stderr2]
    globalIP = stdout.readlines().pop()
    ansible_line = globalIP[:-1]+'   globalIP='+globalIP[:-1]+'   ansible_subnet='+subnet
    zoo_id = subnet.split('.')
    zoo_id = zoo_id.pop()
    print(zoo_id)
    # non-zookeeper nodes
    if int(zoo_id[:-1]) > 3 and int(zoo_id[:-1]) < 33:
        nodes_dict[str(int(zoo_id[:-1])-1)] = ansible_line
    # load gen nodes
    elif int(zoo_id[:-1]) > 32:
        load_dict[str(int(zoo_id[:-1])-1)] = ansible_line
    # zookeeper nodes
    else:
        zoo_dict[str(int(zoo_id[:-1])-1)] = ansible_line[:-1]+'  zoo_id='+zoo_id

    ssh.close()


print("...generating inventory file with Ips -> ./inventory_gen.txt\n *** please merge ./inventory file with this output *** ")
with open('inventory_file_template.j2') as file_:
    template = Template(file_.read())
template = template.render(nodes_dict=nodes_dict,zoo_dict=zoo_dict,load_dict=load_dict,host_user=user)

with open("inventory_gen.txt", "w") as inv:
    inv.write(template)

exit()
