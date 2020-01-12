#!/bin/bash
cp /srv/monitor/watchlog /etc/sysconfig/watchlog
cp /srv/monitor/watchlog.sh /usr/bin/watchlog.sh
cp /srv/monitor/watchlog.service /etc/systemd/system/watchlog.service
cp /srv/monitor/watchlog.timer /etc/systemd/system/watchlog.timer
systemctl daemon-reload

cat /var/log/yum.log > /var/log/watchlog.log
echo 'ALERT' >> /var/log/watchlog.log

systemctl start watchlog.timer
systemctl enable watchlog.timer
systemctl enable watchlog.service
