#!/usr/bin/env bash
#
#written to run on Ubuntu Server 12.04 as provisioned by TortoiseLabs
#
echo "Checking if the local user account already exists."
id -u ephphatha > /dev/null 2>&1
if [ $? != 0 ]; then
  #add local user with ssh key so I can connect easily
  echo "Local user account ephphatha does not already exist."
  read -s -p "Provide a password for the user account: " password
  useradd -m -G sudo -p $password -s bash ephphatha
else
  echo "Local user account ephphatha exists."
fi
#
echo "Checking if ssh public key has been added to authorized_keys file."
if [ ! -d /home/ephphatha/.ssh ]; then
  sudo -u ephphatha mkdir -m700 /home/ephphatha/.ssh
fi
#
if [ ! -f /home/ephphatha/.ssh/authorized_keys ]; then
  echo "authorized_keys file does not exist, creating and adding public key to file."
  sudo -u ephphatha touch /home/ephphatha/.ssh/authorized_keys
  chmod 600 /home/ephphatha/.ssh/authorized_keys
  curl --url http://lithium.thelettereph.com/id_rsa.pub -o ephphatha_id_rsa.pub
  cat ephphatha_id_rsa.pub >> /home/ephphatha/.ssh/authorized_keys
  rm ephphatha_id_rsa.pub
else
  echo "authorized_keys file exists, assuming the contents include the required public key"
fi
#
echo "Disabling password authentication for sshd"
sed -i "s/#\(PasswordAuthentication\) yes/\1 no/" /etc/ssh/sshd_config
service ssh restart
#
#get webserver shit
apt-get update
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
#
echo "Checking if web user account already exists."
id -u www > /dev/null 2>&1
if [ $? != 0 ]; then
  echo "Local user www doesn't exist, creating."
  #set up webserver user and grab files
  read -s -p "Provide a password for the web user account: " password
  useradd www
  echo $password > passwd --stdin www
fi
#
if [ ! -d /var/www ]; then
  mkdir -m775 /var/www
else
  chmod 775 /var/www
fi
#
if [ ! -e /var/www/thelettereph ]; then
  mkdir -m775 /var/www/thelettereph
  chown www /var/www/thelettereph
  apt-get install -y git
  sudo -u www git clone https://github.com/Ephphatha/thelettereph.git /var/www/thelettereph
fi
#
pip install -r /var/www/thelettereph/requirements.txt
#
if [ ! -f /var/www/thelettereph/thelettereph/local_settings.py ]; then
  mv /var/www/thelettereph/thelettereph/local_settings.py.example /var/www/thelettereph/thelettereph/local_settings.py
#
  if [ -d /media/sf_thelettereph ]; then
    echo "DEBUG = True
TEMPLATE_DEBUG = True
MEDIA_URL = '/media'
STATIC_URL = '/static'" >> /var/www/thelettereph/thelettereph/local_settings.py
  fi
  #generate and save secret key
  key=$(tr -dc "[:alnum:\!@#$%^&*\(-_=+\)]" < /dev/urandom | head -c 50)
  sed -i "s/<<secret_key>>/$key/" "/var/www/thelettereph/thelettereph/local_settings.py"
#
  #set up admins
  read -p "Specify the recipients name for Django error emails: " admin_name
  read -p "Provide the destination email address for Django error emails: " admin_email
  sed -i "s/<<admin_name>>/$admin_name/" "/var/www/thelettereph/thelettereph/local_settings.py"
  sed -i "s/<<admin_email>>/$admin_email/" "/var/www/thelettereph/thelettereph/local_settings.py"
#
  #set up database account
  read -s -p "Provide a password for the database user account: " password
  sed -i "s/<<db_pass>>/$password/" "/var/www/thelettereph/thelettereph/local_settings.py"
fi
#
passline=`grep 'PASSWORD' /var/www/thelettereph/thelettereph/local_settings.py`
password=`expr match "$passline" "[[:space:]]*'PASSWORD': '\(.*\)',"`
#
sudo -u postgres psql -q -c "CREATE USER djangouser WITH ENCRYPTED PASSWORD '$password'"
sudo -u postgres psql -q -c "CREATE DATABASE thelettereph WITH OWNER = djangouser"
#
if [ ! -d /media/sf_thelettereph ]; then
  apt-get install -y vsftpd
#
  #ftp server configuration
  rm /etc/vsftpd.conf
  ln -s /var/www/thelettereph/vsftpd.conf /etc/vsftpd.conf
  ln -s /var/www/thelettereph/vsftpd.user_list /etc/vsftpd.user_list
  chown root /var/www/thelettereph/vsftpd.conf
  chmod g+w /var/www/thelettereph/vsftpd.conf
  restart vsftpd
fi
#
#configure vassel
ln -s /var/www/thelettereph/thelettereph_nginx.conf /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
sed -i "/www-data;/www;/" /etc/nginx/nginx.conf
ln -s /var/www/thelettereph/uwsgi.conf /etc/init/uwsgi.conf
initctl reload-configuration
mkdir /etc/uwsgi
chgrp www /etc/uwsgi
chmod g+w /etc/uwsgi
ln /var/www/thelettereph/thelettereph_uwsgi.ini /etc/uwsgi/thelettereph_uwsgi.ini
#
mkdir /var/log/uwsgi
chown www /var/log/uwsgi
#
/var/www/thelettereph/manage.py syncdb
/var/www/thelettereph/manage.py schemamigration portfolio --initial
/var/www/thelettereph/manage.py schemamigration blog --initial
/var/www/thelettereph/manage.py migrate portfolio
/var/www/thelettereph/manage.py migrate blog
#start webserver
/etc/init.d/nginx start
start uwsgi
