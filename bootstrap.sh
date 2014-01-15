#!/usr/bin/env bash

#written to run on Ubuntu Server 12.04 as provisioned by TortoiseLabs

#add local user with ssh key so I can connect easily
read -s -p "Provide a password for the user account: " password
useradd -m -G sudo -p $password -s bash ephphatha
sudo -u ephphatha mkdir -m=700 /home/ephphatha/.ssh
sudo -u ephphatha touch /home/ephphatha/.ssh/authorized_keys
chmod 600 /home/ephphatha/.ssh/authorized_keys
curl -url http://lithium.thelettereph.com/id_rsa.pub -o ephphatha_id_rsa.pub
cat ephphatha_id_rsa.pub >> /home/ephphatha/.ssh/authorized_keys
rm ephphatha_id_rsa.pub

#get webserver shit
apt-get install -y python-software-properties
yes | add-apt-repository ppa:nginx/stable
apt-get update
apt-get install -y nginx
wget https://bitbucket.org/pypa/setuptools/raw/0.7.4/ez_setup.py -O - | python
wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py -O - | python
python get-pip.py
apt-get install -y gcc
apt-get install -y python-dev
pip install uwsgi
pip install django
apt-get install -y postgresql
apt-get install -y python-psycopg2
apt-get install -y python-markdown
apt-get install -y git
apt-get install -y vsftpd
echo "deb http://archive.ubuntu.com/ubuntu precise universe" >> /etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu precise-updates universe" >> /etc/apt/sources.list
apt-get update
apt-get install -y davfs2

#set up webserver user and grab files
read -s -p "Provide a password for the web user account: " password
useradd www
passwd --stdin www << $password
mkdir -m=775 /var/www
sudo -u www mkdir -m=775 /var/www/thelettereph
sudo -u www git clone https://github.com/Ephphatha/thelettereph.git /var/www/thelettereph
pip install -r requirements.txt
mv /var/www/thelettereph/thelettereph/local_settings.py.example /var/www/thelettereph/thelettereph/local_settings.py

#generate and save secret key
key = $(tr -dc "[:alnum:\!@#$%^&*\(-_=+\)]" < /dev/urandom | head -c 50)
sed -i "s/<<secret_key>>/$key/" "/var/www/thelettereph/thelettereph/local_settings.py"

#set up admins
read -p "Specify the recipients name for Django error emails: " admin_name
read -p "Provide the destination email address for Django error emails: " admin_email
sed -i "s/<<admin_name>>/$admin_name/" "/var/www/thelettereph/thelettereph/local_settings.py"
sed -i "s/<<admin_email>>/$admin_email/" "/var/www/thelettereph/thelettereph/local_settings.py"

#set up database account
read -s -p "Provide a password for the database user account: " password
sudo -u postgres psql -q -c "CREATE USER djangouser WITH ENCRYPTED PASSWORD '$password'"
sudo -u postgres psql -q -c "CREATE DATABASE thelettereph WITH OWNER = djangouser"
sed -i "s/<<db_pass>>/$password/" "/var/www/thelettereph/thelettereph/local_settings.py"

#set up WebDAV link for hosting static/media files
read -p "Provide the WebDAV url for the static/media file server: " webdav_url
read -p "Provide the WebDAV username: " webdav_user
read -p -s "Provide the WebDAV password: " webdav_pass
#two mount locations are used by default - common root is /var/www/thelettereph/thelettereph/
echo "/var/www/thelettereph/thelettereph/media $webdav_user $webdav_pass" >> /etc/davfs2/secrets
echo "/var/www/thelettereph/thelettereph/static $webdav_user $webdav_pass" >> /etc/davfs2/secrets
mkdir /var/www/thelettereph/thelettereph/media
mkdir /var/www/thelettereph/thelettereph/static
echo "https://cpsrv13.lithiumhosting.com:2078/media	/var/www/thelettereph/thelettereph/media	davfs	defaults,uid=www,gid=www	0	0" >> /etc/fstab
echo "https://cpsrv13.lithiumhosting.com:2078/static	/var/www/thelettereph/thelettereph/static	davfs	defaults,uid=www,gid=www	0	0" >> /etc/fstab
mount -t davfs $webdav_url/media /var/www/thelettereph/thelettereph/media
mount -t davfs $webdav_url/static /var/www/thelettereph/thelettereph/static

#ftp server configuration
rm /etc/vsftpd.conf
ln -s /var/www/thelettereph/vsftpd.conf /etc/vsftpd.conf
ln -s /var/www/thelettereph/vsftpd.user_list /etc/vsftpd.user_list
chown root /var/www/thelettereph/vsftpd.conf
chmod g+w /var/www/thelettereph/vsftpd.conf
restart vsftpd

#configure vassel
ln -s /var/www/thelettereph/thelettereph_nginx.conf /etc/nginx/sites-enabled/
ln -s /var/www/thelettereph/uwsgi.conf /etc/init/uwsgi.conf
mkdir /etc/uwsgi
chgrp www /etc/uwsgi
chmod g+w /etc/uwsgi
ln /var/www/thelettereph/thelettereph_uwsgi.ini /etc/uwsgi/thelettereph_uwsgi.ini

#start webserver
/etc/init.d/nginx start
service uwsgi start
