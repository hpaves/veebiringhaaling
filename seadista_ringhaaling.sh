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

# reanumbri muutuja tekitamine https://stackoverflow.com/a/29081598
PS4=':$LINENO+'

error_message () {
    # reanumbri väljastamiseks anna parameetriks: ${LINENO}
    if [[ $1 ]]
    then
        printf "Skriptis tekkis viga real $1 ja see peatati.\n" && exit 1
    else
        printf "Skriptis tekkis viga ja see peatati.\n" && exit 1
    fi
}

linux_username=dj
homedir=/home/$linux_username
icecast_conf_file_location="konfid/icecast.xml"
butt_conf_file_location="konfid/.buttrc"
liquidsoap_conf_file_location="konfid/raadio.liq"

# sisengi vastu võtmine ühe klahvivajutusega https://stackoverflow.com/a/1885534
user_confirm () {
    read -p "Teostan toimingu? [J/e] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]]
    then
        echo yes
    else 
        echo no
    fi
}

# lookbehind kasutus: https://stackoverflow.com/a/23009124
read_icecast_parameter () {
    grep -Po "(?<=<$1>).*(?=<\/$1>)" $icecast_conf_file_location
}

read_only_the_first_icecast_parameter_in_the_file () {
    grep -Pom1 "(?<=<$1>).*(?=<\/$1>)" $icecast_conf_file_location
}

update_icecast_parameter () {
    sed -i s/'<'$1'>.*<\/'$1'>'/'<'$1'>'$2'<\/'$1'>'/ $icecast_conf_file_location
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
    which icecast2 > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        icecast_source_password=$(read_icecast_parameter source-password)
        icecast_relay_password=$(read_icecast_parameter relay-password)
        icecast_admin_password=$(read_icecast_parameter admin-password)
        icecast_hostname=$(read_icecast_parameter hostname)
        icecast_port=$(read_only_the_first_icecast_parameter_in_the_file port)
        icecast_admin_user=$(read_icecast_parameter admin-user)
        icecast_location=$(read_icecast_parameter location)
        icecast_admin=$(read_icecast_parameter admin)
    fi
}

print_filename_sans_path_and_extension () {
    # töödeldav fail ei tohi olla peidetud
    printf $1 | grep -Po "(?<=\/)\w*(?=\.*)"
}

# privaatse ipv4 aadressi filtreerimine https://unix.stackexchange.com/a/119272
private_ipv4 () {
    ip a | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
}

print_icecast_data (){
    printf "Sinu icecast serveri aadress samast arvutist ühendamiseks on: $icecast_hostname\n"
    print_printf "Sinu icecast serveri aadress kohalikust võrgust ühendamiseks on: $(private_ipv4)\n"
    printf "Sinu icecast serveri port on: $icecast_port\n"
    printf "Sinu icecast meediavoo ühendamise parool on: $icecast_source_password\n"
    printf "Sinu icecast relee seadistamise parool on: $icecast_relay_password\n"
    printf "Sinu icecast haldamise parool on: $icecast_admin_password \n"
    printf "Sinu icecast haldamise kasutajanimi on: $icecast_admin_user \n"
}

verify_icecast_conf () {
    read_icecast_data
    printf "\nKontrolli üle, kas andmed klapivad!\n\n"
    print_icecast_data
    printf '\n'
}

configure_butt () {
    which butt > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        sed -i s/'address = .*'/'address = '$icecast_hostname/ $butt_conf_file_location
        sed -i s/'port = .*'/'port = '$icecast_port/ $butt_conf_file_location
        sed -i s/'password = .*'/'password = '$icecast_source_password/ $butt_conf_file_location
        sed -i s/'folder = .*'/'folder = \/home\/'$linux_username'\/salvestused\/'/ $butt_conf_file_location
    fi
}

configure_liquidsoap () {
    which liquidsoap > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        liquidsoap_logfile_name=$(print_filename_sans_path_and_extension $liquidsoap_conf_file_location)
        sed -i s%'set("log.file.path",.*'%'set("log.file.path","/tmp/'$liquidsoap_logfile_name'.log")'% $liquidsoap_conf_file_location
        sed -i s%'default = single.*'%'default = single("/home/'$linux_username'/helid/vaikimisi.ogg")'% $liquidsoap_conf_file_location
        sed -i s%'music   = playlist.*'%'music   = playlist("/home/'$linux_username'/helid/muusika.pls")'% $liquidsoap_conf_file_location
        sed -i s%'jingles = playlist.*'%'jingles = playlist("/home/'$linux_username'/helid/teated.pls")'% $liquidsoap_conf_file_location
        sed -i s%'\[input.http.*'%'\[input.http\("http://'$icecast_hostname':'$icecast_port'/otse-eeter.ogg"),'% $liquidsoap_conf_file_location
        sed -i s%'host=.*'%'host="'$icecast_hostname'",port='$icecast_port',password="'$icecast_source_password'",'% $liquidsoap_conf_file_location
    fi
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