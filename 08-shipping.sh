#!/bin/bash

name=shipping
source ./common.sh
check_root
app_setup
java_setup
systemd_setup

dnf install mysql -y &>> $LOGS_FILE
VALIDATE $? "installing mysql-client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e "use cities" &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql  &>> $LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGS_FILE
    echo -e "$TIMESTAMP [INFO] schema Loaded"
else
    echo -e "$TIMESTAMP [INFO] schema already loaded ...$Y SKIPPING $N"
fi

system_restart
print_total_time