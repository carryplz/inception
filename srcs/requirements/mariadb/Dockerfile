FROM debian:bookworm

# MariaDB 설치 및 정리
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# MariaDB 설정 파일 복사
COPY conf/mariadb.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# 초기화 스크립트 복사
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# MariaDB 실행에 필요한 디렉토리 권한 설정
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

# 로그 디렉토리 생성 (mariadb.cnf에서 log_error 경로 사용)
RUN mkdir -p /var/log/mysql && \
    chown -R mysql:mysql /var/log/mysql

CMD ["/usr/local/bin/init.sh"]