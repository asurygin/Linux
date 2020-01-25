### This Otus linux system admistrate homework lesson Ansible


#### How-to:
```
vagrant up
ansible-playbook playbooks/nginx.yml
```
Полностью автоматический provision сделать не  получилось.
Вывод Ansible:
```
PLAYBOOK: nginx.yml ************************************************************
1 plays in playbooks/nginx.yml
[WARNING]: Could not match supplied host pattern, ignoring: nginx


PLAY [Install and configure NGINX] *********************************************
skipping: no hosts matched
```
Если кто подкажет в чем может быть проблема буду благодарен.
