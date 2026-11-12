#!/bin/bash

name=catalogue
source ./common.sh
check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
VALIDATE $? "adding mongo.repo"

dnf install mongodb-mongosh -y &>> $LOGS_FILE
VALIDATE $? "installing MongoDB"

    INDEX=$(mongosh --host mongodb.nazeer.shop --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
    if [ $INDEX -lt 0 ]; then
        mongosh --host mongodb.nazeer.shop < /app/db/master-data.js &>> $LOGS_FILE
        echo -e "$TIMESTAMP [INFO] Load products"
    else
        echo -e "products already loaded ...$Y skipping $N"
    fi

system_restart
print_total_time