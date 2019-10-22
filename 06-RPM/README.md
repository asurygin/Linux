

# Управление пакетами. Дистрибьюция софта.

#### 1. Создать свой RPM пакет
Т.к будем собирать пакет nginx c модулем openssl создадим иерархию катологов для сборки и скачаем исходные коды nginx
````
$ rpmdev-setuptree
$ tree

-- rpmbuild
    |-- BUILD
    |-- RPMS
    |-- SOURCES
    |-- SPECS
    -- SRPMS
    ```
`$ wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm`

Разорхивируем пакет
```
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm```

### 2. Установка зависимостей
Для установки всех зависимостей nginx выполним
```
yum-builddep /root/rpmbuild/SPECS/nginx.spec -y
```
Для использования Openssl скачаем его и пропишим в spec фаил для сборки с этим модулем
```
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz --directory /usr/lib
sed -i 's|--with-debug|--with-openssl=/usr/lib/openssl-1.1.1a|' /root/rpmbuild/SPECS/nginx.spec

```
###3. Сборка пакета
```rpmbuild --bb /root/rpmbuild/SPECS/nginx.spec```
команда
