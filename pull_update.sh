#!/usr/bin/env bash
git pull
./manage.py collectstatic
touch /etc/uwsgi/thelettereph_uwsgi.ini
