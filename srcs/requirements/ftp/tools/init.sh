#!/bin/bash

set -e

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

# FTP 유저 생성
useradd -m -d /var/www/html ${FTP_USER}
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

# WordPress 볼륨 접근 권한
chown -R ${FTP_USER}:${FTP_USER} /var/www/html

# vsftpd 설정
cat > /etc/vsftpd.conf << EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
chroot_local_user=YES
allow_writeable_chroot=YES
local_root=/var/www/html
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
EOF

exec vsftpd /etc/vsftpd.conf