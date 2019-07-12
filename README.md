## This project builds and deploys a distributed SolrCloud Development Environment w/ solr source version control

To deploy you need to set up a local and remote env:

LOCAL:
Create a python3 virtual env:
`pyenv activate your_env`

install packages:
`pip install ansible paramiko Jinja2 numpy`


REMOTE:
1) to set up your remote env, put the four Cloudlab domains in a file ./cloudlabDNS e.g
`domain1`
`domain2`
`domain3`
`domain4`

2) run $python3 getips.py <cloudlab username> <cloudlabDNS filename> <path_to_private_rsa_key>
this will generate >> `inventory_gen.txt` file
- rename this file to `./inventory`

### before you run the ansible scripts:
- fork the lucene-solr repo https://github.com/DavidCPorter/lucene-solr.git
- add ssh keys from solr nodes to github account (temp solution so ansible can easily update repos remotely)
- locally clone repo
- checkout branch_8_0
- create new branch <name> e.g. `git checkout -b <name>`
- push <name> branch to origin
- replace `dporter` with <name> in solr_install.yml script under field "version" in the git step.
- replace `dporte7` in ansible "vars" and "defaults" files with your username in cloudlab

3) to install the cloud env, run `ansible-playbook -i inventory cloud_configure.yml`
4) to install and run zookeeper, run `ansible-playbook -i inventory zoo_configure.yml`
5) to install and run solrcloud, run `ansible-playbook -i inventory solr_configure.yml`


### Running tests
- I found the easiest way to connect with the remote JMX is to modify this line in the ~/solr-8_0/solr/bin/solr executable

REMOTE_JMX_OPTS+=("-Djava.rmi.server.hostname=$SOLR_HOST")
to
REMOTE_JMX_OPTS+=("-Djava.rmi.server.hostname=$GLOBALIP")

ansible sets $GLOBALIP variable


### Notes on Ansible Roles:
There are three roles in this repo `cloudenv, solr, zookeeper` located in the ./roles dir. You can take a look at the procedures for setting up the envs in ./roles/<role_name>/tasks/main.yml

#### Ansible Variables
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
