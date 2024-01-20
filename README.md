![alt text](rh_small_logo.jpg)
* This repository contains a script to deploy Zabbix 6.0 LTS via docker containers. For any additional details or inquiries, please contact us at christopher.sargent@railhead.io.

# Deploy Zabbix 6.0 LTS
1. ssh onrails@IP
2. sudo -i 
3. git clone git@github.com:ChristopherSargent/railhead_zabbix.git
4. cd railhead_zabbix
5. mkdir pgdata
6. ./deploy_zabbix6.sh
7. docker ps 
```
CONTAINER ID   IMAGE                                             COMMAND                  CREATED         STATUS         PORTS                                                                            NAMES
9db1430112a1   zabbix/zabbix-web-nginx-pgsql:alpine-6.0-latest   "docker-entrypoint.sh"   7 minutes ago   Up 7 minutes   0.0.0.0:80->8080/tcp, :::80->8080/tcp, 0.0.0.0:443->8443/tcp, :::443->8443/tcp   zabbix-web-nginx-pgsql
6cf347bd5485   zabbix/zabbix-server-pgsql:alpine-6.0-latest      "/sbin/tini -- /usr/…"   7 minutes ago   Up 7 minutes   0.0.0.0:10051->10051/tcp, :::10051->10051/tcp                                    zabbix-server-pgsql
8f3084052462   zabbix/zabbix-snmptraps:alpine-6.0-latest         "/usr/sbin/snmptrapd…"   7 minutes ago   Up 7 minutes   0.0.0.0:162->1162/udp, :::162->1162/udp                                          zabbix-snmptraps
66d9635c0331   postgres:latest                                   "docker-entrypoint.s…"   7 minutes ago   Up 7 minutes   5432/tcp                                                                         postgres-server
```
8. http://IP 

