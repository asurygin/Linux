
Стенд для домашнего занятия "Файловые системы и LVM"


Для начала необходимо определиться какие устройства мы хотим использовать в качестве Physical Volumes (далее - PV) для наших будущих Volume Groups (далее - VG). Для этого можно воспользоваться lsblk

Также можно воспользоваться утилитой 
lvmdiskscan

### Для начала разметим диск для будущего использования LVM - создадим PV:
```
[root@otuslinux ~]#pvcreate /dev/sdb
Затем можно создавать первый уровень абстракции - VG:
[root@otuslinux ~]#vgcreate otus /dev/sdb  (Если нужно расширить существующее vgextend otus /dev/sdb)
И в итоге создать Logical Volume (далее - LV):
[root@otuslinux ~]#lvcreate -l+80%FREE -n test otus (Если нужно расширить существующее lvextend -L+40G -n test otus )
Посмотреть информацию о только что созданном Volume Group:
[root@otuslinux ~]#vgdisplay otus
Так, например, можно посмотреть информацию о том, какие диски входит в VG:
[root@otuslinux ~]#vgdisplay -v otus | grep 'PV NAME'
Детальную информацию о LV получим командой:
[root@otuslinux ~]#lvdisplay /dev/otus/test
В сжатом виде информацию можно получить командами vgs и lvs:
```

### Мы можем создать еще один LV из свободного места. На этот раз создадим не экстентами, а абсолютным значением в мегабайтах:
```
[root@otuslinux ~]#lvcreate -L100M -n small otus
```
### Создадим на LV файловую систему и смонтируем его
```
[root@otuslinux ~]#mkfs.ext4 /dev/otus/test
[root@otuslinux ~]#mount /dev/otus/test /data/
[root@otuslinux ~]#mount | grep /data
```
## LVM Resizing
Допустим перед нами встала проблема нехватки свободного места в директории /data. 
Мы можем расширить файловую систему на LV /dev/otus/test за счет нового блочного устройства /dev/sdc.
Для начала так же необходимо создать PV:
```
[root@otuslinux ~]#pvcreate /dev/sdc
Далее необходимо расширить VG добавив в него этот диск
[root@otuslinux ~]#vgextend otus /dev/sdc
Убедимся что новый диск присутствует в новой VG: 
[root@otuslinux ~]#vgdisplay -v otus | grep 'PV Name'
Убедимся что диск добавлен:
[root@otuslinux ~]#vgdisplay -v otus | grep 'PV Name'
И что места в VG прибавилось:
[root@otuslinux ~]# vgs
```
### Увеличиваем LV за счет появившегося свободного места. Возьмем не все место - это для того, чтобы осталось место для демонстрации снапшотов:
```
[root@otuslinux ~]#lvextend -l+80%FREE /dev/otus/test
Наблюдаем что LV расширен до 11.14g:
[root@otuslinux ~]#lvs /dev/otus/test
```
Но файловая система при этом осталась прежнего размера:
```
[root@otuslinux ~]#df -Th /data
Filesystem   
Type  Size  Used Avail Use% Mounted on
/dev/mapper/otus-test ext4  7.8G  7.8G 0 100% /data
Произведем resize файловой системы:
[root@otuslinux ~]#resize2fs /dev/otus/test
resize2fs 1.42.9 (28-Dec-2013)
Filesystem at /dev/otus/test is mounted on /data; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/otus/test is now 2919424 blocks long.
[root@otuslinux ~]#df -Th /data
Filesystem        
Type  Size  Used Avail Use% Mounted on
/dev/mapper/otus-test ext4   11G  7.8G  2.6G  76% /data
```
## Уменьшение LV
Допустим Вы забыли оставить место на снапшоты. Можно уменьшить существующий LV с помощью команды lvreduce:
```
[root@otuslinux ~]#lvreduce /dev/otus/test -L 10G
[root@otuslinux ~]#df -Th /data/
```
## LVM Snapshot
Снапшот создается командой lvcreate, только с флагом -s, который указывает на то, что это снимок:
```
[root@otuslinux ~]#lvcreate -L 500M -s -n test-snap /dev/otus/test
Проверим с помощью vgs:
[root@otuslinux ~]# sudo vgs -o +lv_size,lv_name | grep test
Команда lsblk, например, нам наглядно покажет, что произошло:
[root@otuslinux ~]# lsblk
```
#### Снапшот можно смонтировать как и любой другой LV:
[root@otuslinux]# mkdir /data-snap
[root@otuslinux data]# mount /dev/otus/test-snap /data-snap/
[root@otuslinux data]# ll /data-snap/
[root@otuslinux data]# unmount /data-snap

Можно также восстановить предыдущее состояние. “Откатиться” на снапшот. Для этого 
сначала для большей наглядности удалим наш log файл:
```
[root@otuslinux ~]# rm test.log
rm: remove regular file 'test.log'? y
[root@otuslinux ~]# ll
total 16
drwx------. 2 root root 16384 Oct 29 10:48 lost+found
[root@otuslinux ~]# umount /data
[root@otuslinux ~]# lvconvert --merge /dev/otus/test-snap
  Merging of volume otus/test-snap started.
  otus/test: Merged: 100.00%
[root@otuslinux ~]# mount /dev/otus/test /data
[root@otuslinux ~]# ll /data
```
## LVM Mirroring
Работа с lvm
```
[root@otuslinux ~]# pvcreate /dev/sd{d,e}
  Physical volume "/dev/sdd" successfully created.
  Physical volume "/dev/sde" successfully created.
[root@otuslinux ~]# vgcreate vg0 /dev/sd{d,e}
  Volume group "vg0" successfully created
[root@otuslinux ~]# lvcreate -l+80%FREE -m1 -n mirror vg0
  Logical volume "mirror" created.
[root@otuslinux ~]# lvs
```
_____________________________
Домашнее задание
На имеющемся образе 
centos/7 - v. 1804.2
1)
Уменьшить том под / до 8G
2)
Выделить том под /home
3)
Выделить том под /var -  сделать в mirror
4)
/home - сделать том для снапшотов
5)
Прописать монтирование в fstab. Попробовать с разными опциями и разными 
файловыми системами ( на выбор)
Работа со снапшотами:
- сгенерить файлы в /home/
- снять снапшот
- удалить часть файлов
- восстановится со снапшота
- залоггировать работу можно с помощью утилиты scrip
_________________________________
***
Подготовим временный том для / раздела:
```
[root@otuslinux ~]# pvcreate /dev/sdb
[root@otuslinux ~]# vgcreate vg_root /dev/sdb
[root@otuslinux ~]#lvcreate -n lv_root -l +100%FREE /dev/vg_root
Создадим на нем файловую систему и смонтируем его, чтобы перенести туда данные:
[root@otuslinux ~]# mkfs.xfs /dev/vg_root/lv_root
[root@otuslinux ~]# mount /dev/vg_root/lv_root /mnt
```
Этой командой скопируем все данные с / раздела в /mnt:
```
[root@otuslinux ~]# xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
```
Тут выхлоп большой, но в итоге вы должны увидеть SUCCESS. Проверить что скопировалось 
можно командой ls /mnt

Затем переконфигурируем grub для того, чтобы при старте перейти в новый /
Сымитируем текущий root -> сделаем в него chroot и обновим grub:
```
[root@otuslinux ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@otuslinux ~]# chroot /mnt/
[root@otuslinux ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
```
Обновим образ initrd. Что это такое и зачем нужно вы узнаете из след. лекции.
```
[root@otuslinux ~]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
```
Перезагружаемся успешно с новым рут томом. Убедиться в этом можно посмотрев вывод 
lsblk:
```
[root@otuslinux ~]# lsblk
```
Теперь нам нужно изменить размер старой VG и вернуть на него рут. Для этого удаляем 
старый LV размеров в 40G и создаем новый на 8G:
```
[root@otuslinux ~]# lvremove /dev/VolGroup00/LogVol00
[root@otuslinux ~]# lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
```
Проделываем на нем те же операции, что и в первый раз:
```
[root@otuslinux ~]# mkfs.xfs /dev/VolGroup00/LogVol00
[root@otuslinux ~]# mount /dev/VolGroup00/LogVol00 /mnt
[root@otuslinux ~]# xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
```
Так же как в первый раз переконфигурируем 
grub, 
за исключением правки /etc/grub2/grub.cfg
```
[root@otuslinux ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@otuslinux ~]# chroot /mnt/
[root@otuslinux ~]# grub2-mkconfig -o /boot/grub2/grub.cfg

[root@otuslinux ~]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
```
Пока не перезагружаемся и не выходим из под chroot - мы можем заодно перенести /var!

На свободных дисках создаем зеркало:
```
[root@otuslinux ~]#pvcreate /dev/sdc /dev/sdd
[root@otuslinux ~]# vgcreate vg_var /dev/sdc /dev/sdd
[root@otuslinux ~]# lvcreate -L 950M -m1 -n lv_var vg_var
```
Создаем на нем ФС и перемещаем туда /var:
```
[root@otuslinux ~]# mkfs.ext4 /dev/vg_var/lv_var
[root@otuslinux ~]# mount /dev/vg_var/lv_var /mnt
[root@otuslinux ~]# cp -aR /var/* /mnt/   
```
```
 rsync -avHPSAX /var/ /mnt/
 ```
На всякий случай сохраняем содержимое старого var (или же можно его просто удалить):
```
[root@otuslinux ~]# mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
```
Ну и монтируем новый var в каталог /var:
```
[root@otuslinux ~]# umount /mnt
[root@otuslinux ~]# mount /dev/vg_var/lv_var /var
```
Правим fstab для автоматического монтирования /var:
```
[root@otuslinux ~]# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
```
После чего можно успешно перезагружаться в новый (уменьшенный root) и удалять временную Volume Group:
```
[root@otuslinux ~]# lvremove /dev/vg_root/lv_root
[root@otuslinux ~]# vgremove /dev/vg_root
[root@otuslinux ~]# pvremove /dev/sdb
```
Выделяем том под /home по тому же принципу что делали для /var:
```
[root@otuslinux ~]# lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
[root@otuslinux ~]# mkfs.xfs /dev/VolGroup00/LogVol_Home
[root@otuslinux ~]# mount /dev/VolGroup00/LogVol_Home /mnt/
[root@otuslinux ~]# cp -aR /home/* /mnt/   
[root@otuslinux ~]# rm -rf /home/*
[root@otuslinux ~]# umount /mnt
[root@otuslinux ~]# mount /dev/VolGroup00/LogVol_Home /home/
```
Правим fstab для автоматического монтирования /home
```
[root@otuslinux ~]# echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
Сгенерируем файлы в /home/:
[root@otuslinux ~]# touch /home/file{1..20}
Снять снапшот:
[root@otuslinux ~]# lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
Удалить часть файлов:
[root@otuslinux ~]# rm -f /home/file{11..20}
Процесс восстановления со снапшота:
[root@otuslinux ~]#umount /home
[root@otuslinux ~]# lvconvert --merge /dev/VolGroup00/home_snap
[root@otuslinux ~]# mount /home