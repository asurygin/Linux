#!/bin/bash
cp /srv/httpd/httpd@.service /etc/systemd/system/httpd@.service
cp /srv/httpd/httpd-first /etc/sysconfig/httpd-first
cp /srv/httpd/httpd-second /etc/sysconfig/httpd-second
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/second.conf
sed -i '/ServerRoot "\/etc\/httpd"/a PidFile \/var\/run\/second.pid' /etc/httpd/conf/second.conf

systemctl disable httpd
systemctl daemon-reload
systemctl enable httpd@service
systemctl start httpd@first
systemctl start httpd@second
