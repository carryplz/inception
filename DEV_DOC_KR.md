# 개발자 문서 (Developer Documentation)

## 전체 흐름

```
VirtualBox 설치
      |
Debian ISO 다운로드 및 VM 생성
      |
Debian 설치
      |
make, Docker, Git 설치
      |
레포지토리 클론
      |
secrets 및 .env 파일 생성
      |
도메인 등록
      |
make 실행
      |
https://injo.42.fr 접속
```

---

## 1. VirtualBox 설치

1. https://www.virtualbox.org/wiki/Downloads 접속
2. 본인 OS에 맞는 버전 다운로드 (Windows / macOS / Linux)
3. 설치 파일 실행 후 기본 설정으로 설치

---

## 2. Debian ISO 다운로드

1. https://www.debian.org/download 접속
2. `debian-XX.X.X-amd64-netinst.iso` 다운로드
   - netinst = 네트워크 설치 버전 (용량 작음, 설치 중 패키지를 인터넷에서 받아옴)

---

## 3. VirtualBox에서 VM 생성

1. VirtualBox 실행 → "새로 만들기(New)" 클릭
2. 다음과 같이 설정:
   - 이름: `inception` (자유롭게)
   - 종류(Type): `Linux`
   - 버전(Version): `Debian (64-bit)`
3. 메모리: **2048MB 이상** 권장
4. 하드 디스크: "새 가상 디스크 만들기" → VDI → 동적 할당 → **20GB 이상**
5. VM 생성 후 "설정(Settings)" → "저장소(Storage)" → 광학 드라이브에 다운로드한 Debian ISO 연결
6. "네트워크(Network)" → 어댑터 1: NAT (기본값 유지)

---

## 4. Debian 설치

1. VM 시작 → `Install` 선택 (텍스트 기반 설치)
2. 언어: English 권장 (에러 메시지 검색이 쉬움)
3. 지역, 키보드 설정 후 진행
4. 호스트명(hostname): 자유롭게 입력 (예: `inception`)
5. root 비밀번호 설정
6. 일반 유저 생성 (예: `injo`)
7. 파티션: "Guided - use entire disk" 선택 → 기본 설정으로 진행
8. 패키지 선택 화면에서 **SSH server**와 **standard system utilities**만 선택 (나머지 해제)
9. GRUB 부트로더: Yes → `/dev/sda` 선택
10. 설치 완료 후 재부팅

---

## 5. sudo 설정

일반 유저에게 sudo 권한을 부여합니다.

```bash
# root로 전환
su -

# sudo 설치
apt-get install -y sudo

# 유저에게 sudo 권한 부여 (injo 자리에 본인 유저명 입력)
usermod -aG sudo injo

# 재부팅 후 적용됨
reboot
```

재부팅 후 확인:
```bash
sudo apt-get update   # 에러 없이 실행되면 sudo 설정 완료
```

---

## 6. make, Docker, Git 설치

```bash
# make와 git 설치
sudo apt-get install -y make git

# Docker 설치를 위한 의존성 패키지 설치
sudo apt-get install -y ca-certificates curl gnupg

# Docker 공식 GPG 키 추가
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Docker 레포지토리 추가
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 및 Docker Compose 설치
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

# 현재 유저를 docker 그룹에 추가 (sudo 없이 docker 명령 사용 가능)
sudo usermod -aG docker $USER

# 재로그인 후 설치 확인
docker --version
docker-compose --version
```

---

## 7. 레포지토리 클론

```bash
# Git 유저 설정
git config --global user.name "injo"
git config --global user.email "injo@student.42seoul.kr"

# 레포지토리 클론
git clone <레포지토리_URL>
cd inception
```

---

## 8. secrets 파일 생성

비밀번호 파일은 Git에 포함되지 않으므로 직접 생성해야 합니다.

```bash
mkdir -p secrets

# 반드시 echo -n 사용 (없으면 비밀번호 끝에 줄바꿈 문자가 붙어서 인증 실패)
echo -n "root_비밀번호"  > secrets/db_root_pw.txt
echo -n "db_비밀번호"    > secrets/db_pw.txt
echo -n "admin_비밀번호" > secrets/wp_admin_pw.txt
echo -n "user_비밀번호"  > secrets/wp_user_pw.txt
```

파일 확인 (줄바꿈 없이 비밀번호만 출력되어야 함):
```bash
cat secrets/db_root_pw.txt
```

---

## 9. .env 파일 생성

```bash
cat > srcs/.env << EOF
DOMAIN_NAME=injo.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=injo
WP_ADMIN_USER=in-jo
WP_ADMIN_EMAIL=in-jo@example.com
WP_USER_USER=injouser
WP_USER_EMAIL=injouser@example.com
EOF
```

주의: `WP_ADMIN_USER`에 `admin`, `administrator` 등이 포함되면 과제 규정 위반입니다.

---

## 10. 도메인 등록

`injo.42.fr`은 실제 인터넷에 등록된 도메인이 아니므로, VM 내부에서 직접 IP를 지정해야 합니다.

```bash
echo "127.0.0.1 injo.42.fr" | sudo tee -a /etc/hosts

# 확인
grep injo /etc/hosts
```

---

## 11. 실행

```bash
make
```

최초 실행 시 이미지 빌드와 WordPress 설치가 진행되어 1~2분 정도 소요됩니다.

완료 후 브라우저에서 `https://injo.42.fr` 접속. 자체 서명 인증서 경고가 뜨면 "고급" → "계속 진행" 클릭.

---

## 컨테이너 관리 명령어

```bash
# 상태 확인
docker ps

# 로그 확인
docker logs mariadb
docker logs wordpress
docker logs nginx
docker logs -f mariadb       # 실시간 로그

# 컨테이너 내부 접속
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash

# MariaDB 직접 접속
docker exec -it mariadb mysql -u root -p
docker exec -it mariadb mysql -u injo -p wordpress

# 중지 (데이터 유지)
docker-compose -f ./srcs/docker-compose.yaml down

# 이미지/볼륨까지 삭제
make clean

# 데이터까지 완전 삭제 후 재시작
make re
```

---

## 데이터 저장 위치 및 영속성

볼륨은 bind mount 방식으로 호스트에 직접 저장됩니다:

| 데이터 | 컨테이너 내부 경로 | 호스트 경로 |
|---|---|---|
| WordPress 파일 | `/var/www/html` | `/home/injo/data/wordpress` |
| MariaDB 데이터 | `/var/lib/mysql` | `/home/injo/data/mariadb` |

`make clean`으로 컨테이너를 삭제해도 `/home/injo/data/`의 데이터는 유지됩니다. `make fclean`을 실행해야 데이터까지 삭제됩니다.

---

## 트러블슈팅

### MariaDB가 계속 재시작되는 경우
```bash
docker logs mariadb
```
`Access denied` 에러 → `secrets/` 파일에 줄바꿈이 포함됐을 가능성. `echo -n` 사용 여부 확인.

### WordPress가 MariaDB 대기 중인 경우
MariaDB 초기화가 끝날 때까지 정상적으로 대기하는 동작입니다. `docker logs mariadb`에서 `MariaDB is ready.`가 출력되면 자동으로 진행됩니다.

### 볼륨 권한 오류
```bash
make fclean
make
```

### https://injo.42.fr 접속 불가
```bash
grep injo /etc/hosts   # 도메인 등록 확인
docker ps              # 컨테이너 상태 확인
```
