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
nodea=''
nodeb=''
nodec=''
noded=''
abcd=['a','b','c','d']
with open(sys.argv[2], 'r') as domainfile:
    i=0
    for line in domainfile:
        exec('%s=%s'%('node'+abcd[i],"'"+str(line[:-1])+"'"))
        i+=1

k = paramiko.RSAKey.from_private_key_file(sys.argv[3])
hosts=[nodea,nodeb,nodec,noded]
solr_node_list=[]
tnode=''
return_dict={}

open('hostsIps','w').close()

for host in hosts:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host,username=user,pkey=k)
    print ("Connected to %s" % host)
    # get global IP
    stdin, stdout, stderr = ssh.exec_command("ifconfig | awk '/inet/ {print $2}' | head -n 1")
    stdin2, stdout2, stderr2 = ssh.exec_command("ifconfig | awk '/inet 10.10/ {print $2}'")
    subnet = str(stdout2.readlines().pop())
    [print(line) for line in stderr and stderr2]
    print(subnet)
    # if subnet == "10.10.1.4\n":
    #     ip = stdout.readlines().pop()[:-1]
    #     tnode=ip+' globalIP='+ip+' ansible_subnet='+subnet
    #     ssh.close()
    #     continue
    globalIP = stdout.readlines().pop()
    ansible_line = globalIP[:-1]+' globalIP='+globalIP[:-1]+' ansible_subnet='+subnet
    zoo_id = subnet.split('.').pop()
    if zoo_id == '1\n':
        return_dict['node0'] = ansible_line[:-1]+' zoo_id='+zoo_id
        solr_node_list.append(return_dict['node0'])
    elif zoo_id == '2\n':
        return_dict['node1'] = ansible_line[:-1]+' zoo_id='+zoo_id
        solr_node_list.append(return_dict['node1'])
    elif zoo_id == '3\n':
        return_dict['node2'] = ansible_line[:-1]+' zoo_id='+zoo_id
        solr_node_list.append(return_dict['node2'])
    else:
        tnode=ansible_line[:-1]
    # get subnet


    ssh.close()



print("...generating inventory file with Ips -> ./inventory_gen.txt\n *** please merge ./inventory file with this output *** ")
with open('hostfile.j2') as file_:
    template = Template(file_.read())
template = template.render(host_file=solr_node_list,return_dict=return_dict,traffic_node=tnode,host_user=user,node='node')

with open("inventory_gen.txt", "w") as inv:
    inv.write(template)

exit()
