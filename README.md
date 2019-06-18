## This project builds and deploys a distributed SolrCloud Development Environment w/ solr source version control

To deploy:

Create a python3 virtual env:
`pyenv activate your_env`

install packages:
`pip install ansible paramiko Jinja2 numpy`


### Notes on Ansible Roles:
#### Variables
`hostvars`



`VARIABLE PRECEDENCE`
If multiple variables of the same name are defined in different places, they win in a certain order, which is:
- extra vars (-e in the command line) always win
- then comes connection variables defined in inventory (ansible_ssh_user, etc)
- then comes "most everything else" (command line switches, vars in play, included vars, role vars, etc)
- then comes the rest of the variables defined in inventory
- then comes facts discovered about a system
- then "role defaults", which are the most "defaulty" and lose in priority to everything.
