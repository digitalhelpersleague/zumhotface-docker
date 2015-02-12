#!/bin/bash

set -e

if [ "$1" = '/run.sh' ]; then
  rbenv exec bundle exec rake db:migrate db:seed
  /usr/sbin/nginx
  exec "$@"
fi

exec "$@"
