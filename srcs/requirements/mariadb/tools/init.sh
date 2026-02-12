#!/bin/bash

set -e

echo "MariaDB start"

# 1. 시스템 DB가 없으면 초기화
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# 2. MariaDB 백그라운드 실행
mysqld_safe --datadir='/var/lib/mysql' &

# 3. 준비될 때까지 대기
until mysqladmin ping -u root >/dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 2
done

echo "MariaDB is ready."

# 4. 데이터베이스/유저 생성 (첫 실행만)
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

# 5. 안전한 shutdown (root 비밀번호 두 가지 경우 모두 대응)
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown 2>/dev/null || \
    mysqladmin -u root shutdown 2>/dev/null

echo "MariaDB restarting in foreground"
exec mysqld