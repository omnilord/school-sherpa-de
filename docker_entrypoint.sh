#!/bin/sh
set -e

if [ -f /usr/src/app/tmp/pids/server.pid ]; then
  rm /usr/src/app/tmp/pids/server.pid
fi

until PGPASSWORD="sherpa" psql -h "postgresql" -U "sherpa" --port=5432 -d "sherpa_development" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 3
done

echo
echo "*******************"
echo "SETTING UP DATABASE (ENTRY)"
echo "*******************"
echo

bundle exec rails db:migrate

dockerize -wait tcp://postgresql:5432 -timeout 1s "$@"
