# System Administration HW3 Writeups

## FTP part I, prequisities

### Step 1: Install the pure-ftpd if nothing is found in your /usr/ports
* First install the snap if is cries 

cd /usr/ports/ftp/pureftpd
/usr/ports/ftp/pureftpd: No such file or directory.
```sh
portsnap fetch
```
* Make it with the component that TA wants
```sh
cd /usr/ports/ftp/pureftpd
sudo make #(compile with the upload script after the GUI pops out, must be installed with sudo!)
```
### Step 2: Start the pureftp daemon "pure-ftpd".
* Now start the ftp daemon service but cries with the following error
```sh
sudo pure-ftpd onestart

/usr/local/etc/rc.d/pure-ftpd: WARNING: /usr/local/etc/pure-ftpd.conf is not readable.
/usr/local/etc/rc.d/pure-ftpd: WARNING: failed precmd routine for pureftpd
```

found that pure-ftpd in /usr/local/etc is not named as pure-ftpd.conf but pure-ftpd.conf.sample
so just
```sh

/usr/local/etc/rc.d
> cd ..
> ls
avahi				gnome.subr			periodic			pureftpd-pgsql.conf.sample	tcsd.conf
bash_completion.d		gtk-2.0				pkg.conf			rc.d				tcsd.conf.sample
cups				man.d				pkg.conf.sample			ssl				vim
dbus-1				pam.d				pure-ftpd.conf.sample		sudoers
devd				papersize.a4			pureftpd-ldap.conf.sample	sudoers.d
fonts				papersize.letter		pureftpd-mysql.conf.sample	sudoers.dist
> sudo mv pure-ftpd.conf.sample pure-ftpd.conf
```

and then
```sh
sudo service pure-ftpd onestart
sudo service pure-ftpd status
pureftpd is running as pid 83241. #this shows pure-ftpd is running well
```

### Step 3: Trouble shooting after building pure-ftpd but still unable to connect from FileZilla

* Problem: Unable to connect from localhost to ftp within same PC(one in main OS and the other in the Virtual Box, the user is the one that created after installed FreeBSD)

![](https://imgur.com/NRc2Dza.png)

![](https://imgur.com/r91d07b.png)

* Reason: Due to the lack of users to be added in the pure-pw system, the pure=pw system is the stand alone user database hold by pure-ftpd

* Solution: Try to first add the account and do the configs
    <br />Tool is under /usr/local/bin/pure-pw
    <br />Database is under /usr/local/etc/pureftpd.passwd and
/usr/local/etc/pureftpd.pdb, cat it after successfully added user to see if data write correctly.
    
    * 3-1. Added the user virtual user
    ```sh
    pure-pw useradd <user_name> -u <uid> -g <gid> -d <home_dir_path>
    #for example add test for the id 1003, gid 1003 of system,
    whose home dir is /home/ftp
    pure-pw useradd user1 -u 1003 -g 1003 -d /home/ftp
    ```
    
    * 3-2. Build database and restart
    ```sh
    pure-pw mkdb
    sudo service pure-ftpd restart
    ```

    * 3-3. OK to login or not?, if not, see( [link1 for database checking](https://www.jianshu.com/p/7d86472208cd
    )or [link2 to config your network adapter, and ftp to your virtual user](https://www.youtube.com/watch?v=xlJQ9uWs_qU&list=PL68bOVolR6EqKCHaFJvcLPX8CuqxLRIGo) )
    Note: Don't forget to `dhclient <host_only_adapter_name>` in BSD for configuring local IP correctly, for example, the newly added adapter for me is em1
    ```sh
    ifconfig

    em1: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
    options=9b<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,VLAN_HWCSUM>
    ether 08:00:27:d0:6c:f8
    hwaddr 08:00:27:d0:6c:f8
    inet 192.168.56.101 netmask 0xffffff00 broadcast 192.168.56.255
    nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
    media: Ethernet autoselect (1000baseT <full-duplex>)
    status: active
    ```
    Then we can successfully ftp to `192.168.56.101`


## FTP part II HW requirements(check 09_file_system pdf p31 -  for more info)

### Some knowledges to know before proceed this part
* [What is wheel and why use it?](https://www.cnblogs.com/jan5/p/3359421.html)

* [Linux system account administration](http://linux.vbird.org/linux_basic/0410accountmanager.php#passwd_file)

* [shell nologin vs false](https://unix.stackexchange.com/questions/10852/whats-the-difference-between-sbin-nologin-and-bin-false)

* To check all users and groups
```sh
awk -F":" '{print $1}' /etc/passwd
awk -F":" '{print $1}' /etc/group
```

* Regular Linux file permission
[See 鳥哥 5.2.3 to understand what rwx can do](http://linux.vbird.org/linux_basic/0210filepermission.php#filepermission_dir)

### Prob 1. Anonymous Login
```
Anonymous Login
 Can download from /home/ftp/public
 Can upload & mkdir from /home/ftp/upload
 But no download or delete from /home/ftp/upload
 Hidden directory problem /home/ftp/hidden
 There is a directory called “treasure” inside /home/ftp/hidden/
 Client can’t list /home/ftp/hidden/ but can enter hidden/treasure
```

* Unable to chroot??

```sh
sudo chroot -u alfons0329 /home/alfons0329/
chroot: /bin/tcsh: No such file or directory
```

Check your `$PATH` to see if chroot exists

```sh
echo $0 #usually lies in /usr/sbin
```

Mine exists, but stil unable to chroot :|

[check this link](https://unix.stackexchange.com/questions/128046/chroot-failed-to-run-command-bin-bash-no-such-file-or-directory?fbclid=IwAR1xV7TzWuW2tugvfZnmpV5-rA1la-HIm6AyGl-ufeOrVSsqaPJXP7FMdrk)