#!/usr/bin/env bash

read -s -p "Provide a password for the user account: " password
#add user
useradd -m -G sudo -p $password -s bash ephphatha
mkdir -m=700 /home/ephphatha/.ssh
touch /home/ephphatha/.ssh/authorized_keys
chmod 600 /home/ephphatha/.ssh/authorized_keys
chown -R ephphatha:ephphatha /home/ephphatha/.ssh
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

#configure webserver
ln -s /var/www/thelettereph/uwsgi.conf /etc/init/uwsgi.conf
ln /var/www/thelettereph/thelettereph_uwsgi.ini /etc/uwsgi/thelettereph_uwsgi.ini
