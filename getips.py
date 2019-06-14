import os
import sys
import paramiko
import base64

if len(sys.argv) != 4:
    print("\nusage: getips.py <username> <clouddnsfile> <path_to_private_rsa_key>\n")
    exit()

user = sys.argv[1]
dn={}
node0=''
node1=''
node2=''
node3=''

print(sys.argv)
with open(sys.argv[2], 'r') as domainfile:
    num=0
    for line in domainfile:
        print('node'+str(num))
        exec('%s=%s'%('node'+str(num),"'"+str(line[:-1])+"'"))
        num+=1
print(node0,'shit')
k = paramiko.RSAKey.from_private_key_file(sys.argv[3])
hosts=[node0,node1,node2,node3]
open('hostsIps','w').close()

for host in hosts:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host,username=user,pkey=k)
    print ("Connected to %s" % host)
    stdin, stdout, stderr = ssh.exec_command("ifconfig | awk '/inet/ {print $2}' | head -n 1")
    [open('hostsIps','a').write(line) for line in stdout]
    [print(line) for line in stderr]
    ssh.close()
