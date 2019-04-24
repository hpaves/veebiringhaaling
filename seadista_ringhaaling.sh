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
    # https://stackoverflow.com/a/23009124
    icecast_source_password=$(grep -Po "(?<=<source-password>).*(?=<\/source-password>)" konfid/icecast.xml)
    icecast_relay_password=$(grep -Po "(?<=<relay-password>).*(?=<\/relay-password>)" konfid/icecast.xml)
    icecast_admin_password=$(grep -Po "(?<=<admin-password>).*(?=<\/admin-password>)" konfid/icecast.xml)
    icecast_hostname=$(grep -Po "(?<=<hostname>).*(?=<\/hostname>)" konfid/icecast.xml)
    icecast_port=$(grep -Pom1 "(?<=<port>).*(?=<\/port>)" konfid/icecast.xml)
    icecast_admin_user=$(grep -Po "(?<=<admin-user>).*(?=<\/admin-user>)" konfid/icecast.xml)
}

read_butt () {
    grep -Po "(?<=password = ).*$" konfid/.buttrc
}

read_icecast2
read_butt
echo $icecast_source_password