# srcs/requirements/redis/Dockerfile

FROM debian:bookworm

RUN apt-get update && apt-get install -y redis-server && \
    rm -rf /var/lib/apt/lists/*

# 외부(wordpress 컨테이너)에서 접근 가능하도록 bind 주소 변경
RUN sed -i "s/bind 127.0.0.1/bind 0.0.0.0/" /etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "--protected-mode", "no"]