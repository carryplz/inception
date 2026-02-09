#!/bin/bash
set -e

echo "MariaDB starting..."

# 1. 로그 디렉토리 권한 확인 (없으면 생성)
mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

# 2. MariaDB 백그라운드 실행
mysqld_safe --datadir='/var/lib/mysql' &

# 3. MariaDB 준비 대기 (사용자명 -u root 추가)
# 핑이 성공할 때까지 대기합니다.
until mysqladmin -u root ping >/dev/null 2>&1; do
    echo "Waiting for MariaDB to be ready..."
    sleep 2
done

echo "MariaDB is ready. Starting configuration..."

# 4. 데이터베이스 및 유저 생성
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    echo "Database and user created."
else
    echo "Database already exists."
fi

# 5. 설정 완료 후 임시 프로세스 종료
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "MariaDB restarting in foreground..."
# 6. 포그라운드 실행
exec mysqld