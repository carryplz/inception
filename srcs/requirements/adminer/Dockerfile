# srcs/requirements/adminer/Dockerfile

FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php \
    php-mysqli \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Adminer 단일 PHP 파일 다운로드
RUN wget -O /var/www/html/adminer.php https://www.adminer.org/latest.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]