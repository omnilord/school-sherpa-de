#!/bin/sh

if [[ ! -e $(which ogr2ogr) ]]; then
  (>&2 echo "ogr2ogr utility was not found and must be installed.")
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DIR="$(realpath ${SCRIPT_DIR}/../db/seed_files)"
REGEX_NAME=".+/Grade_([A-Za-z]+)\.geojson$"
DATABASE_NAME="${DATABASE_NAME:-sherpa_${RAILS_ENV:-development}}"
DATABASE_USER="${DATABASE_USER:-$(whoami)}"
DATABASE_TABLE="raw_feeder_patterns_by_grades"

for filepath in ${DIR}/Grade_*.geojson; do
  if [[ -e $filepath && $filepath =~ $REGEX_NAME ]]; then
    GRADE=$(echo ${BASH_REMATCH[1]} | tr '[:upper:]' '[:lower:]')

    echo Importing Grade ${GRADE}

    `ogr2ogr -f "PostgreSQL" PG:"dbname=${DATABASE_NAME} user=${DATABASE_USER}" "${filepath}" -nln ${DATABASE_TABLE}`

    psql -U $DATABASE_USER -d $DATABASE_NAME \
      -c "UPDATE ${DATABASE_TABLE} SET grade_level='${GRADE}' WHERE grade_level IS NULL;"
  fi
done
