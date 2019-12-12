## This project builds and deploys a distributed SolrCloud Development Environment w/ solr source version control

To deploy you need to set up a local and remote env:

LOCAL:  
Create a python3 virtual env:  
`pyenv activate your_env`

install packages:  
`pip install ansible paramiko Jinja2 numpy`


REMOTE:  
1. to set up your remote env, put the four Cloudlab domains in a file ./cloudlabDNS e.g
```
ms1312.utah.cloudlab.us
ms1019.utah.cloudlab.us
ms1311.utah.cloudlab.us
ms1341.utah.cloudlab.us
ms0819.utah.cloudlab.us
...
```

*before running this script, make sure your id_rsa public key is on cloudlab and your id_rsa private key starts with -----BEGIN RSA PRIVATE KEY----- since this paramiko version requires this.*
**also make sure all whitespace is removed from this file otherwise paramiko may throw a curious error**
**be sure the list of dns names are in order of the cloudlab listview**

2. run $python3 getips.py <cloudlab username> <cloudlabDNS filename> <path_to_private_rsa_key>
this will generate >> `inventory_gen.txt` file. swap this file with `./inventory`

### before you run the ansible scripts:
*these steps fork the solr repo, check out a specific branch, and duplicate that branch to your own dev branch.*
- fork the lucene-solr repo https://github.com/DavidCPorter/lucene-solr.git
- add ssh keys from solr nodes to github account (temp solution so ansible can easily update repos remotely)
- locally clone repo
- checkout branch_8_0
- create new branch <name> e.g. `git checkout -b <name>`
- push <name> branch to origin
- replace `dporter` with <branch name> in roles/solr/defaults/main.yml.
- replace `dporte7` in ansible role "vars" and "defaults" files with your username in cloudlab

##### LOAD env helpers utils.sh and be sure to replace PROJ_HOME and CL_USER var with your path for this app.

#### run ansible scripts
3. to install the cloud env, run:  
`play cloud_configure.yml --tags never`
4. to install and run zookeeper, run:  
`play zoo_configure.yml`
5. to install and run solrcloud, run:  
`play solr_configure.yml`
6. to install solrj-enabled client application (cloudaware solr client). There is a tag you can use to enable remote monitoring via jmx if you would like to see that. Also requires REMOTE_JMX setting mod (see below)
`play solr_bench.yml --tags solrj`

#### set up shell envs
1. update all files in utils folder with your current cluster and user-specific info **especially the ARRAYS with the IPS**
2. then, run `ssh_files/produce_ssh_files.sh` to create files for pssh tasks dependencies in runtest.sh


#### run experiment
*before you run any experiment you want to make sure solr is not running `checksolr` and that there is no indicies on the cores `listcores`*
*make sure the utils are updated  loaded first*
*make sure to edit params file*
fulltest < list of solr clusters >
e.g. if i wanted to run scaling experiment on 2 4 8 and 16 clusters and compare the performance, I would run this:
`fulltest 2 4 8 16`

**IF YOU EVER EXIT an experiment or it fails... make sure to remember run `stopSolr <clustersize>` and `wipecores` and `killallbyname dstat` `callingnodes rm *.csv` before you continue**
*FURTHERMORE, if the exp posted_data (indexed) for the first time, you might want to consider deleting that collection via solr admin and redoing the experiemnt becuase the final step in the exp is to save to aws and that would not have happened in a failed exp... you can either run the ansible script to post to aws, or just redo it after deleting*

**It's important to remember that the disk space on the cluster is small ~10GB so any more that 4 replicas will prolly fail due to disk size failure. This is why there is the posting the index to aws (if prev nott there ) and removing it after each exp so you dont hit the limit.**


### NOTES
#### Notes on Solr Config
*This is completed automatically during the solr config step with the ansible playbooks.*

I found the easiest way to connect with the remote JMX is to modify this line in the ~/solr-8_0/solr/bin/solr executable

`REMOTE_JMX_OPTS+=("-Djava.rmi.server.hostname=$SOLR_HOST")`  
to  
`REMOTE_JMX_OPTS+=("-Djava.rmi.server.hostname=$GLOBALIP")`


#### Notes on Ansible Roles:
There are five roles in this repo `cloudenv, solr, zookeeper, upload_data, benchmark` located in the /playbooks/roles dir. You can take a look at the procedures for setting up the envs in ./roles/<role_name>/tasks/main.yml

#### Notes on Ansible Variables
when you run ansible playbooks, the process will generate sys variables, and to view these you can run `ansible -i inventory -m setup`
`hostvars`
`VARIABLE PRECEDENCE`
If multiple variables of the same name are defined in different places, they win in a certain order, which is:
- extra vars (-e in the command line) always win
- then comes connection variables defined in inventory (ansible_ssh_user, etc)
- then comes "most everything else" (command line switches, vars in play, included vars, role vars, etc)
- then comes the rest of the variables defined in inventory
- then comes facts discovered about a system
- then "role defaults", which are the most "defaulty" and lose in priority to everything.
