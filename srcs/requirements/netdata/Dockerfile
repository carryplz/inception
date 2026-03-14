FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    netdata \
    && rm -rf /var/lib/apt/lists/*

# 설정을 직접 생성하여 0.0.0.0(모든 주소)에서 접속 허용
RUN echo "[global]\n\
    run as user = netdata\n\
    web files owner = root\n\
    web files group = netdata\n\
    bind socket to IP = 0.0.0.0\n" > /etc/netdata/netdata.conf

EXPOSE 19999

# 포그라운드 모드로 실행
CMD ["netdata", "-D"]