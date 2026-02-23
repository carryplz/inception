FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    netdata \
    && rm -rf /var/lib/apt/lists/*

# 외부에서 접근 가능하도록 bind 주소 변경
RUN sed -i 's/127.0.0.1/0.0.0.0/g' /etc/netdata/netdata.conf

EXPOSE 19999

CMD ["netdata", "-D"]