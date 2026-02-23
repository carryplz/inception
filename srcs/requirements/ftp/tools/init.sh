#!/bin/bash

set -e

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

# 디렉토리 생성
mkdir -p /var/run/vsftpd/empty

# 유저가 없을 때만 생성
if ! id "${FTP_USER}" &>/dev/null; then
    useradd -m -d /var/www/html "${FTP_USER}"
fi

echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
chown -R ${FTP_USER}:${FTP_USER} /var/www/html

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
secure_chroot_dir=/var/run/vsftpd/empty
EOF

exec vsftpd /etc/vsftpd.conf