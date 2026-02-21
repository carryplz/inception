#!/bin/bash

set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
    echo "Waiting for MariaDB..."
    sleep 2
done

if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "wordpress downloading"
    wp core download --allow-root

    wp config create --allow-root \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb:3306

    wp core install --allow-root \
        --url=${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL}

    wp user create ${WP_USER_USER} ${WP_USER_EMAIL} \
        --user_pass=${WP_USER_PASSWORD} \
        --role=author \
        --allow-root

    # Redis 연결 설정
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --allow-root

    # Redis 캐시 플러그인 설치 및 활성화
    wp plugin install redis-cache --activate --allow-root

    # Redis 캐시 활성화
    wp redis enable --allow-root

    echo "wordpress installation completed!"
else
    echo "wordpress is already installed."
fi

exec "$@"