# Developer Documentation

## Overview

```
Install VirtualBox
      |
Download Debian ISO and create VM
      |
Install Debian
      |
Install make, Docker, Git
      |
Clone repository
      |
Create secrets and .env files
      |
Register domain in /etc/hosts
      |
Run make
      |
Open https://injo.42.fr
```

---

## 1. Install VirtualBox

1. Go to https://www.virtualbox.org/wiki/Downloads
2. Download the installer for your host OS (Windows, macOS, or Linux)
3. Run the installer with default settings

---

## 2. Download Debian ISO

1. Go to https://www.debian.org/download
2. Download `debian-XX.X.X-amd64-netinst.iso` (the netinst image is small and installs packages over the network)

---

## 3. Create a VM in VirtualBox

1. Open VirtualBox and click "New"
2. Set the following:
   - Name: `inception` (or any name)
   - Type: `Linux`
   - Version: `Debian (64-bit)`
3. Memory: 2048 MB or more (recommended)
4. Hard disk: Create a new virtual disk — VDI format, dynamically allocated, 20 GB or more
5. After creating the VM, go to Settings > Storage > attach the downloaded Debian ISO to the optical drive
6. Network: Adapter 1 set to NAT (default)

---

## 4. Install Debian

1. Start the VM and select `Install` (text-based installer)
2. Language: English (recommended — error messages are easier to search online)
3. Follow prompts to set region, keyboard layout, and hostname (e.g. `inception`)
4. Set a root password and create a regular user (e.g. `injo`)
5. Partitioning: select "Guided - use entire disk" and proceed with defaults
6. On the software selection screen, select only "SSH server" and "standard system utilities" — deselect everything else
7. Install GRUB bootloader: Yes, on `/dev/sda`
8. Reboot after installation completes

---

## 5. Configure sudo

After logging in as the regular user:

```bash
# Switch to root
su -

# Install sudo
apt-get install -y sudo

# Grant sudo privileges to your user (replace injo with your username)
usermod -aG sudo injo

# Exit root
exit

# Log out and log back in for the change to take effect
logout
```

Verify sudo is working:
```bash
sudo apt-get update
```

---

## 6. Install make, Docker, and Git

```bash
# Install make and git
sudo apt-get install -y make git

# Install dependencies for Docker
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker and Docker Compose
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

# Add your user to the docker group (so you can run docker without sudo)
sudo usermod -aG docker $USER

# Log out and log back in, then verify installation
docker --version
docker-compose --version
```

---

## 7. Clone the Repository

```bash
# Configure Git identity
git config --global user.name "injo"
git config --global user.email "injo@student.42seoul.kr"

# Clone the project
git clone <repository_url>
cd inception
```

---

## 8. Create secrets Files

Password files are not included in the repository and must be created manually.

```bash
mkdir -p secrets

# Use echo -n to avoid a trailing newline — without it, passwords will fail silently
echo -n "your_root_password"  > secrets/db_root_pw.txt
echo -n "your_db_password"    > secrets/db_pw.txt
echo -n "your_admin_password" > secrets/wp_admin_pw.txt
echo -n "your_user_password"  > secrets/wp_user_pw.txt
echo -n "your_ftp_password"   > secrets/ftp_pw.txt
```

Verify the files contain only the password (no trailing newline):
```bash
cat secrets/db_root_pw.txt
```

---

## 9. Create the .env File

```bash
cat > srcs/.env << EOF
DOMAIN_NAME=injo.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=injo
WP_ADMIN_USER=in-jo
WP_ADMIN_EMAIL=in-jo@example.com
WP_USER_USER=injouser
WP_USER_EMAIL=injouser@example.com
FTP_USER=injo
EOF
```

Note: `WP_ADMIN_USER` must not contain `admin` or `administrator` in any form — this is a subject requirement.

---

## 10. Register the Domain

```bash
echo "127.0.0.1 injo.42.fr" | sudo tee -a /etc/hosts

# Verify
grep injo /etc/hosts
```

## 10-1. Open Firewall Ports (Bonus services)

```bash
sudo ufw allow 80        # Static website
sudo ufw allow 8080      # Adminer
sudo ufw allow 19999     # Netdata
sudo ufw allow 21        # FTP
sudo ufw allow 21100:21110/tcp  # FTP passive mode
sudo ufw enable
```

---

## 11. Build and Run

```bash
make
```

On first run, this will:
1. Create `/home/injo/data/wordpress` and `/home/injo/data/mariadb` on the host
2. Build Docker images for mariadb, wordpress, and nginx
3. Start all containers in the background

The first run takes 1–2 minutes. Open `https://injo.42.fr` in a browser when complete. Accept the self-signed certificate warning to proceed.

---

## Container Management Commands

```bash
# Check container status
docker ps

# View logs
docker logs mariadb
docker logs wordpress
docker logs nginx
docker logs redis
docker logs adminer
docker logs netdata
docker logs static
docker logs ftp
docker logs -f mariadb       # Follow logs in real time

# Open a shell inside a container
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash
docker exec -it redis bash
docker exec -it ftp bash

# Connect to MariaDB directly
docker exec -it mariadb mysql -u root -p
docker exec -it mariadb mysql -u injo -p wordpress

# Check Redis connection status
docker exec -it redis redis-cli ping
docker exec -it wordpress wp redis status --allow-root

# FTP connection test
ftp injo.42.fr

# Stop containers (data preserved)
docker-compose -f ./srcs/docker-compose.yaml down

# Remove containers, images, and volumes
make clean

# Full reset including host data
make fclean

# Full reset and rebuild
make re
```

---

## Data Storage and Persistence

Data is stored on the host using bind mounts:

| Data | Container path | Host path |
|---|---|---|
| WordPress files | `/var/www/html` | `/home/injo/data/wordpress` |
| MariaDB data | `/var/lib/mysql` | `/home/injo/data/mariadb` |

Running `make clean` removes containers but leaves the data directories intact. Running `make fclean` deletes the data directories as well.

---

## Troubleshooting

### MariaDB keeps restarting

```bash
docker logs mariadb
```

If you see `Access denied`, a trailing newline in the secrets files is the most likely cause. Recreate the files using `echo -n`.

### WordPress is stuck waiting for MariaDB

This is expected behavior during the first startup. MariaDB runs its initialization routine before accepting connections. Once `MariaDB is ready.` appears in the logs, WordPress will proceed automatically.

### Volume permission error

```bash
make fclean
make
```

### Cannot access https://injo.42.fr

```bash
grep injo /etc/hosts    # Verify domain is registered
docker ps               # Verify all containers are running
```
