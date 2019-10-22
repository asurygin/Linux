

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
<pre>

# Скачаем и распакуем наши исходники nginx

```
$ wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
$ rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
```

