
# Управление пакетами. Дистрибьюция софта.

#### 1. Создать свой RPM пакет
Т.к будем собирать пакет nginx c модулем openssl создадим иерархию катологов для сборки и скачаем исходные коды nginx
```
$ rpmdev-setuptree
$ tree

```
<pre>
  -- rpmbuild
    |-- BUILD
    |-- RPMS
    |-- SOURCES
    |-- SPECS
    |-- SRPMS
</pre>
#### Скачаем и распакуем наши исходники nginx
```
$ wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
$ rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
```
Данная команда сразу добавит путь расположения до openssl в spec фаил

```
$ sed -i 's|--with-debug|--with-openssl=/usr/lib/openssl-1.1.1a|' /root/rpmbuild/SPECS/nginx.spec
```
Собираем пакет. Параметры команды rpmbuild -bb собирает только RPM -bs собирает SRPM(исходные коды в .rpm и RPM)
```
rpmbuild --bb /root/rpmbuild/SPECS/nginx.spec
```

Данная процедура займет примерно 10-15 в зависимости от конфигурации машины

Установим нам пакет проверим что он работает
```
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
sed -i '/index  index.html index.htm;/a autoindex on;' /etc/nginx/conf.d/default.conf
systemctl enable --now nginx
```
### Создание своего репозитория
Для начала создадим папку в которую мы положим наш пакет
```
mkdir /usr/share/nginx/html/repo
```
Скопируем в нее наш пакет
```
cp /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
```
И создадим репозиторий
```
createrepo /usr/share/nginx/html/repo/
```
```
cat >> /etc/yum.repos.d/custom.repo << EOF
[custom]
name=custom-repo
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
```
Готово. Можно открывать репозиторий в браузере с проверять
