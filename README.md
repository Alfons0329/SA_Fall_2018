# System Administration Fall 2018

* Lectured by TA in CSCC@NCTU Taiwan
* Course page: [Here](https://people.cs.nctu.edu.tw/~wangth/course/sysadm/)
# Homeworks
* FreeBSD Installation [Spec](https://people.cs.nctu.edu.tw/~wangth/course/sysadm/slides/hw1.pdf)

* Shell sciprt programming [HW2 Repo](HW2_shell_only/), [Spec](https://people.cs.nctu.edu.tw/~wangth/course/sysadm/slides/hw2_en.pdf)
    *  2-1. Using only ONE LINE command to list the top 5 big files in system, calculate #of directories #of file and sum of file size
    *  2-2. Using Shell script to crawl the class JSON file from school course registration system, use awk, sed to parse it and use dialog to make one course registration system similar to that in school

* Service and Systems in FreeBSD [Writeups](HW3/README.md), [Spec](https://people.cs.nctu.edu.tw/~wangth/course/sysadm/slides/hw3.pdf)
    * FTP server, different permissions for different types of users
    * ZFS with mirror, backup, snapshot, rollback functions
    * RC scripts, self-written executables to be placed under `/usr/local/bin` for system execution
        
* Apache and nginx server [Writeups](HW4/README.md), [Spec](https://people.cs.nctu.edu.tw/~wangth/course/sysadm/slides/hw4.pdf)
    * Problems including: Virtual Host, indexing, htaccess, reverse proxy + load balance, hide server token and HTTPS + redirection

* The NIS, NFS Server and Client [Writeups for bonus(Credie to my roomate GitHub ID: lincw6666)](https://hackmd.io/oT0vo6VzTTKxx-PcK8zdYg?view&fbclid=IwAR1j3UuwKKsosfDS-3Zu3fniXo5QMYPjsrk1WABG2a3sMcEXF9ECiI8M_pk), [Spec](https://people.cs.nctu.edu.tw/~wangth/course/sysadm/slides/hw5.pdf)
    * Problems including: System file sharing, remote directories sharing, automount, NIS NFS master client SSH permission, access / root permissions ...etc.
    * Bonus with autosharing the /etc/autofs.map (self-create file on NIS map and share, need to modify the `/var/yp/Makefile` on NIS master(add what's new to share) and `/etc/auto_master` on NFS clients to redefine the automount requirements) and a script to auto create the account
