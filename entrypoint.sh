#!/bin/bash

set -e

if [ "$1" = '/run.sh' ]; then

  rbenv exec bundle exec rake db:migrate db:seed

  exec "nginx && $@"
fi

exec "$@"
