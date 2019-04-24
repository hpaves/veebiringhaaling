#!/bin/bash
#Autor: Henri Paves 
#Versioon: 0.1
#Otstarve: Loeb Icecast2 seadistused ja kasutab neid muude vabavaralise veebringhäälingu komponentide seadistamiseks
#Juhend: sudo bash seadista_ringhaaling.sh

#Juurkasutaja õiguste kontroll https://wiki.itcollege.ee/index.php/Bash_n%C3%A4ide
# if [ $UID -ne 0 ]
# then
#     printf "$(basename $0) tuleb käivitada juurkasutaja õigustes.\n"
#     exit 1
# fi

error_message () {
    printf "Skriptis tekkis viga ja see peatati.\n" && exit 1
}

linux_username=dj
homedir=/home/$linux_username
icecast_conf_file="konfid/icecast.xml"

user_confirm () {
    # ühe klahvivajutusega vastuvõtmine https://stackoverflow.com/a/1885534
    read -p "Teostan toimingu? [J/e] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]]
    then
        echo yes
    else 
        echo no
    fi
}

read_icecast_parameter () {
    # lookbehind kasutus: https://stackoverflow.com/a/23009124
    grep -Po "(?<=<$1>).*(?=<\/$1>)" $icecast_conf_file
}

read_only_the_first_icecast_parameter_in_the_file () {
    grep -Pom1 "(?<=<$1>).*(?=<\/$1>)" $icecast_conf_file
}

update_icecast_parameter () {
    sed s/'<'$1'>.*<\/'$1'>'/'<'$1'>'$2'<\/'$1'>'/ $icecast_conf_file
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

read_icecast_data (){
    icecast_source_password=$(read_icecast_parameter source-password)
    icecast_relay_password=$(read_icecast_parameter relay-password)
    icecast_admin_password=$(read_icecast_parameter admin-password)
    icecast_hostname=$(read_icecast_parameter hostname)
    icecast_port=$(read_only_the_first_icecast_parameter_in_the_file port)
    icecast_admin_user=$(read_icecast_parameter admin-user)
    icecast_location=$(read_icecast_parameter location)
    icecast_admin=$(read_icecast_parameter admin)
}

# privaatse ipv4 filtreerimine https://unix.stackexchange.com/a/119272
private_ipv4 () {
ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
}

print_icecast_data (){
    printf "Sinu icecast serveri aadress samast arvutist ühendamiseks on: $icecast_hostname\n"
    printf "Sinu icecast serveri aadress kohalikust võrgust ühendamiseks on: $private_ipv4\n"
    printf "Sinu icecast serveri port on: $icecast_port\n"
    printf "Sinu icecast meediavoo ühendamise parool on: $icecast_source_password\n"
    printf "Sinu icecast relee seadistamise parool on: $icecast_relay_password\n"
    printf "Sinu icecast haldamise parool on: $icecast_admin_password \n"
    printf "Sinu icecast haldamise kasutajanimi on: $icecast_admin_user \n"
}

verify_icecast_conf () {
    read_icecast
    printf "\nKontrolli üle, kas andmed klapivad!\n\n"
    print_icecast_data
}

configure_butt () {
    buttrc_location="konfid/.buttrc"
    sed -i s/'address = .*'/'address = '$icecast_hostname/ $buttrc_location
    sed -i s/'port = .*'/'port = '$icecast_port/ $buttrc_location
    sed -i s/'password = .*'/'password = '$icecast_source_password/ $buttrc_location
    sed -i s/'folder = .*'/'folder = /home/'$linux_username'/salvestused/'/ $buttrc_location
}

configure_liquidsoap () {
    liquidsoap_conf_file="konfid/raadio2.liq"
    liquidconf_name_stripped=$(echo $liquidsoap_conf_file | grep -Po "(?<=\/)\w*(?=\.liq)")
    sed -i s/'set("log.file.path",.*'/'set("log.file.path","\/tmp\/'$liquidconf_name_stripped'.log")'/ $liquidsoap_conf_file
    sed -i s/'default = single.*'/'default = single("\/home\/'$linux_username'\/helid\/vaikimisi.ogg")'/ $liquidsoap_conf_file
    sed -i s/'music   = playlist.*'/'music   = playlist("\/home\/'$linux_username'\/helid\/muusika.pls")'/ $liquidsoap_conf_file
    sed -i s/'jingles = playlist.*'/'jingles = playlist("\/home\/'$linux_username'\/helid\/teated.pls")'/ $liquidsoap_conf_file
    sed -i s/'\[input.http.*'/'\[input.http("http:\/\/'$icecast_hostname':'$icecast_port'\/otse-eeter.ogg"),'/ $liquidsoap_conf_file
    sed -i s/'host=.*'/'host="'$icecast_hostname'",port='$icecast_port',password="'$icecast_source_password'",'/ $liquidsoap_conf_file
}

read_icecast_data
update_icecast_default_values
verify_icecast_conf
configure_butt
configure_liquidsoap


# mkdir -p $homedir/{helid/{muusika,teated},salvestused}
# groupadd veebiringhaaling
# usermod -a -G veebiringhaaling $linux_username
# usermod -a -G veebiringhaaling icecast2
# usermod -a -G veebiringhaaling liquidsoap
# chown -R :veebiringhaaling $homedir/{helid,salvestused}
# chmod -R 750 $homedir/helid
# chmod -R 754 $homedir/salvestused

# meelespead: ip staatiliseks, lõpus restart (gruppidesse lisamise aktiveerumiseks jms)