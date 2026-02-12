#!/bin/bash

set -e

MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

echo "MariaDB start"

# 시스템 DB가 없으면 초기화
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe --datadir='/var/lib/mysql' &

until mysqladmin ping -u root >/dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 2
done

echo "MariaDB is ready."

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    echo "Database created"
else
    echo "Database already exists"
fi

mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown 2>/dev/null || \
    mysqladmin -u root shutdown 2>/dev/null

echo "MariaDB restarting in foreground"
exec mysqld