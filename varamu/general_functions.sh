#!/bin/bash
# Author: Henri Paves
# Version: 0.1
# Application: Repository for functions.
# Instructions: Not meant to be executed independently.
# How to reference: source general_functions.sh

# juurkasutaja õiguste kontroll https://wiki.itcollege.ee/index.php/Bash_n%C3%A4ide
check_for_root_privileges () {
    if [ $UID -ne 0 ]
    then
        printf "$(basename $0) tuleb käivitada juurkasutaja õigustes.\n"
        exit 1
    fi
}

check_for_root_privileges_absence () {
    if [ $UID -eq 0 ]
    then
        printf "$(basename $BASH_SOURCE) tuleb käivitada tavakasutaja õigustes.\n"
        exit 1
    fi
}

# reanumbri muutuja tekitamine https://stackoverflow.com/a/29081598
make_line_number_variable () {
    PS4=':$LINENO+'
}

exit_with_error () {
    # reanumbri väljastamiseks kasuta: exit_with_error ${LINENO}
    if [[ $1 ]]
    then
        printf "Skriptis tekkis viga real $1 ja see peatati.\n" && exit 1
    else
        printf "Skriptis tekkis viga ja see peatati.\n" && exit 1
    fi
}

error_issues_with_program () {
    printf "\n%s pole paigaldatud või selle seadistusfail pole kirjutatav/loetav.\n" "$1"
}

print_filename_without_path_and_extension () {
    # töödeldav fail ei tohi olla peidetud
    printf $1 | grep -Po "(?<=\/)\w*(?=\..*)"
}

# privaatse ipv4 aadressi filtreerimine https://unix.stackexchange.com/a/119272
private_ipv4 () {
    ip a | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
}

cp_if_not_there_already () {
    if [ ! -f $2 ]
    then
        cp $1 $2
    fi
}

mkdir_if_not_there_already () {
    if [ ! -d $1 ]
    then
        mkdir -p $1
    fi
}

touch_if_not_there_already () {
    if [ ! -f $1 ]
    then
        touch $1
    fi
}

reboot_prompt () {
    if whiptail --yesno --title "Confirm reboot" "Taaskäivitus on vajalik. Teeme kohe ära?\n" 8 60 3>&1 1>&2 2>&3
    then
        reboot
    fi
}
