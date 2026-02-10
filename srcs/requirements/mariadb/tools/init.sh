#!/bin/bash

# 에러 발생 시 스크립트 중단
set -e

echo "MariaDB start"
mysqld_safe --datadir='/var/lib/mysql' &

until mysqladmin ping >/dev/null 2>&1; do
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
    echo "Database create"

else
    echo "Database is aleardy"
fi

mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "Mariadb restart"
exec mysqld


