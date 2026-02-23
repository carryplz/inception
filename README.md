*This project has been created as part of the 42 curriculum by injo.*

# Inception

## Description

This project sets up a small web infrastructure using Docker Compose inside a Virtual Machine. Each service runs in its own dedicated container and communicates over a private Docker network.

The mandatory part consists of NGINX, WordPress (with PHP-FPM), and MariaDB. The bonus part adds Redis cache, Adminer, Netdata, a static website, and an FTP server. All Docker images are built from custom Dockerfiles based on Debian Bookworm.

### Architecture Overview

```
       [ External Client ]
               |
         +-----+------+-------+----------+
         |     |      |       |          |
        443   80    8080   19999        21
         |     |      |       |          |
         v     v      v       v          v
       NGINX Static Adminer Netdata     FTP
         |
    (FastCGI:9000)
         v
  WordPress + PHP-FPM <--6379--> Redis
         |
       (3306)
         v
       MariaDB
```

**Mandatory services:**
- **NGINX**: The sole HTTPS entry point (TLSv1.2/1.3, port 443). Forwards PHP requests to WordPress via FastCGI.
- **WordPress + PHP-FPM**: Processes PHP and serves the WordPress application (port 9000, internal only).
- **MariaDB**: Stores the WordPress database (port 3306, internal only).

**Bonus services:**
- **Redis**: In-memory cache for WordPress. Reduces database queries via the `redis-cache` plugin.
- **Adminer**: Web-based database management UI at `http://injo.42.fr:8080/adminer.php`.
- **Netdata**: Real-time system and container monitoring dashboard at `http://injo.42.fr:19999`.
- **Static website**: A simple introduction page served via NGINX on port 80.
- **FTP server**: vsftpd container pointing to the WordPress volume. Access via `ftp injo.42.fr`.

---

## Project Description

This project uses Docker Compose to orchestrate three services built from custom Dockerfiles. Below are the key design choices and concept comparisons.

### Virtual Machines vs Docker

| | Virtual Machine | Docker |
|---|---|---|
| Isolation | Full hardware-level isolation (hypervisor) | Process-level isolation (shared kernel) |
| Size | GBs — includes a full guest OS | MBs — shares the host OS kernel |
| Startup time | Minutes | Seconds |
| Use case | Strong isolation, different OS required | Lightweight, reproducible app environments |

A VM creates an entirely separate computer inside your computer. Docker isolates processes using Linux kernel features (namespaces, cgroups) without duplicating the OS. Docker is far lighter and faster, but does not provide the same level of security isolation as a VM.

### Secrets vs Environment Variables

| | Environment Variables (.env) | Docker Secrets |
|---|---|---|
| Storage | Set as container environment variables | Mounted as files under `/run/secrets/` |
| Visibility via docker inspect | Exposed in plaintext | Not exposed |
| Suitable data | Non-sensitive config (domain name, usernames) | Passwords, API keys |

In this project, passwords are stored exclusively in `secrets/` text files and read at runtime via `/run/secrets/`. Non-sensitive values (domain name, DB name, usernames) are stored in `.env`. Both files are listed in `.gitignore` and must never be committed to Git.

### Docker Network vs Host Network

| | Docker Network (bridge) | Host Network |
|---|---|---|
| Isolation | Containers are isolated from the host network | Container shares the host's network stack directly |
| Inter-container communication | By service name (DNS resolution: `mariadb`, `wordpress`) | Via `localhost` |
| External exposure | Only explicitly published ports are accessible | All ports are exposed on the host |
| Used in this project | Yes — `inception` bridge network | Forbidden by subject rules |

Using a bridge network means MariaDB and WordPress are never directly reachable from outside — only NGINX exposes port 443 to the host.

### Docker Volumes vs Bind Mounts

| | Docker Volumes | Bind Mounts |
|---|---|---|
| Managed by | Docker engine | Host filesystem path |
| Portability | High — Docker manages the path | Low — tied to a specific host path |
| Direct host access | Requires `docker volume` commands | Directly accessible on the host |
| Subject requirement | — | Data must reside in `/home/login/data` |

This project uses named volumes configured as bind mounts (`driver: local`, `o: bind`) to satisfy the subject requirement of storing data under `/home/injo/data/`. This way, data persists on the host even after containers are removed.

---

## Instructions

### Prerequisites

- Virtual Machine running Debian
- Docker and Docker Compose installed
- `make` installed

### Setup

1. Clone the repository:
```bash
git clone <repository_url>
cd inception
```

2. Create `srcs/.env`:
```env
DOMAIN_NAME=injo.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=injo
WP_ADMIN_USER=in-jo
WP_ADMIN_EMAIL=in-jo@example.com
WP_USER_USER=injouser
WP_USER_EMAIL=injouser@example.com
FTP_USER=injo
```

3. Create secrets files:
```bash
mkdir -p secrets
echo -n "your_root_password"  > secrets/db_root_pw.txt
echo -n "your_db_password"    > secrets/db_pw.txt
echo -n "your_admin_password" > secrets/wp_admin_pw.txt
echo -n "your_user_password"  > secrets/wp_user_pw.txt
echo -n "your_ftp_password"   > secrets/ftp_pw.txt
```

4. Register the domain in `/etc/hosts`:
```bash
echo "127.0.0.1 injo.42.fr" | sudo tee -a /etc/hosts
```

5. Build and run:
```bash
make
```

6. Open a browser and go to `https://injo.42.fr`.

### Makefile Commands

| Command | Description |
|---|---|
| `make` | Build images, create volumes and network, start all containers |
| `make clean` | Stop and remove containers, images, and volumes |
| `make fclean` | `clean` + delete host data under `/home/injo/data` |
| `make re` | Full reset and rebuild from scratch |

---

## Resources

### Documentation
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress WP-CLI](https://wp-cli.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [Docker secrets documentation](https://docs.docker.com/engine/swarm/secrets/)
- [Redis cache WordPress plugin](https://wordpress.org/plugins/redis-cache/)
- [Adminer documentation](https://www.adminer.org/)
- [Netdata documentation](https://learn.netdata.cloud/)
- [vsftpd documentation](https://security.appspot.com/vsftpd.html)

### AI Usage

AI (Claude) was used in the following ways during this project:

- **Dockerfile review**: Checking syntax, layer optimization, and identifying missing directory permissions.
- **Script debugging**: Resolving issues in `init.sh` (MariaDB socket path mismatch, shutdown sequence with root password) and `setup.sh` (WP-CLI flags, `exec "$@"` signal forwarding).
- **Configuration validation**: Verifying `nginx.conf` FastCGI settings and `www.conf` `clear_env` behavior.
- **Concept explanation**: Understanding PID 1 signal handling, foreground vs background processes, Docker secrets mounting, and bridge network DNS resolution.
- **Documentation**: Structuring and drafting this README, USER_DOC.md, and DEV_DOC.md.

All AI-generated content was reviewed, tested, and fully understood before being applied to the project.
