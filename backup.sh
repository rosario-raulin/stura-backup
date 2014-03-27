#!/bin/sh

BACKUP_DIR="backup"
ROOT_MAIL="rosario.raulin@stura-md.de"

log_error() {
  subject = $1
  message = $2
  echo ${message} | mail -s ${subject} ${ROOT_MAIL}
}

cd /

mkdir -p ${BACKUP_DIR}

if [ -d "$BACKUP_DIR" ]; then
  log_error "[Server Backup] Error creating backup dir" ""
fi
