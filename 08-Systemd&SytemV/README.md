# Домашние задание Systemd

#### Все сервисы деплоються через Git. Файлы для деплоя находятся
[Solution](https://github.com/asurygin/systemd)

#### 1. Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig

##### Скрипт парсинга

    #!/bin/bash

    WORD=$1
    LOG=$2
    DATE=`date`
    if grep $WORD $LOG &> /dev/null
    then
    logger "$DATE: I found word, Master!"
    else
    exit 0
    fi

##### Environmentfile для скрипта /etc/sysconfig/watchlog

    WORD="ALERT"
    LOG=/var/log/watchlog.log

##### Unit-файл для сервиса

    [Unit]
    Description=My watchlog service

    [Service]

    Type=oneshot
    EnvironmentFile=/etc/sysconfig/watchlog
    ExecStart=/usr/bin/watchlog.sh $WORD $LOG


##### Unit-файл для таймера

    [Unit]
    Description=Run watchlog script every 30 second

    [Timer]
    # Run every 30 second
    OnBootSec=40s
    OnUnitActiveSec=30s
    Unit=watchlog.service

    [Install]
    WantedBy=multi-user.target

Cкрипт [monitor-setup.sh](https://github.com/asurygin/Linux/blob/Homework/08-Systemd%26SytemV/monitor/monitor-setup.sh) установит конфиги куда нужно, создаст тестовый лог-фаил и запустит сервис

#### 2. Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно так же называться.

    [Unit]
    Description=Spawn used by web servers
    After=network.target

    [Service]
    Type=simple
    EnvironmentFile=/etc/sysconfig/spawn-fcgi
    ExecStart=/usr/bin/spawn-fcgi $OPTIONS
    KillMode=process

    [Install]
    WantedBy=multi-user.target

#### 3. Дополнить юнит-файл apache httpd возможностьб запустить несколько инстансов сервера с разными конфигами

Дополняем Unit-файил httpd

    EnvironmentFile=/etc/sysconfig/httpd-%I

Создаем конфиги в котором изменен
>PidFile и Listen порт.

    /etc/httpd/conf/first.conf
    /etc/httpd/conf/second.conf

#### Получаем статус:

    systemctl status httpd@first
    ● httpd@first.service - The Apache HTTP Server
       Loaded: loaded (/etc/systemd/system/httpd@.service; enabled; vendor preset: disabled)
       Active: active (running) since Sun 2020-01-12 23:48:33 MSK; 33s ago
         Docs: man:httpd(8)
               man:apachectl(8)
     Main PID: 6438 (httpd)
       Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
       CGroup: /system.slice/system-httpd.slice/httpd@first.service
               ├─6438 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
               ├─6439 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
               ├─6440 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
               ├─6441 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
               ├─6442 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
               ├─6443 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
               └─6444 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

***

    systemctl status httpd@second
    httpd@second.service - The Apache HTTP Server
       Loaded: loaded (/etc/systemd/system/httpd@.service; enabled; vendor preset: disabled)
       Active: active (running) since Sun 2020-01-12 23:48:33 MSK; 40s ago
         Docs: man:httpd(8)
               man:apachectl(8)
     Main PID: 6446 (httpd)
       Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
       CGroup: /system.slice/system-httpd.slice/httpd@second.service
               ├─6446 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
               ├─6447 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
               ├─6448 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
               ├─6449 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
               ├─6450 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
               ├─6451 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
               └─6452 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
