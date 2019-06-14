import os
import sys
import paramiko
import base64

from jinja2 import Template



if len(sys.argv) != 4:
    print("\nusage: getips.py <username> <clouddnsfile> <path_to_private_rsa_key>\n")
    exit()

user = sys.argv[1]
dn={}
node0=''
node1=''
node2=''
node3=''

with open(sys.argv[2], 'r') as domainfile:
    num=0
    for line in domainfile:
        exec('%s=%s'%('node'+str(num),"'"+str(line[:-1])+"'"))
        num+=1

k = paramiko.RSAKey.from_private_key_file(sys.argv[3])
hosts=[node0,node1,node2,node3]
host_file=[]
tnode=''

open('hostsIps','w').close()

for host in hosts:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host,username=user,pkey=k)
    print ("Connected to %s" % host)
    stdin, stdout, stderr = ssh.exec_command("ifconfig | awk '/inet/ {print $2}' | head -n 1")
    [print(line) for line in stderr]
    if host == node3:
        tnode=stdout.readlines().pop()
        ssh.close()
        break
    host_file.append(stdout.readlines().pop())
    ssh.close()

print("...generating inventory file with Ips -> ./inventory_gen.txt")
with open('hostfile.j2') as file_:
    template = Template(file_.read())
template = template.render(hostsfile=host_file,traffic_node=tnode,host_user=user)

with open("inventory_gen.txt", "w") as inv:
    inv.write(template)

exit()
