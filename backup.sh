#!/bin/sh

BACKUP_DIR = "backup"
ROOT_MAIL = "rosario.raulin@stura-md.de"

BACKUP_DIR_ERROR = "The backup directory of stura-md.de couldn't be found!"

cd /

mkdir -p ${BACKUP_DIR}

if [true]; then
  mail -s "Error creating backup file" ${ROOT_MAIL} << ${BACKUP_DIR}
  . exit 1
fi
