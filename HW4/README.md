# System Administration HW4 Writeups

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
* Config the `/usr/local/etc/apache24/extra/httpd-vhosts.conf`
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
* Add this to your `/usr/local/etc/apache24/httpd.conf`
    
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


### Prob4. Reverse Proxy
* Decomment the following module in `/usr/local/etc/apache24/httpd.conf`
    ```
    LoadModule watchdog_module
    LoadModule proxy_module
    LoadModule proxy_http_module
    LoadModule proxy_balancer_module
    LoadModule proxy_hcheck_module
    LoadModule lbmethod:q_bytraffic_module
    ```
Also do not forget to decomment `slotmem_shm_module`
* Add this to your `/usr/local/etc/apache24/httpd.conf`

    What in httpd.conf should be like this (create a `proxy balancer` object)
    ```
    <Proxy balancer://myset>
    BalancerMember http://sahw4-loadbalance1.nctucs.net/ #balancer1 for this HW
    BalancerMember http://sahw4-loadbalance2.nctucs.net/ #balancer2 for this HW
    ProxySet lbmethod=bytraffic #balance by traffic
    </Proxy>

    ProxyPass "/reverse/"  "balancer://myset/" #request to reverse are proxied according to this scheme
    ProxyPassReverse "/reverse/"  "balancer://myset/" #request to reverse are proxied according to this scheme
    ```
    In the above, any requests which start with the /reverse path with be proxied to the specified backend, otherwise it will be handled locally.

* Trouble shooting, please refer to `/var/log/httpd-error.log` to check what error occurred

### Prob5. Disguise Server Token

* First, install modesecurity in `/usr/ports/www/mod_security`
    ```sh
    make install clean
    ```
* Trboule shooting: Manually install perl if ceris about dependency
    ```
    env: /usr/local/bin/perl5.26.3: No such file or directory
    Error code 127
    ```
    Download perl [here](http://www.cpan.org/src/)

    ```sh
    sudo wget https://www.cpan.org/src/5.0/perl-5.26.3.tar.gz
    sudo ./Config -Dprefix=$HOME/localperl
    sudo make test
    sudo make install
    sudo ln -s /home/ftp/localperl/bin/perl5.26.3 /usr/local/bin/perl5.26.3
    ```

    **I STILL FAILED TO INSTALL, SO I USE PORT FOR ELTERNATIVE**

    ```sh
    pkg install www/mod_security
    ```

* Decomment last 3 lines these in `/usr/local/etc/apache24/modules.d/280_mod_security.conf`
* Check if success by `curl -Ilk $IP_of_your_domain`
    * Success: Server name is disguised like
    ```
    $ curl -Ilk $your_IP
    HTTP/1.1 200 OK
    Date: Thu, 06 Dec 2018 07:04:04 GMT
    Server: Some other server
    Last-Modified: Wed, 05 Dec 2018 16:25:37 GMT
    ETag: "50-57c48d5083f7a"
    Accept-Ranges: bytes
    Content-Length: 80
    Content-Type: text/html
    ```
    * Failed: Server name shows something like Apache version
* Visit [here](http://bojack.pixnet.net/blog/post/31610515-%E3%80%90freebsd%E3%80%91%E5%9C%A8-apache-%E4%B8%8A%E9%9D%A2%E5%AE%89%E8%A3%9D-modsecutiry-%28open-sourc) for more information


### Prob6. HTTPS and Redirect
* Just visit [here](https://blog.csdn.net/ithomer/article/details/50433363) for all the tutorial* Check if success by `curl -Ilk $Your_domain`
    * Success, sees 302 HTTP redirect to HTTPS web page
    * Failed, no 302
* I put my certificate under `/usr/local/etc/apache24/certificate.crt` for convenience
* I put my key under `/usr/local/etc/apache24/key.key` for convenience

## nginx server
## Read this first
`Some unexpected error may occurred, so I write the trouble shooting strategy in the comment of config file such as`
`Please CTRL+F searching "nginx-tbst" for each solution`
    ```
    #reverse proxy and load balance THIS SHOULD BE IN THE SERVER CONTEXT BLOCK SAME AS YOUR DOMAIN METHOD, OTHERWISE ERROR 404 or 403 MAY OCCURR
    location /reverse/
    {
    root /usr/local/www/apache24/data; 
    proxy_pass http://back/;
    }
    ```
`This paragraph shows the possible reason result in 404 or 403 error in webpage`
### Install nginx on FreeBSD
* Install the nginx server
    ```sh
    cd /usr/ports/www/nginx
    sudo make install clean
    ```
* Select `headers more` to hide server token

### Prob1. Virtual Host
* Add the these to your `/usr/local/etc/nginx/nginx.conf`
    
    ```
	#for domain to get in
	server 
	{
		listen 80;
		server_name $your_domain;

		location / #decent from apache24/data (root of webpage)
		{
			types {}
			default_type text/html;
			root /usr/local/www/apache24/data; 
		}
	}
	
	#for IP to get in
	server 
	{
		listen 80;
		server_name $your_IP;

		location /
		{
			root /usr/local/www2/apache24/data;
		}
	}
    ```

### Prob2. Indexing
* Use the same content as Apache is fine, no need to write anything new

### Prob3. htaccess
* Add the these to your `/usr/local/etc/nginx/nginx.conf`
    ```
    #htaccess
    location /public/admin/
    {
        auth_basic "Protect by htaccess, please provide user account and password" ;
        auth_basic_user_file /var/www/apache.passwd; 
        root /usr/local/www/apache24/data; 
        #--------------nginx-tbst-----------------------#
        # Note NOT: root /usr/local/www/apache24/data/public/admin; !!! Just same as the last one since
        # the serching path is root/location so root/location for this is procted as htaccess 
    }

    ```
### Prob4. Reverse Proxy
* Add the these to your `/usr/local/etc/nginx/nginx.conf`
    ```
    #THIS SHOULD BE OUT THE SERVER CONTEXT BLOCK SAME OF YOUR DOMAIN METHOD
    upstream back	
	{
		#server http://sahw4-loadbalance1.nctucs.net/ weight=1; NO NEED TO WRITE HTTP SINCE proxy pass will add in the prefix
		server sahw4-loadbalance1.nctucs.net weight=1 ; 
        #--------------nginx-tbst-----------------------#
		#server http://sahw4-loadbalance2.nctucs.net/ weight=1; NO NEED TO WRITE HTTP SINCE proxy pass will add in the prefix
		server sahw4-loadbalance2.nctucs.net weight=1 ;
	}

    #--------------nginx-tbst-----------------------#
    #reverse proxy and load balance THIS SHOULD BE IN THE SERVER CONTEXT BLOCK SAME AS YOUR DOMAIN METHOD, OTHERWISE ERROR 404 or 403 MAY OCCURR
    location /reverse/
    {
        root /usr/local/www/apache24/data; 
        proxy_pass http://back/;
    }
    ```
		
### Prob5. Disguise Server Token
* Step 1. Install the `headers_more_module` from github [here](https://github.com/openresty/headers-more-nginx-module#installation)
* Install 
    ```sh
    wget 'http://nginx.org/download/nginx-1.13.6.tar.gz'
    tar -xzvf nginx-1.13.6.tar.gz
    cd nginx-1.13.6/

    # Here we assume you would install you nginx under /opt/nginx/.
    ./configure --prefix=/opt/nginx \
        --add-module=/path/to/headers-more-nginx-module

    make
    make install
    ```
* Step 3. add these to your `/usr/local/etc/nginx/nginx.conf`

    ```
    #for disguise the server
    more_set_headers 'Server: Some other server';
    ```
### Prob6. HTTPS and Redirect
* Add these to your `/usr/local/etc/nginx/nginx.conf`, both domain and IP method context
`The certificate and key can be the same as that in Apache (same path and file will be fine)`   
    ```
    #In 
    more_set_headers 'Server: Some other server';

    #for HTTPS and redirect
    listen 443 ssl; 

    #the path of certificate and key
    ssl_certificate /usr/local/etc/apache24/certificate.crt;
    ssl_certificate_key /usr/local/etc/apache24/key.key;

    #enhance the security
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ```

* Add these to your `/usr/local/etc/nginx/nginx.conf`, both domain method context

    ```
    #In domain method context    
    #redirect
    #--------------nginx-tbst-----------------------#
    #rewrite ^(.*)$ https://$host$1 ; this gives ERR_TOO_MANY_REDIRECTS
    if ($scheme = http)
    {
        return 301 https://$your_domain$request_uri;
    }
    ```

* Add these to your `/usr/local/etc/nginx/nginx.conf`, IP method context
    
    ```
    #In IP method context
    #redirect
    #--------------nginx-tbst-----------------------#
    #rewrite ^(.*)$ https://$host$1 ; this gives ERR_TOO_MANY_REDIRECTS
    if ($scheme = http)
    {
        return 301 https://$your_IP$request_uri;
    }
    ```

