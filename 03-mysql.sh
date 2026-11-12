#!/bin/bash

source ./common.sh
check_root

dnf install mysql-server -y &>> $LOGS_FILE
VALIDATE $? "installing mysql-server"

systemctl --now enable mysqld &>> $LOGS_FILE
VALIDATE $? "enable and start"

mysql_secure_installation --set-root-pass
VALIDATE $? "setting up root password"

print_total_time