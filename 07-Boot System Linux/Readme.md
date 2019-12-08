# Boot System Linux

1. Попасть в систему без пароля несколькими способами
1. Установить систему с LVM, после чего переименовать VG
1. Добавить модуль в initrd

### Попасть в систему без пароля несколькими способами
1. Первый способ взят из [документации RedHat](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/sec-terminal_menu_editing_during_boot#sec-Changing_and_Resetting_the_Root_Password)
1. При загрузке VM в меню Grub используем e, что позволит отредактировать опции загрузки:
1. нажимаем `e` в меню граба
1. добавляем в параметры запуска ядра (строчка `linux16`) команду `rd.break
1. перезагружаемся с установленными параметрами `ctrl+x`
   1. Меняем пароль от `root`
        ```bash
        mount -o remount,rw /sysroot
        chroot /sysroot
        passwd
        touch /.autorelabel
        mount -o remount,ro /
        exit```
        exit
    1.Проверяем
### Способ второй

1. Способ основан на подмене процесса с которого стартует ядро (по умолчанию это `/sbin/init`)
    1. Подменяем `init` процесс
        1. нажимаем `e` в меню граба
        1. добавляем в параметры запуска ядра (строчка `linux16`) команду `init=/sysroot/bin/sh`
        1. перезагружаемся с установленными параметрами `ctrl+x`
    1. Меняем пароль от `root`
        ```bash
        mount -o remount,rw /
        passwd
        touch /.autorelabel
        mount -o remount,ro /
        reboot```
        
### Установить систему с LVM, после чего переименовать VG
Устанавливаем CentOS в VM, в разделе настройки диска выбираем установку на LVM.
После установки используя `vgs` получаем имя VG = `centos`.
`lvs` покажет, что существут LV c именем = `root`, где и примонтирован `/`
`vgrename -v centos rootvg` - переименовываем VG
`vi /etc/defaults/grub` - изменяем опцию `GRUB_CMDLINE_LINUX`, заменяя в ней имя VG на новое `rootvg`
`vi /etc/fstab` - изменяем опцию монтирования, также указывая новую VG `rootvg`

  Перезагружаем VM и с установочного диска стартуем rescue режим, используем `chroot /mnt/sysimage` и получаем доступ к нашей системе.
`grub2-mkconfig -o /boot/grub2/grub.cfg` - создаем новый конфиг для Grub
Перезагружаем VM, запускаем систему штатно. Загрузка успешна с новым именем VG.

### Добавить модуль в initrd

### Добавить модуль в initrd
  1. Скрипт создания модуля: `dracut/add-module.sh`
     1. Для проверки можно запустить vm и увидеть пингвинчика при запуске.
        1. Либо можно зайти в запущенный бокс и запустить
            ```bash
            lsinitrd -m /boot/initramfs-$(uname -r).img | grep pinguin
            ```
