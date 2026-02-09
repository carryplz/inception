#!/bin/bash

set -e

echo "MariaDB starting..."
mysqld_safe --datadir='/var/lib/mysql' &

# DB가 응답할 때까지 대기
until mysqladmin ping >/dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 2
done

# 최초 실행 시 (데이터베이스 폴더가 없을 때) 초기화 진행
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Initializing MariaDB for the first time..."

    # 1. 루트 비밀번호 설정 및 DB/유저 생성
    # 처음에는 비밀번호 없이 접속 시도 후, 루트 비번 변경과 유저 생성을 한 번에 처리
    mysql -u root << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    echo "Database and user created successfully."
else
    echo "Database already exists."
fi

# 설정을 마친 후 안전하게 셧다운
# 이때부터는 설정된 루트 비밀번호가 필요함
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "MariaDB restarting in foreground..."
exec mysqld

