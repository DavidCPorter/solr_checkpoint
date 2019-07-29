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
solr_node_list=[]
tnode=''

open('hostsIps','w').close()

for host in hosts:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host,username=user,pkey=k)
    print ("Connected to %s" % host)
    # get global IP
    stdin, stdout, stderr = ssh.exec_command("ifconfig | awk '/inet/ {print $2}' | head -n 1")
    stdin2, stdout2, stderr2 = ssh.exec_command("ifconfig | awk '/inet 10.10/ {print $2}'")

    [print(line) for line in stderr and stderr2]
    if host == node3:
        ip = stdout.readlines().pop()[:-1]
        tnode=ip+' globalIP='+ip+' ansible_subnet='+str(stdout2.readlines().pop())
        ssh.close()
        break
    globalIP = stdout.readlines().pop()
    ansible_subnet=str(stdout2.readlines().pop())
    ansible_line = globalIP[:-1]+' globalIP='+globalIP[:-1]+' ansible_subnet='+ansible_subnet
    zoo_id = ansible_subnet.split('.').pop()
    solr_node_list.append(ansible_line[:-1]+' zoo_id='+zoo_id)

    # get subnet

    ssh.close()

print("...generating inventory file with Ips -> ./inventory_gen.txt\n *** please merge ./inventory file with this output *** ")
with open('hostfile.j2') as file_:
    template = Template(file_.read())
template = template.render(hostsfile=solr_node_list,traffic_node=tnode,host_user=user,node='node')

with open("inventory_gen.txt", "w") as inv:
    inv.write(template)

exit()
