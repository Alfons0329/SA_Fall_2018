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

    <details><summary>Problem: Unable to chroot?? (May not surely happen)</summary>
    <p>
* 

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

    [And the second last reply of this link gives the answer!!!](https://ubuntuforums.org/showthread.php?t=1434781&s=4098497d6090e45179ec3e50e46e0118&fbclid=IwAR3LDiadDntL3FqjzHR5T4vGUzW6YPz4mse_i5KQtKvnugPDw5z6IJSTg0E)

* Reason: The root dir is the highest in the UNIX file hierachy, it should at least contains an "executable shell" in it. Hence the following commands will fail to proceed

    ```sh
    sudo mkdir /home/chrooted #make a dir named chrooted for chroot jail
    sudo chroot -u <user_name>  /home/chrooted
    > failed to run command ‘/bin/bash’: No such file or directory  #or the like
    ```

    but with

    ```sh
    sudo chroot -u <user_name> /
    #succeeded
    ```

    That is because there is no /bin/bash directory inside chroot. Make sure you point it to where bash (or other shell's) executable is in chroot directory.

* Solution: Make a symbolic link in it (there is no need to cp all the /bin/ to /home/chrooted), or `mount --bind` (seems not available in BSD)

    </p>
    </details>

### Prob 1. FTP

```
Anonymous Login
• Chrooted (/home/ftp) (5%)
• Download from “/home/ftp/public” (5%)
• Upload to “/home/ftp/upload” (5%)
• Can’t download or delete form “/home/ftp/upload” (5%)
• Hidden directory “/home/ftp/hidden” problem: can enter but can’t
retrieve directory listing (5%)
• FTP over TLS (5%)

sysadm
• Login from SSH (2%)
• Full access to “/home/ftp”, “upload”, “public” (3%)
• Full access to “hidden” (list, mkdir, upload, download…) (3%)
• FTP over TLS (2%)

ftp-vip (same permission as sysadm, but this is the virtual user in pure-db)
• Chrooted (/home/ftp) (5%)
• Full access to “/home/ftp”, “upload”, “public” (5%)
• Full access to “hidden” (list, mkdir, upload, download, …) (5%)
• FTP over TLS (5%)
```

#### Step1. Config the TLS certificate first

* See [this link](http://blog.topspeedsnail.com/archives/4309) and [this link](http://pureftpd.sourceforge.net/README.TLS)
    * pureftpd.conf lies in `/usr/local/etc` of FreeBSD

#### Step2. The permissions

* anonymous login

    * make a system user ftp so that anonymous can be attatched on that
    * PureDB should be set like this for the database`PureDB                       /usr/local/etc/pureftpd.pdb`
        ```
        drwxr-x--x(cannot list, no r permission, can cd x permission)  2 sysadm  sysadm     2 Oct 31 05:18 hidden
        drwxr-xr(anonymous download, r permission)-x  2 sysadm  sysadm     2 Oct 31 05:17 public
        drwxrwx-w(anonymous upload and mkdir, w permission, but no download and delete, remove r permission)x  2 sysadm  sysadm     2 Oct 31 05:17 upload
        ```

* sysadm
    default permission after sysadm created (enough for problem two if these folers were created ny sysadm himself)
    ```
    drwxr-xr-x  2 sysadm  sysadm     2 Oct 31 05:18 hidden
    drwxr-xr-x  2 sysadm  sysadm     2 Oct 31 05:17 public
    drwxr-xr-x  2 sysadm  sysadm     2 Oct 31 05:17 upload
    ```

* ftp-vip
    just add the ftp-vip user under the same group of sysadm and make the database will be fine

    ```sh
    #attatch virtual user: ftp-vip to the real system user sysadm and its group (make the home dir be /home/ftp)
    pure-pw add useradd ftp-vip -u sysadm -g sysadm -d /home/ftp
    sudo pure-pw mkdb
    sudo service pure-ftpd restart
    ```

#### Verifications
* Can’t download or delete form “/home/ftp/upload” (5%)
    In your FileZilla, you should see the following error msg: 

    ```
    嚴重檔案傳輸錯誤
    ```
* FTP over TLS, the TLS certificate message should popped out and then the following log
    ```
    狀態: 	連線已建立, 正在等候歡迎訊息...
    狀態: 	正在初始 TLS...
    狀態: 	正在驗證憑證...
    狀態: 	TLS 連線已建立.
    狀態: 	記錄
    狀態: 	正在取得目錄列表...
    狀態: 	成功取得 "/" 的目錄
    ```

### Prob2. ZFS and automatic backup script

#### Step1. Prerequisite

* First, make a disk and mirror it in the VM, just click add VDI with 16GB will be fine for this HW (16 / 2 = 8 for each mirror disk)

* For example, mirror 2 8GB space for zpool

    ```sh
    sudo gpart create -s GPT ada1
    sudo gpart add -t freebsd-ufs -s 8G ada1
    sudo gpart add -t freebsd-ufs -s 8G ada1
    sudo zpool create mypool mirror /dev/adap1 /dev/adap2
    ```
* Create and set datasets

    ```sh
    sudo zfs create mypool/public
    sudo zfs create mypool/upload
    sudo zfs create mypool/hidden
    ```
* Mount them together on the place for HW3 respectively, ex. mount mypool/public on the /homt/ftp/public (the rest are all the same)
    ```sh
    sudo zfs set mountpoint=/home/ftp/public mypool/public
    ```
    * And menwhile set the compression to gzip
        ```sh
        sudo zfs set compression=gzip mypool/public
        ```
* Check if mypool has been set up right
    ```sh
    $ zfs list -t all
    NAME                 USED  AVAIL  REFER  MOUNTPOINT
    mypool               196K  7.27G    23K  /mypool
    mypool/hidden         23K  7.27G    23K  /home/ftp/hidden/
    mypool/public         23K  7.27G    23K  /home/ftp/public/
    mypool/upload         23K  7.27G    23K  /home/ftp/upload/

    # check the compression type has been set up right
    $ zfs get all mypool/hidden | grep compression
    mypool/hidden  compression           gzip                   local
    ```
* The newer snapshot is, the closer to the end of command `zfs list -t snapshot`
    ```sh
    $ zfs list -t  snapshot
    NAME                   USED  AVAIL  REFER  MOUNTPOINT
    mypool/hidden@first       0      -    23K  -
    mypool/hidden@second      0      -    23K  -
    mypool/hidden@third       0      -    23K  -
    ```
* For the implementation of zbackup.sh please check [here](zbackup.sh)
#### Prob3. RC service

* If the system cris about
```sh
$ service ftp-watchd start
ftp-watchd does not exist in /etc/rc.d or the local startup
directories (/usr/local/etc/rc.d), or is not executable
```
then the solution is: 