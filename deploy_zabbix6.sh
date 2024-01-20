#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs -d '\n')
fi

# Create directories
#mkdir -p railhead_zabbix6/pgdata
#mkdir -p railhead_zabbix6/zbx_instance/snmptraps
#mkdir -p railhead_zabbix6/zabbix-data/{alertscripts,externalscripts,export,modules,enc,ssh_keys,mibs,snmptraps}

# Create Docker network
docker network create --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 zabbix-net

# Run PostgreSQL container
docker run --name postgres-server -t \
      -e POSTGRES_USER="${POSTGRES_USER}" \
      -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
      -e POSTGRES_DB="${POSTGRES_DB}" \
      --network=zabbix-net \
      -v "./pgdata:/var/lib/postgresql/data:rw" \
      --restart unless-stopped \
      -d postgres:latest

# Run Zabbix SNMP Traps container
docker run --name zabbix-snmptraps -t \
      -v "./zbx_instance/snmptraps:/var/lib/zabbix/snmptraps:rw" \
      -v /var/lib/zabbix/mibs:/usr/share/snmp/mibs:ro \
      --network=zabbix-net \
      -p 162:1162/udp \
      --restart unless-stopped \
      -d zabbix/zabbix-snmptraps:alpine-6.0-latest

# Run Zabbix Server with PostgreSQL container
docker run --name zabbix-server-pgsql -t \
      -e DB_SERVER_HOST="postgres-server" \
      -e POSTGRES_USER="${POSTGRES_USER}" \
      -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
      -e POSTGRES_DB="${POSTGRES_DB}" \
      -e ZBX_ENABLE_SNMP_TRAPS="true" \
      --network=zabbix-net \
      -p 10051:10051 \
      -v /etc/localtime:/etc/localtime:ro \
      -v /etc/timezone:/etc/timezone:ro \
      -v "./zabbix-data/alertscripts:/usr/lib/zabbix/alertscripts:ro" \
      -v "./zabbix-data/externalscripts:/usr/lib/zabbix/externalscripts:ro" \
      -v "./zabbix-data/export:/var/lib/zabbix/export:rw" \
      -v "./zabbix-data/modules:/var/lib/zabbix/modules:ro" \
      -v "./zabbix-data/enc:/var/lib/zabbix/enc:ro" \
      -v "./zabbix-data/ssh_keys:/var/lib/zabbix/ssh_keys:ro" \
      -v "./zabbix-data/mibs:/var/lib/zabbix/mibs:ro" \
      -v "./zabbix-data/snmptraps:/var/lib/zabbix/snmptraps:rw" \
      --restart unless-stopped \
      -d zabbix/zabbix-server-pgsql:alpine-6.0-latest

# Run Zabbix Web Nginx with PostgreSQL container
docker run --name zabbix-web-nginx-pgsql -t \
      -e ZBX_SERVER_HOST="zabbix-server-pgsql" \
      -e DB_SERVER_HOST="postgres-server" \
      -e POSTGRES_USER="${POSTGRES_USER}" \
      -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
      -e POSTGRES_DB="${POSTGRES_DB}" \
      --network=zabbix-net \
      -p 443:8443 \
      -p 80:8080 \
      -v /etc/ssl/nginx:/etc/ssl/nginx:ro \
      --restart unless-stopped \
      -d zabbix/zabbix-web-nginx-pgsql:alpine-6.0-latest

