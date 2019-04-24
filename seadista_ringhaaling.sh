#!/bin/bash
#Autor: Henri Paves 
#Versioon: 0.1
#Otstarve: Loeb Icecast2 seadistused ja kasutab neid muude vabavaralise veebringhäälingu komponentide seadistamiseks
#Juhend: sudo bash seadista_ringhaaling.sh

#Juurkasutaja õiguste kontroll https://wiki.itcollege.ee/index.php/Bash_n%C3%A4ide
# if [ $UID -ne 0 ]
# then
#     echo "$(basename $0) tuleb käivitada juurkasutaja õigustes"
#     exit 1
# fi

error_message () {
    echo "Skriptis tekkis viga ja see peatati." && exit 1
}

linux_username=dj
homedir=/home/$linux_username

user_confirm () {
    # ühe klahvivajutusega vastuvõtmine https://stackoverflow.com/a/1885534
    read -p "Teostan toimingu? [J/e] " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Jj]$ ]]
    then
        echo yes
    else 
        echo no
    fi
}

read_icecast_parameter () {
    # lookbehind kasutus: https://stackoverflow.com/a/23009124
    grep -Po "(?<=<$1>).*(?=<\/$1>)" konfid/icecast.xml
}

read_only_the_first_icecast_parameter_in_the_file () {
    grep -Pom1 "(?<=<$1>).*(?=<\/$1>)" konfid/icecast.xml
}

update_icecast_parameter () {
    sed s/'<'$1'>.*<\/'$1'>'/'<'$1'>'$2'<\/'$1'>'/ konfid/icecast.xml
}

update_icecast_default_values () {
    if [[ $icecast_location =~ Earth ]]
    then
        printf "\nSinu icecast teenuse asukohaks on märgitud Earth.\n"
        read -p "See on küll puhtkosmeetiline, kuid sisesta täpsem asukoht: " -r
        update_icecast_parameter location $REPLY
    fi
    if [[ $icecast_admin =~ icemaster@localhost ]]
    then
        printf "\nSinu icecast teenuse kontaktiks on märgitud icemaster@localhost.\n"
        read -p "Palun sisesta päris e-posti aadress: " -r
        update_icecast_parameter admin $REPLY
    fi
    if [[ $icecast_admin_user =~ admin ]]
    then
        printf "\nSinu icecast teenuse haldamise kasutajanimi on admin.\nNime samaks jätmine võib kaasa tuua turvariski.\n"
        read -p "Palun sisesta uus (ilma täpitähtedeta) kasutajanimi: " -r
        update_icecast_parameter admin-user $REPLY
    fi
}

read_icecast (){
    icecast_source_password=$(read_icecast_parameter source-password)
    icecast_relay_password=$(read_icecast_parameter relay-password)
    icecast_admin_password=$(read_icecast_parameter admin-password)
    icecast_hostname=$(read_icecast_parameter hostname)
    icecast_port=$(read_only_the_first_icecast_parameter_in_the_file port)
    icecast_admin_user=$(read_icecast_parameter admin-user)
    icecast_location=$(read_icecast_parameter location)
    icecast_admin=$(read_icecast_parameter admin)
}

print_icecast_data (){
    printf "Sinu icecast serveri aadress on: $icecast_hostname \n"
    printf "Sinu icecast serveri port on: $icecast_port \n"
    printf "Sinu icecast meediavoo ühendamise parool on: $icecast_source_password\n"
    printf "Sinu icecast relee seadistamise parool on: $icecast_relay_password\n"
    printf "Sinu icecast haldamise parool on: $icecast_admin_password \n"
    printf "Sinu icecast haldamise kasutajanimi on: $icecast_admin_user \n"
}

configure_icecast () {
    read_icecast
    printf "\nKontrolli üle, kas andmed klapivad!\n\n"
    print_icecast_data
}

configure_butt () {
    sed -i s/'address = .*'/'address = '$icecast_hostname/ konfid/.buttrc
    sed -i s/'port = .*'/'port = '$icecast_port/ konfid/.buttrc
    sed -i s/'password = .*'/'password = '$icecast_source_password/ konfid/.buttrc
}

read_icecast
update_icecast_default_values
configure_icecast
configure_butt

# mkdir -p $homedir/{helid/{muusika,teated},salvestused}