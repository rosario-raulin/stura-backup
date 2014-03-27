#!/bin/sh

# configuration

BACKUP_ROOT="backup"
ROOT_MAIL="rosario.raulin@stura-md.de"
MYSQL_PASSWORD=""
declare -a DATABASES=("etherpad" "mail" "monatsreport" "ria" "roundcubemail" "wiki" "wordpress")

# helper functions

log_error() {
  subject=$1
  echo "" | mail -s ${subject} ${ROOT_MAIL}
  exit 1
}

# +++ actual script starts here +++

# first thing is to change to the root directory
cd /

# there we create backup/MONTH-DAY-YEAR-$some-uuid to store everything
curr="$(date +'%m-%d-%Y')-$(uuidgen)"
backup_dir="${BACKUP_ROOT}/${curr}/www"

mkdir -p ${backup_dir}

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

mkdir mail
cp -r /home/vmail/mail/stura-md.de/* mail/

if [ $? -ne 0 ] ; then
  log_error "[Server Backup] Saving mail failed"
fi

tar cjf "${curr}.tar.bz2" www/ mail/ mysql/
if [ $? -ne 0 ] ; then
  log_error "[Server Backup] 'tar'ing the backup failed"
fi

echo "success"
exit 0
