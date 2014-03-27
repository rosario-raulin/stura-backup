#!/bin/bash

# configuration

BACKUP_ROOT="backup"
ROOT_MAIL="rosario.raulin@stura-md.de"
MYSQL_PASSWORD=""
declare -a DATABASES=("etherpad" "mail" "monatsreport" "ria" "roundcubemail" "wiki" "wordpress")

# helper functions

log_error() {
  subject=$1
  echo ${subject}
  exit 1
}

# +++ actual script starts here +++

# first thing is to change to the root directory
cd /

# there we create backup/MONTH-DAY-YEAR-$some-uuid to store everything
curr="$(date +'%m-%d-%Y')-$(uuidgen)"
backup_dir="${BACKUP_ROOT}/${curr}"

mkdir -p ${backup_dir}/www
mkdir -p ${backup_dir}/mail
mkdir -p ${backup_dir}/mysql

if [ ! -d ${backup_dir} ]; then
  log_error "[Server Backup] Error creating backup dir"
fi

cd ${backup_dir}

# first thing to backup is www content
cp -r /usr/share/nginx/www/* www/

if [ $? -ne 0 ] ; then
  log_error "[Server Backup] Temporary copying www files failed"
fi

# next up: databases

for i in "${DATABASES[@]}"
do
  mysqldump -u root -p${MYSQL_PASSWORD} ${i} | gzip > "mysql/${i}.gz"

  if [ $? -ne 0 ] ; then
    log_error "[Server Backup] Dumping mysql database ${i} failed"
  fi
done

# last but not least: mail

cp -r /home/vmail/mail/stura-md.de/* mail/

if [ $? -ne 0 ] ; then
  log_error "[Server Backup] Saving mail failed"
fi

tar c www/ mail/ mysql/ | gzip --fast > ${curr}.tar.gz
if [ $? -ne 0 ] ; then
  log_error "[Server Backup] 'tar'ing the backup failed"
fi

echo "success"
exit 0
