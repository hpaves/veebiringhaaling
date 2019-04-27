#!/bin/bash
# Autor: Henri Paves 
# Versioon: 0.1
# Otstarve: Loeb Icecast2 seadistused ja kasutab neid muude vabavaralise veebringhäälingu komponentide seadistamiseks
# Juhend: sudo bash seadista_ringhaaling.sh <linux_kasutajanimi>

# Juurkasutaja õiguste kontroll https://wiki.itcollege.ee/index.php/Bash_n%C3%A4ide
if [ $UID -ne 0 ]
then
    printf "$(basename $0) tuleb käivitada juurkasutaja õigustes.\n"
    exit 1
fi

# argumentide arvu kontroll
if [ $# -eq 1 ]
then
    linux_username=$1
else
    echo "Skripti kasutus: sudo bash $(basename $0) <linux_kasutajanimi>"
    exit 1
fi

# reanumbri muutuja tekitamine https://stackoverflow.com/a/29081598
PS4=':$LINENO+'

exit_with_error () {
    # reanumbri väljastamiseks kasuta: || exit_with_error ${LINENO}
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

homedir=/home/$linux_username

icecast_default_file_copy="$homedir/veebiringhaaling/mallid/icecast.xml"
butt_template_file_location="$homedir/veebiringhaaling/mallid/.buttrc"
liquidsoap_template_file_location="$homedir/veebiringhaaling/mallid/raadio.liq"
youtubedl_template_file_location="$homedir/veebiringhaaling/mallid/config"

icecast_conf_file_location="/etc/icecast2/icecast.xml"
butt_conf_file_location="$homedir/.buttrc"
liquidsoap_conf_file_location="/etc/liquidsoap/raadio.liq"
youtubedl_conf_file_location="$homedir/.config/youtube-dl/config"

mkdir -p $homedir/{helid/{muusika,saated,teated},salvestused}
touch $homedir/helid/{muusika.m3u,saated.m3u,teated.m3u}
mv esitusloendid.txt $homedir/helid/esitusloendid.txt
mv v2rskenda_esitusloendeid.sh $homedir/helid/v2rskenda_esitusloendeid.sh
groupadd veebiringhaaling
usermod -a -G veebiringhaaling $linux_username
usermod -a -G veebiringhaaling icecast2
usermod -a -G veebiringhaaling liquidsoap
chown -R $linux_username:$linux_username $homedir
chown -R :veebiringhaaling $homedir/{helid,salvestused}
chmod -R 750 $homedir/helid
chmod -R 754 $homedir/salvestused

# sisendi vastu võtmine ühe klahvivajutusega https://stackoverflow.com/a/1885534
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
    sed -i s/'<'$1'>.*<\/'$1'>'/'<'$1'>'$2'<\/'$1'>'/ $icecast_conf_file_location || exit_with_error ${LINENO}
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

    printf "\nSinu icecast teenust saab hetkel maksimaalselt kuulata %s kuulajat.\n" $icecast_clients
    read -p "Määra endale sobiv maksimaalsete kuulajate arv: " -r
    update_icecast_parameter clients $REPLY

    printf "\nSinu icecast teenusesse saab hetkel saata maksimaalselt %s sisendvoogu.\nLiquidsoap vajab vaikimisi kahte, butt ühte ja mixxx samuti ühte voogu.\nKõiki kolme tarkvara kasutades läheb seega kokku tarvis vähemalt nelja voogu.\n" $icecast_sources
    read -p "Määra endale sobiv maksimaalsete sisendvoogude arv: " -r
    update_icecast_parameter sources $REPLY

}

read_icecast_data () {
    which icecast2 > /dev/null 2>&1

    if [[ $? -eq 0 && -r $icecast_conf_file_location && -w $icecast_conf_file_location ]]
    then
        icecast_clients=$(read_icecast_parameter clients)
        icecast_sources=$(read_icecast_parameter sources)
        icecast_source_password=$(read_icecast_parameter source-password)
        icecast_relay_password=$(read_icecast_parameter relay-password)
        icecast_admin_password=$(read_icecast_parameter admin-password)
        icecast_hostname=$(read_icecast_parameter hostname)
        icecast_port=$(read_only_the_first_icecast_parameter_in_the_file port)
        icecast_admin_user=$(read_icecast_parameter admin-user)
        icecast_location=$(read_icecast_parameter location)
        icecast_admin=$(read_icecast_parameter admin)
    else
        error_issues_with_program icecast2
        printf "icecast on vajalik.\n"
        exit_with_error
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

print_icecast_data () {
    printf "Sinu icecast serveri aadress samast arvutist ühendamiseks on: $icecast_hostname\n"
    printf "Sinu icecast serveri aadress kohalikust võrgust ühendamiseks on: $(private_ipv4)\n"
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

    if [[ $? -eq 0 ]]
    then
        cp $butt_template_file_location $butt_conf_file_location || exit_with_error ${LINENO}
        if [[ -r $butt_conf_file_location && -w $butt_conf_file_location ]]
        then
            sed -i s/'address = .*'/'address = '$icecast_hostname/ $butt_conf_file_location || exit_with_error ${LINENO}
            sed -i s/'port = .*'/'port = '$icecast_port/ $butt_conf_file_location || exit_with_error ${LINENO}
            sed -i s/'password = .*'/'password = '$icecast_source_password/ $butt_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'folder = .*'%'folder = '$homedir'/salvestused/'% $butt_conf_file_location || exit_with_error ${LINENO}
        fi
    fi
}

configure_liquidsoap () {
    which liquidsoap > /dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        cp $liquidsoap_template_file_location $liquidsoap_conf_file_location || exit_with_error ${LINENO}
        if [[ -r $liquidsoap_conf_file_location && -w $liquidsoap_conf_file_location ]]
        then
            liquidsoap_logfile_name=$(print_filename_sans_path_and_extension $liquidsoap_conf_file_location)
            sed -i s%'set("log.file.path",.*'%'set("log.file.path","/tmp/'$liquidsoap_logfile_name'.log")'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'default = single.*'%'default = single("/home/'$linux_username'/helid/vaikimisi.ogg")'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'music   = playlist.*'%'music   = playlist("/home/'$linux_username'/helid/muusika.m3u")'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'jingles = playlist.*'%'jingles = playlist("/home/'$linux_username'/helid/teated.m3u")'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'\[input.http.*'%'\[input.http\("http://'$icecast_hostname':'$icecast_port'/otse-eeter.ogg"),'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'host=.*'%'host="'$icecast_hostname'",port='$icecast_port',password="'$icecast_source_password'",'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
        fi
    fi
}

configure_youtubedl () {
    which youtube-dl > /dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        mkdir p $homedir/.config/youtube-dl/
        cp $youtubedl_template_file_location $youtubedl_conf_file_location || exit_with_error ${LINENO}
        if [[ -r $youtubedl_conf_file_location && -w $youtubedl_conf_file_location ]]
        then
            sed -i s%'--download-archive .*'%'--download-archive "'$homedir'/helid/youtube_allalaadimiste_arhiiv.txt"'% $youtubedl_conf_file_location || exit_with_error ${LINENO}
            sed -i s:'-o .*':'-o "'$homedir'/helid/muusika/%(title)s %(id)s.%(ext)s"': $youtubedl_conf_file_location || exit_with_error ${LINENO}
        fi
    fi
}

read_icecast_data
update_icecast_default_values
verify_icecast_conf
configure_butt
configure_liquidsoap
configure_youtubedl
