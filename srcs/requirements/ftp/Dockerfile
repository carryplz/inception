FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 21

ENTRYPOINT ["/init.sh"]