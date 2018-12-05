# System Administration HW3 Writeups

## Apache server
### Install Apache on FreeBSD
* [Main information is here](https://www.freebsd.org/doc/zh_TW/books/handbook/network-apache.html)
* Install the Apache server
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
* Trouble shooting: Vulnerable port tree problem
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
### Prob1. Virtual Host

* Get a domain
    * Visit [here](https://www.nctucs.net) to apply a domain if you are student in CS NCTU
    * Create hosts where hosts to be your domain name and record to be your IP address
    * then put your $domain_name in `/usr/local/etc/apacheXX/httpd.conf`
        ```
        ServerName: www.example.com:80 #case sensitive
        ```
    * Use the IP address or local address for it (if extern IP should you use the bridge mode)
* Config the `/usr/local/etc/apache24/httpd.conf`
    * Rememner to decomment `Virtual hosts Include etc/apache24/extra/httpd-vhosts.conf`
    Make two `dir objects` for IP access and Domain access
        ```
        DocumentRoot $document_root_path_for_your_site #such as /usr/local/www/apache24/data
        <Directory "$document_root_path_for_your_site">
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
        </Directory>
        ```
* Config the `/etc/apache24/extra/httpd-vhosts.conf`
    ```
    <VirtualHost *:80>
   	#ServerAdmin webmaster@dummy-host.example.com
    DocumentRoot "/usr/local/www/apache24/data"
    ServerName $your_domain
    ServerAlias http://$your_domain
    ErrorLog "/var/log/dummy-host.example.com-error_log"
    CustomLog "/var/log/dummy-host.example.com-access_log" common
    </VirtualHost>

    # This is for IP to get in
    <VirtualHost *:80>
    #ServerAdmin webmaster@dummy-host2.example.com
    DocumentRoot "/usr/local/www2/apache24/data" #TWO DIFFERENT DIR FOR DOMAIN NAME ACCESS AND IP ACCESS
    ServerName $IP_addr
    ErrorLog "/var/log/dummy-host2.example.com-error_log"
    CustomLog "/var/log/dummy-host2.example.com-access_log" common
    </VirtualHost>
    ```
* Visit [here](https://vannilabetter.blogspot.com/2017/12/freebsd-apachephp.html?m=1&fbclid=IwAR0uqICO3YzKjq37YPKgO4BIAJyy0h3bpEkroF_NADtx6RiQb4svQemsoik) for more information 
* Check if success by directly typing the IP or domain name or not

* The local IP is easier for this homework if you use WiFi connection and public IP is easier for Ethernet connection. (Emperical thinking for trouble shooting)

### Prob2. Indexing
* Make the public directory
    ```sh
    sudo mkdir -p public
    ```
* Write a HTML for it to access (the normal, simpliest HTML is ok)

### Prob3. htaccess
* Change config to be like this
    ```sh
    sudo vim /usr/local/etc/apache24/httpd.conf
    ```
    
    What in httpd.conf should be like this (create another `dir object`)
    ```
    <Directory $directory_you_want_to_protect>
    AllowOverride AuthConfig
    Require user $user_auth_to_access

    AuthName $login_hint #such as "Protect by htaccess, please provide user account and password"
    Authtype Basic
    AuthUserFile $path_to_authfile #Do not put in the same foler as apache web data!!!
    </Directory>

    ```
* Add the admin user in the htpasswd
    ```
    $ sudo htpasswd -c /var/www/apache.passwd admin
    New password:
    Re-type new password:
    Adding password for user admin
    ```
* Visit [here](http://linux.vbird.org/linux_server/0360apache.php#www_adv_htaccess) for more information
