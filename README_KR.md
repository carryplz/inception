# Inception

*이 프로젝트는 injo가 42 커리큘럼의 일환으로 제작하였습니다.*

## 설명 (Description)

이 프로젝트는 Docker Compose를 사용하여 가상 머신(VM) 내에서 소규모 웹 인프라를 구축합니다. NGINX, WordPress(PHP-FPM 포함), MariaDB 각각이 독립된 컨테이너로 실행되며, 격리된 전용 Docker 네트워크를 통해 통신합니다.

단순히 컨테이너를 실행하는 것을 넘어, 직접 Dockerfile을 작성하여 이미지를 빌드하고 시스템 관리의 핵심 원칙(보안, 영속성, 네트워크 격리)을 적용하는 것이 목표입니다.

### 아키텍처 개요

```
       [ 외부 클라이언트 ]
               |
               | HTTPS (443 포트)
               v
    +------------------------------------------+
    |  Docker 네트워크: inception              |
    |                                          |
    |  [ NGINX ] --(FastCGI:9000)--> [ WordPress + PHP-FPM ]
    |  (TLSv1.2/1.3)                       |
    |                                    (3306 포트)
    |                                       |
    |                                       v
    |                                  [ MariaDB ]
    +------------------------------------------+
               |                         |
         [ Bind Mount ]           [ Bind Mount ]
    /home/injo/data/wordpress  /home/injo/data/mariadb
```

- **NGINX**: 유일한 외부 진입점. HTTPS(TLSv1.2/1.3)를 처리하고 PHP 요청을 FastCGI로 WordPress에 전달.
- **WordPress + PHP-FPM**: PHP를 처리하고 WordPress 애플리케이션을 실행. 내부 9000 포트로 대기.
- **MariaDB**: WordPress 데이터베이스를 저장. Docker 네트워크 내부에서만 접근 가능.

---

## 프로젝트 설명 (Project Description)

이 프로젝트는 커스텀 Dockerfile로 빌드한 세 가지 서비스를 Docker Compose로 오케스트레이션합니다. 아래는 주요 설계 선택과 개념 비교입니다.

### Virtual Machines vs Docker

| | 가상 머신 (VM) | Docker |
|---|---|---|
| 격리 수준 | 하드웨어 수준 완전 격리 (하이퍼바이저) | 프로세스 수준 격리 (커널 공유) |
| 크기 | GB 단위 (Guest OS 포함) | MB 단위 (호스트 커널 공유) |
| 시작 속도 | 분 단위 | 초 단위 |
| 사용 목적 | 강한 격리, 다른 OS 필요 시 | 가볍고 재현 가능한 앱 환경 |

VM은 컴퓨터 안에 완전히 새로운 컴퓨터를 만드는 것이고, Docker는 Linux 커널 기능(네임스페이스, cgroup)을 사용해 프로세스를 격리하는 것이다. Docker가 훨씬 가볍고 빠르지만, VM만큼의 보안 격리는 제공하지 않는다.

### Secrets vs 환경 변수 (Environment Variables)

| | 환경 변수 (.env) | Docker Secrets |
|---|---|---|
| 저장 방식 | 컨테이너 환경변수로 설정 | `/run/secrets/` 에 파일로 마운트 |
| docker inspect 노출 여부 | 평문으로 노출됨 | 노출되지 않음 |
| 적합한 데이터 | 비민감 설정값 (도메인명, 유저명) | 비밀번호, API 키 |

이 프로젝트에서는 비밀번호만 `secrets/` 텍스트 파일에 저장하고 `/run/secrets/`를 통해 런타임에 읽는다. 비밀번호가 아닌 값은 `.env`에 저장한다. 두 파일 모두 `.gitignore`에 등록되어 Git에 커밋되지 않는다.

### Docker 네트워크 vs 호스트 네트워크

| | Docker 네트워크 (bridge) | 호스트 네트워크 |
|---|---|---|
| 격리 | 호스트 네트워크와 격리됨 | 호스트 네트워크 스택을 직접 공유 |
| 컨테이너 간 통신 | 서비스 이름으로 DNS 해석 (`mariadb`, `wordpress`) | `localhost`로 통신 |
| 외부 노출 | 명시적으로 게시한 포트만 접근 가능 | 모든 포트가 호스트에 노출 |
| 이 프로젝트 | 사용 (`inception` bridge 네트워크) | 과제 규정상 금지 |

bridge 네트워크를 사용하면 MariaDB와 WordPress는 외부에서 직접 접근할 수 없고, NGINX의 443 포트만 외부에 노출된다.

### Docker Volumes vs Bind Mounts

| | Docker Volumes | Bind Mounts |
|---|---|---|
| 관리 주체 | Docker 엔진 | 호스트 파일 시스템 경로 |
| 이식성 | 높음 (Docker가 경로 관리) | 낮음 (특정 호스트 경로에 종속) |
| 호스트 직접 접근 | `docker volume` 명령 필요 | 호스트에서 바로 접근 가능 |
| 과제 요구사항 | — | `/home/login/data`에 데이터 저장 필수 |

이 프로젝트는 과제 요구사항(`/home/injo/data/`에 데이터 저장)을 만족하기 위해 bind mount 방식의 named volume을 사용한다. 컨테이너를 삭제해도 호스트의 데이터는 유지된다.

---

## 설치 및 실행 (Instructions)

### 사전 요구사항

- Debian이 설치된 가상 머신
- Docker, Docker Compose, make 설치 완료

### 설정 단계

1. 레포지토리 클론:
```bash
git clone <레포지토리_URL>
cd inception
```

2. `srcs/.env` 파일 생성:
```env
DOMAIN_NAME=injo.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=injo
WP_ADMIN_USER=in-jo
WP_ADMIN_EMAIL=in-jo@example.com
WP_USER_USER=injouser
WP_USER_EMAIL=injouser@example.com
```

3. secrets 파일 생성:
```bash
mkdir -p secrets
echo -n "root_비밀번호"  > secrets/db_root_pw.txt
echo -n "db_비밀번호"    > secrets/db_pw.txt
echo -n "admin_비밀번호" > secrets/wp_admin_pw.txt
echo -n "user_비밀번호"  > secrets/wp_user_pw.txt
```

4. 도메인 등록:
```bash
echo "127.0.0.1 injo.42.fr" | sudo tee -a /etc/hosts
```

5. 빌드 및 실행:
```bash
make
```

6. 브라우저에서 `https://injo.42.fr` 접속.

### Makefile 명령어

| 명령어 | 설명 |
|---|---|
| `make` | 이미지 빌드, 볼륨/네트워크 생성, 컨테이너 시작 |
| `make clean` | 컨테이너, 이미지, 볼륨 삭제 |
| `make fclean` | `clean` + 호스트의 `/home/injo/data` 데이터까지 삭제 |
| `make re` | 완전 초기화 후 처음부터 재빌드 |

---

## 포트 변경 방법

기본 설정에서는 443 포트만 외부에 노출됩니다. 보너스 서비스 등을 추가하거나 포트를 변경해야 하는 경우 아래를 참고하세요.

### NGINX 포트 변경 (예: 443 → 8443)

수정이 필요한 파일이 두 곳입니다.

**1. `srcs/docker-compose.yaml`**
```yaml
nginx:
    ports:
      - "8443:8443"   # 호스트포트:컨테이너포트
```

**2. `srcs/requirements/nginx/conf/nginx.conf`**
```nginx
server {
    listen 8443 ssl;
    listen [::]:8443 ssl;
    ...
}
```

변경 후 `make re`로 재빌드 필요.

### 보너스 서비스 포트 추가 (예: Adminer 8080 포트)

`srcs/docker-compose.yaml`에 서비스 추가 시 포트를 함께 선언합니다:
```yaml
adminer:
    ports:
      - "8080:8080"
```

> 주의: 과제 mandatory 파트에서는 NGINX 443 포트가 유일한 진입점이어야 합니다. 추가 포트는 보너스 서비스에서만 허용됩니다.

---

## 참고 자료 (Resources)

### 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Compose 레퍼런스](https://docs.docker.com/compose/)
- [NGINX 문서](https://nginx.org/en/docs/)
- [WordPress WP-CLI](https://wp-cli.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [PHP-FPM 설정](https://www.php.net/manual/en/install.fpm.configuration.php)
- [Docker secrets 문서](https://docs.docker.com/engine/swarm/secrets/)


### AI 활용 내역

이 프로젝트 진행 과정에서 AI(Claude, Gemini)를 다음과 같이 활용하였습니다:

- **Dockerfile 검토**: 문법 확인, 레이어 최적화, 디렉토리 권한 누락 확인.
- **스크립트 디버깅**: `init.sh`의 MariaDB 소켓 경로 불일치 및 shutdown 순서 문제 해결, `setup.sh`의 WP-CLI 플래그 및 `exec "$@"` 시그널 전달 확인.
- **설정 파일 검증**: `nginx.conf` FastCGI 설정 및 `www.conf`의 `clear_env` 동작 확인.
- **개념 학습**: PID 1 시그널 처리, 포그라운드/백그라운드 프로세스, Docker secrets 마운트, bridge 네트워크 DNS 해석 이해.
- **문서 작성**: README, USER_DOC.md, DEV_DOC.md 구조화 및 초안 작성.

AI가 생성한 모든 내용은 직접 검토하고 테스트한 후 프로젝트에 적용하였습니다.
