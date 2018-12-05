# System Administration HW3 Writeups

## Install Apache on FreeBSD
* [Main information is here](https://www.freebsd.org/doc/zh_TW/books/handbook/network-apache.html)
* 
    ```sh
    cd /usr/ports/www 
    #you will see apache22 and apache24 either is fine
    make install clean
    ```
* Config options
    ```
    WITH_SSL (default)
    WITH_MPM=worker
    WITH_THREADS=yes
    WITH_SUEXEC=yes
    ```
* Vulnerable port tree problem
    ```
    1 problem(s) in the installed packages found.
    => Please update your ports tree and try again.
    => Note: Vulnerable ports are marked as such even if there is no update available.
    => If you wish to ignore this vulnerability rebuild with 'make DISABLE_VULNERABILITIES=yes'
    *** Error code 1
    ```
    
    update it to solve the problem
    ```
    portsnap fetch update
    ```
    if cries
    ```
    you must run portsnap extract before running portsnap update
    ```
    then just to it

    ```
    portsnap fetch extract
    ```

    if still not able to install such as Error 127, than use pkg to install
    ```
    pkg install apache24
    ```
## Prob1. Virtual Host

 
