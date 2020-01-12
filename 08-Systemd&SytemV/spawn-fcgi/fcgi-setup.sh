#!/bin/bash
 yum install epel-release -y
 yum install spawn-fcgi php php-cli mod_fcgid httpd -y
 cp /srv/spawn-fcgi/spawn-fcgi.service /etc/systemd/system/spawn-fcgi.service
 cp -u  /srv/spawn-fcgi/spawn-fcgi /etc/sysconfig/spawn-fcgi

 systemctl start spawn-fcgi.service
 systemctl enable spawn-fcgi.service
 
