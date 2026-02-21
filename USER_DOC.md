# User Documentation

## Services Provided

This infrastructure runs three services:

| Service | Role | Access |
|---|---|---|
| NGINX | HTTPS entry point, reverse proxy | `https://injo.42.fr` |
| WordPress | Web CMS | `https://injo.42.fr` |
| MariaDB | Database | Internal only (not directly accessible) |

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
└── wp_user_pw.txt      # WordPress regular user password
```

Non-sensitive configuration values (domain name, usernames, email addresses) are stored in `srcs/.env`.

Both `secrets/` and `srcs/.env` are listed in `.gitignore` and are never uploaded to Git.

---

## Checking That Services Are Running

### Check container status
```bash
docker ps
```
All three containers — `mariadb`, `wordpress`, and `nginx` — should show status `Up`.

### Check logs
```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
```

### Test HTTPS access from the command line
```bash
curl -k https://injo.42.fr
```
If HTML is returned, the service is working correctly. The `-k` flag ignores the self-signed certificate warning.

### Connect to MariaDB directly
```bash
docker exec -it mariadb mysql -u injo -p
# Enter db_pw.txt password when prompted
USE wordpress;
SHOW TABLES;
```