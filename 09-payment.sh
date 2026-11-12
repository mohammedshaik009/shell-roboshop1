#!/bin/bash

name=payment
source ./common.sh
check_root
app_setup
python_setup
systemd_setup
system_restart
print_total_time