#!/bin/bash
#Autor: Henri Paves 
#Versioon: 0.1
#Otstarve: Loeb Icecast2 seadistused ja kasutab neid muude vabavaralise veebringhäälingu komponentide seadistamiseks
#Juhend: sudo bash seadista_ringhaaling.sh

#Juurkasutaja õiguste kontroll https://wiki.itcollege.ee/index.php/Bash_n%C3%A4ide
if [ $UID -ne 0 ]
then
    echo "$(basename $0) tuleb käivitada juurkasutaja õigustes"
    exit 1
fi

error_message () {
    echo "Skriptis tekkis viga ja see peatati." && exit 1
}

user_confirm () {
    # https://stackoverflow.com/a/1885534
    read -p "Teostan toimingu? [J/e] " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Jj]$ ]]
    then
        echo yes
    else 
        echo no
    fi
}

read_icecast2 (){
    echo "sinu paroolid on:"
    # https://stackoverflow.com/a/23009124
    grep -Po "(?<=<source-password>).*(?=<\/source-password>)" /etc/icecast2/icecast.xml
    grep -Po "(?<=<relay-password>).*(?=<\/relay-password>)" /etc/icecast2/icecast.xml
    grep -Po "(?<=<admin-password>).*(?=<\/admin-password>)" /etc/icecast2/icecast.xml

    echo "sinu serveri aadress on:"
    grep -Po "(?<=<hostname>).*(?=<\/hostname>)" /etc/icecast2/icecast.xml

    echo "sinu kasutajanimi on:"
    grep -Po "(?<=<admin-user>).*(?=<\/admin-user>)" /etc/icecast2/icecast.xml
}