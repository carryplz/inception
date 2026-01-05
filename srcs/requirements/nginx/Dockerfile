FROM alpine:3.19

# 패키지 설치 (nginx, openssl)
RUN apk update && apk add --no-cache nginx openssl

# SSL 인증서 생성 (과제 요구사항: TLSv1.2/1.3)
# -x509: Self-signed 인증서 생성
# -nodes: 개인키 암호화 안 함 (자동 실행 위해)
# -days 365: 유효기간
# -newkey rsa:2048: RSA 알고리즘 사용
# -keyout / -out: 키와 인증서 저장 위치
# -subj: 인증서 정보 자동 입력 (대화형 입력 방지)
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=Inception/CN=injo.42.fr"

# NGINX 설정 복사 (설정 파일은 나중에 만들 예정)
COPY conf/nginx.conf /etc/nginx/http.d/default.conf

# NGINX 실행 (foreground 모드 필수!)
CMD ["nginx", "-g", "daemon off;"]