#!/bin/bash
# Autor: Henri Paves 
# Versioon: 0.1
# Otstarve: Loeb Icecast2 seadistused ja kasutab neid muude vabavaralise veebringhäälingu komponentide seadistamiseks
# Juhend: sudo bash seadista_raadio.sh <linux_kasutajanimi>

# käivitatud skripti asukoha leidmine https://stackoverflow.com/a/630387
find_installer_directory () {
    MY_PATH="`dirname \"$BASH_SOURCE\"`"    # relative
    MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
    if [ -z "$MY_PATH" ]
    then
        exit_with_error ${LINENO}
    fi
    installer_directory="$MY_PATH"
}

find_installer_directory

source $installer_directory/funktsioonide_varamu.sh
check_for_root_privileges
ensure_exactly_one_argument
make_line_number_variable
# exit_with_error ${LINENO}

user_homedir=/home/$linux_username
radio_dir=$user_homedir/raadio

icecast_default_file_copy="$installer_directory/mallid/icecast.xml"
butt_template_file_location="$installer_directory/mallid/.buttrc"
liquidsoap_template_file_location="$installer_directory/mallid/raadio.liq"
youtubedl_template_file_location="$installer_directory/mallid/config"

icecast_conf_file_location="/etc/icecast2/icecast.xml"
butt_conf_file_location="$user_homedir/.buttrc"
liquidsoap_conf_file_location="/etc/liquidsoap/raadio.liq"
youtubedl_conf_file_location="$user_homedir/.config/youtube-dl/config"

mkdir -p $radio_dir/{helid/{muusika,saated,teated},salvestused}
touch $radio_dir/helid/{muusika.m3u,saated.m3u,teated.m3u}
mv esitusloendid.txt $radio_dir/helid/esitusloendid.txt
mv v2rskenda_esitusloendeid.sh $radio_dir/helid/v2rskenda_esitusloendeid.sh
groupadd veebiringhaaling
usermod -a -G veebiringhaaling $linux_username
usermod -a -G veebiringhaaling icecast2
usermod -a -G veebiringhaaling liquidsoap

# sisendi vastu võtmine ühe klahvivajutusega https://stackoverflow.com/a/1885534
icecast_password_save_option () {
    read -p "Kas ma kirjutan need andmed $linux_username kodukaustas asuvasse faili? [J/e] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]]
    then
        print_icecast_data > $user_homedir/serveri_andmed.txt
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

print_icecast_data () {
    printf "\n"
    printf "Sinu icecast serveri aadress samast arvutist ühendamiseks on: $icecast_hostname\n"
    printf "Sinu icecast serveri aadress kohalikust võrgust ühendamiseks on: $(private_ipv4)\n"
    printf "Sinu icecast serveri port on: $icecast_port\n"
    printf "Sinu icecast meediavoo ühendamise parool on: $icecast_source_password\n"
    printf "Sinu icecast relee seadistamise parool on: $icecast_relay_password\n"
    printf "Sinu icecast haldamise parool on: $icecast_admin_password \n"
    printf "Sinu icecast haldamise kasutajanimi on: $icecast_admin_user \n"
    printf "\n"
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
            sed -i s%'folder = .*'%'folder = '$radio_dir'/salvestused/'% $butt_conf_file_location || exit_with_error ${LINENO}
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
            liquidsoap_logfile_name=$(print_filename_without_path_and_extension $liquidsoap_conf_file_location)
            sed -i s%'set("log.file.path",.*'%'set("log.file.path","/tmp/'$liquidsoap_logfile_name'.log")'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'default = single.*'%'default = single("'$radio_dir'/helid/vaikimisi.ogg")'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'music   = playlist.*'%'music   = playlist("'$radio_dir'/helid/muusika.m3u")'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'jingles = playlist.*'%'jingles = playlist("'$radio_dir'/helid/teated.m3u")'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'\[input.http.*'%'\[input.http\("http://'$icecast_hostname':'$icecast_port'/otse-eeter.ogg"),'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'host=.*'%'host="'$icecast_hostname'",port='$icecast_port',password="'$icecast_source_password'",'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
        fi
    fi
}

configure_youtubedl () {
    which youtube-dl > /dev/null 2>&1

    if [[ $? -eq 0 ]]
    then
        mkdir -p $user_homedir/.config/youtube-dl/
        cp $youtubedl_template_file_location $youtubedl_conf_file_location || exit_with_error ${LINENO}
        if [[ -r $youtubedl_conf_file_location && -w $youtubedl_conf_file_location ]]
        then
            sed -i s%'--download-archive .*'%'--download-archive "'$radio_dir'/helid/youtube_allalaadimiste_arhiiv.txt"'% $youtubedl_conf_file_location || exit_with_error ${LINENO}
            sed -i s:'-o .*':'-o "'$radio_dir'/helid/muusika/%(title)s %(id)s.%(ext)s"': $youtubedl_conf_file_location || exit_with_error ${LINENO}
        fi
    fi
}

read_icecast_data
update_icecast_default_values
configure_butt
configure_liquidsoap
configure_youtubedl
print_icecast_data
icecast_password_save_option

chown -R $linux_username:$linux_username $user_homedir/.
chown -R :veebiringhaaling $radio_dir
chmod -R 750 $radio_dir/helid
chmod -R 754 $radio_dir/salvestused
