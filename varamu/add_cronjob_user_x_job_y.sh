#!/bin/bash
# Autor: Henri Paves 
# Versioon: 0.1
# Application: Appends cron jobs to the end of the current crontab in a scriptable way
# Manpage: bash add_cronjob_user_x_job_y.sh <user> "<*/5 * * * * /path/to/job -with args>"
# Adding cron jobs in a script: https://stackoverflow.com/a/9625233

if [[ ! $(crontab -u $1 -l | grep "$2") ]]
then
    echo -e "$(crontab -u $1 -l)\n$2" | crontab -u $1 -
    printf "The following cron job added to $1:\n$2\n"
else
    printf "Such cron job already exists!\n"
fi
