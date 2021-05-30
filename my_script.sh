#!/bin/bash

# Bash script for database convertion to utf8
DATABASE=bitnami_redmine

COLLATE=utf8mb4_unicode_ci
ROW_FORMAT=DYNAMIC
THREADS_RUNNING=200

TABLES=$(echo SHOW TABLES | mysql --host mariadb -u root -s $DATABASE)

echo "ALTER DATABASE $DATABASE CHARACTER SET utf8mb4 COLLATE $COLLATE" | mysql --host mariadb  -uroot $DATABASE

for TABLE in $TABLES ; do
  echo "ALTER TABLE $TABLE ROW_FORMAT=$ROW_FORMAT CHARACTER SET utf8mb4 COLLATE $COLLATE;" | mysql --host mariadb -uroot $DATABASE

 # ./pt-online-schema-change -uroot --alter "ROW_FORMAT=$ROW_FORMAT CHARACTER SET utf8mb4 COLLATE $COLLATE" D=$DATABASE,t=$TABLE --chunk-size=10k --critical-load Threads_running=$THREADS_RUNNING --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto --execute
done

echo "Finished the script"

