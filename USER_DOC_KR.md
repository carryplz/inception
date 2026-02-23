# 사용자 문서 (User Documentation)

## 제공되는 서비스

**Mandatory:**

| 서비스 | 역할 | 접근 방법 |
|---|---|---|
| NGINX | HTTPS 진입점, 리버스 프록시 | `https://injo.42.fr` |
| WordPress | 웹사이트 CMS | `https://injo.42.fr` |
| MariaDB | 데이터베이스 | 내부 전용 |

**Bonus:**

| 서비스 | 역할 | 접근 방법 |
|---|---|---|
| Redis | WordPress 캐시 | 내부 전용 |
| Adminer | DB 관리 웹 UI | `http://injo.42.fr:8080/adminer.php` |
| Netdata | 시스템 모니터링 대시보드 | `http://injo.42.fr:19999` |
| 정적 웹사이트 | 소개 페이지 | `http://injo.42.fr` |
| FTP 서버 | WordPress 볼륨 파일 접근 | `ftp injo.42.fr` (21 포트) |

---

## 프로젝트 시작 및 중지

### 시작
```bash
make
```
처음 실행 시 Docker 이미지를 빌드하고 WordPress를 자동 설치합니다. 완료까지 1~2분 정도 소요됩니다.

### 중지 (데이터 유지)
```bash
docker-compose -f ./srcs/docker-compose.yaml down
```

### 완전 초기화 (데이터 삭제 후 재시작)
```bash
make re
```

---

## 웹사이트 및 관리자 패널 접속

### 웹사이트
브라우저에서 `https://injo.42.fr` 접속.

자체 서명 인증서(Self-signed SSL)를 사용하므로 브라우저에서 보안 경고가 표시됩니다. "고급" → "계속 진행"을 클릭하면 정상 접속됩니다.

### 관리자 패널
`https://injo.42.fr/wp-admin` 접속 후 WordPress 관리자 계정으로 로그인.

---

## 자격 증명(Credentials) 관리

비밀번호는 프로젝트 루트의 `secrets/` 폴더에 저장됩니다:

```
secrets/
├── db_root_pw.txt      # MariaDB root 비밀번호
├── db_pw.txt           # MariaDB 일반 유저 비밀번호
├── wp_admin_pw.txt     # WordPress 관리자 비밀번호
├── wp_user_pw.txt      # WordPress 일반 유저 비밀번호
└── ftp_pw.txt          # FTP 유저 비밀번호
```

비밀번호가 아닌 설정값(도메인명, 유저명, 이메일 등)은 `srcs/.env`에 저장됩니다.

두 파일 모두 `.gitignore`에 등록되어 Git에 업로드되지 않습니다.

---

## 서비스 정상 동작 확인

### 컨테이너 상태 확인
```bash
docker ps
```
`mariadb`, `wordpress`, `nginx`, `redis`, `adminer`, `netdata`, `static`, `ftp` 8개 컨테이너가 모두 `Up` 상태여야 합니다.

### 로그 확인
```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
docker logs redis
docker logs adminer
docker logs netdata
docker logs static
docker logs ftp
```

### 서비스별 접속 확인

```bash
# WordPress (HTTPS)
curl -k https://injo.42.fr

# 정적 웹사이트 (HTTP)
curl http://injo.42.fr

# Adminer
curl http://injo.42.fr:8080/adminer.php

# Redis 연결 상태
docker exec -it wordpress wp redis status --allow-root

# FTP 접속 테스트
ftp injo.42.fr
```

### MariaDB 직접 확인
```bash
docker exec -it mariadb mysql -u injo -p
# db_pw.txt의 비밀번호 입력 후
USE wordpress;
SHOW TABLES;
```
