#!/bin/bash

LOGS_FOLDER=/var/log/roboshop
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

check_root(){
USERID=$(id -u)
#check root user or not
if [ $USERID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $R please run this script with root access" | tee -a $LOGS_FILE
    exit 1
fi
}

echo -e "$TIMESTAMP [INFO] script started"

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 is ....$R FAILED $N" | tee -a $LOGS_FILE
    else
        echo -e "$TIMESTAMP [INFO] $2 is ...$G success $N" | tee -a $LOGS_FILE
    fi
}

app_setup(){
    id roboshop &>> $LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        echo "adding system user"
    else
        echo -e "system user already created...$Y skipping $N"
    fi

rm -rf /app &>> $LOGS_FILE
VALIDATE $? "removing app directory"

mkdir -p /app &>> $LOGS_FILE
VALIDATE $? "adding app directory"

rm -rf /tmp/$name.zip &>> $LOGS_FILE
VALIDATE $? "removing existed code"

curl -o /tmp/$name.zip https://roboshop-artifacts.s3.amazonaws.com/$name-v3.zip  &>> $LOGS_FILE
cd /app 
unzip /tmp/$name.zip &>> $LOGS_FILE
VALIDATE $? "download the code and extracted"
}

systemd_setup(){
cp $SCRIPT_DIR/$name.service /etc/systemd/system/$name.service &>> $LOGS_FILE
VALIDATE $? "adding systemd service"
systemctl daemon-reload &>> $LOGS_FILE
systemctl --now enable $name &>> $LOGS_FILE
VALIDATE $? "enable and start"
}

nodejs_setup(){
dnf module disable nodejs -y &>> $LOGS_FILE
dnf module enable nodejs:20 -y &>> $LOGS_FILE
dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "installing nodejs"
npm install  &>> $LOGS_FILE
VALIDATE $? "installing dependencies" 
}

print_total_time(){
    echo -e "$TIMESTAMP [INFO] script executed in $SECONDS seconds"
}

