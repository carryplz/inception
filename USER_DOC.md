# User Documentation

## Services Provided

This infrastructure runs the following services:

**Mandatory:**

| Service | Role | Access |
|---|---|---|
| NGINX | HTTPS entry point, reverse proxy | `https://injo.42.fr` |
| WordPress | Web CMS | `https://injo.42.fr/wp-admin` |
| MariaDB | Database | Internal only |

**Bonus:**

| Service | Role | Access |
|---|---|---|
| Redis | WordPress cache | Internal only |
| Adminer | Database management UI | `http://injo.42.fr:8080/adminer.php` |
| Netdata | System monitoring dashboard | `http://injo.42.fr:19999` |
| Static website | Introduction page | `http://injo.42.fr` |
| FTP server | File access to WordPress volume | `ftp injo.42.fr` (port 21) |

---

## Starting and Stopping the Project

### Start
```bash
make
```
On first run, Docker images are built and WordPress is installed automatically. This takes 1–2 minutes.

### Stop (data preserved)
```bash
docker-compose -f ./srcs/docker-compose.yaml down
```

### Full reset (deletes all data)
```bash
make re
```

---

## Accessing the Website and Administration Panel

### Website
Open a browser and go to `https://injo.42.fr`.

The project uses a self-signed SSL certificate, so the browser will show a security warning. Click "Advanced" and then "Proceed" to continue.

### Administration Panel
Go to `https://injo.42.fr/wp-admin` and log in with the WordPress administrator credentials.

---

## Credentials

Passwords are stored as plain text files in the `secrets/` folder at the project root:

```
secrets/
├── db_root_pw.txt      # MariaDB root password
├── db_pw.txt           # MariaDB user password
├── wp_admin_pw.txt     # WordPress administrator password
├── wp_user_pw.txt      # WordPress regular user password
└── ftp_pw.txt          # FTP user password
```

Non-sensitive configuration values (domain name, usernames, email addresses) are stored in `srcs/.env`.

Both `secrets/` and `srcs/.env` are listed in `.gitignore` and are never uploaded to Git.

---

## Checking That Services Are Running

### Check container status
```bash
docker ps
```
All 8 containers — `mariadb`, `wordpress`, `nginx`, `redis`, `adminer`, `netdata`, `static`, `ftp` — should show status `Up`.

### Check logs
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

### Service access checks

```bash
# WordPress (HTTPS)
curl -k https://injo.42.fr

# Static website (HTTP)
curl http://injo.42.fr

# Adminer
curl http://injo.42.fr:8080/adminer.php

# Redis connection status
docker exec -it wordpress wp redis status --allow-root

# FTP connection test
ftp injo.42.fr
```

### Connect to MariaDB directly
```bash
docker exec -it mariadb mysql -u injo -p
# Enter db_pw.txt password when prompted
USE wordpress;
SHOW TABLES;
```
