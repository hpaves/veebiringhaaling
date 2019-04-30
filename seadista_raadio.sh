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

if [ $# -eq 1 ]
then
    linux_username=$1
else
    printf "\nSkripti kasutus: bash $(basename $0) <linux_kasutajanimi>\n"
    printf "Mõeldud on tavakasutajat, kelle konto all toimub failide haldamine.\n\n"
    exit 1
fi

source $installer_directory/funktsioonide_varamu.sh
check_for_root_privileges
make_line_number_variable
# exit_with_error ${LINENO}

user_homedir=/home/$linux_username
radio_dir=$user_homedir/raadio
public_dir_name=avalik

icecast_default_file_copy="$installer_directory/mallid/icecast.xml"
butt_template_file_location="$installer_directory/mallid/.buttrc"
liquidsoap_template_file_location="$installer_directory/mallid/raadio.liq"
youtubedl_template_file_location="$installer_directory/mallid/config"

icecast_conf_file_location="/etc/icecast2/icecast.xml"
butt_conf_file_location="$user_homedir/.buttrc"
liquidsoap_conf_file_location="/etc/liquidsoap/raadio.liq"
youtubedl_conf_file_location="$user_homedir/.config/youtube-dl/config"

mkdir_if_not_there_already $radio_dir
mkdir_if_not_there_already $radio_dir/salvestused
mkdir_if_not_there_already $radio_dir/$public_dir_name
mkdir_if_not_there_already $radio_dir/$public_dir_name/muusika
mkdir_if_not_there_already $radio_dir/$public_dir_name/saated
mkdir_if_not_there_already $radio_dir/$public_dir_name/teated

touch_if_not_there_already $radio_dir/$public_dir_name/muusika.m3u
touch_if_not_there_already $radio_dir/$public_dir_name/saated.m3u
touch_if_not_there_already $radio_dir/$public_dir_name/teated.m3u

cp_if_not_there_already $installer_directory/esitusloendid.txt $radio_dir/esitusloendid.txt
cp_if_not_there_already $installer_directory/v2rskenda_esitusloendeid.sh $radio_dir/v2rskenda_esitusloendeid.sh
cp_if_not_there_already $installer_directory/helid/vaikimisi.ogg $radio_dir/$public_dir_name/vaikimisi.ogg

if [ ! $(cat /etc/group | grep veebiringhaaling) ]
then
    groupadd veebiringhaaling || exit_with_error ${LINENO}
    usermod -a -G veebiringhaaling $linux_username || exit_with_error ${LINENO}
    usermod -a -G veebiringhaaling icecast2 || exit_with_error ${LINENO}
    usermod -a -G veebiringhaaling liquidsoap || exit_with_error ${LINENO}
fi

icecast_password_save_option () {
    if whiptail --yesno --title "Jääb sulle see kõik meelde?" "Sinu icecast serveri andmed:\n\nAadress samast arvutist ühendamiseks: $icecast_hostname\nAadress kohalikust võrgust ühendamiseks: $(private_ipv4)\nServeri port: $icecast_port\nMeediavoo ühendamise parool: $icecast_source_password\nRelee seadistamise parool: $icecast_relay_password\nVeebiliidese parool: $icecast_admin_password \nVeebiliidese kasutajanimi: $icecast_admin_user \n\nKohaliku võrgus kuulamise aadress: $(private_ipv4):$icecast_port\n\nKas salvestan need andmed eraldi $linux_username kodukausta?\n" 20 60 3>&1 1>&2 2>&3
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
    if [[ $icecast_admin_user =~ admin ]]
    then
        # sterr stdouti suunamise trikk https://stackoverflow.com/a/1970254
        new_admin_user=$(whiptail --inputbox --nocancel --title "Change icecast2 admin-user" "\nSinu icecast teenuse haldamise kasutajanimi on admin.\nNime samaks jätmine võib kaasa tuua turvariski.\n\nPalun sisesta uus (ilma täpitähtedeta) kasutajanimi." 12 60 3>&1 1>&2 2>&3)
        update_icecast_parameter admin-user $new_admin_user
    fi

    if new_clients=$(whiptail --inputbox --title "Set icecast2 max clients" "\nSinu icecast teenust saab vaikimisi kuulata $icecast_clients kuulajat.\n\nMäära endale sobiv maksimaalsete kuulajate arv." 12 60 "$icecast_clients" 3>&1 1>&2 2>&3)
    then
        update_icecast_parameter clients $new_clients
    fi

    if new_sources=$(whiptail --inputbox --title "Set icecast2 max sources" "\nSinu icecast teenusesse saab hetkel saata maksimaalselt $icecast_sources sisendvoogu.\n\nLiquidsoap vajab vaikimisi kahte ja butt ühte voogu, ning vaikimisi paigaldatakse need mõlemad.\n\nSeega läheb edukaks automaatpaigalduseks tarvis vähemalt kolme voogu.\n\nMäära endale sobiv maksimaalsete sisendvoogude arv.\n" 18 60 "3" 3>&1 1>&2 2>&3)
    then
        update_icecast_parameter sources $new_sources
    fi

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
    printf "Sinu icecast serveri andmed:\n\n"
    printf "Aadress samast arvutist ühendamiseks: $icecast_hostname\n"
    printf "Aadress kohalikust võrgust ühendamiseks: $(private_ipv4)\n"
    printf "Serveri port: $icecast_port\n"
    printf "Meediavoo ühendamise parool: $icecast_source_password\n"
    printf "Relee seadistamise parool: $icecast_relay_password\n"
    printf "Veebiliidese parool: $icecast_admin_password \n"
    printf "Veebiliidese kasutajanimi: $icecast_admin_user \n\n"
    printf "Kohaliku võrgus kuulamise aadress: $(private_ipv4):$icecast_port\n"
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
            # programmimenüü ikoonide asukohad: https://www.raspberrypi.org/forums/viewtopic.php?p=784631#p784631
            cp_if_not_there_already $installer_directory/mallid/butt.desktop /usr/share/applications/butt.desktop
            cp_if_not_there_already $installer_directory/pildid/butt-icon.svg /usr/share/pixmaps/butt-icon.svg
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
            sed -i s%'default = single.*'%'default = single("'$radio_dir'/'$public_dir_name'/vaikimisi.ogg")'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'music   = playlist.*'%'music   = playlist("'$radio_dir'/'$public_dir_name'/muusika.m3u",reload_mode="watch")'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
            sed -i s%'jingles = playlist.*'%'jingles = playlist("'$radio_dir'/'$public_dir_name'/teated.m3u",reload_mode="watch")'% $liquidsoap_conf_file_location || exit_with_error ${LINENO}
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
            sed -i s%'--download-archive .*'%'--download-archive "'$radio_dir'/youtube_allalaadimiste_arhiiv.txt"'% $youtubedl_conf_file_location || exit_with_error ${LINENO}
            sed -i s:'-o .*':'-o "'$radio_dir'/'$public_dir_name'/muusika/%(title)s %(id)s.%(ext)s"': $youtubedl_conf_file_location || exit_with_error ${LINENO}
        fi
    fi
}

ask_for_youtube_url () {
    if youtube_url=$(whiptail --inputbox --title "Add first playlist to youtube-dl" "\nSinu serveri ~/raadio kaustas asub fail esitusloendid.txt\n\nAntud failis olevaid esitusloendeid kontrollitakse ajakohasuse osas, tõmmatakse uued lood alla lisatakse raadioprogrammi.\n\nFaili saab igal ajal täiendada, aga palun lisa siia oma esimene YouTube esitusloend või viide.\n" 17 60 "https://www.youtube.com/watch?v=z0NfI2NeDHI" 3>&1 1>&2 2>&3)
    then
        printf "$youtube_url\n" >> $radio_dir/esitusloendid.txt 
    fi
}

read_icecast_data
update_icecast_default_values
configure_butt
configure_liquidsoap
configure_youtubedl
print_icecast_data
icecast_password_save_option
ask_for_youtube_url

chown -R $linux_username:$linux_username $user_homedir/. || exit_with_error ${LINENO}
chown -R :veebiringhaaling $radio_dir/$public_dir_name || exit_with_error ${LINENO}
chmod -R 754 $radio_dir/$public_dir_name || exit_with_error ${LINENO}
chmod -R 750 $radio_dir/salvestused || exit_with_error ${LINENO}

bash $installer_directory/add_cronjob_user_x_job_y.sh root "0 3 * * 6 /usr/local/bin/youtube-dl -U"
bash $installer_directory/add_cronjob_user_x_job_y.sh $linux_username "* * * * * /bin/bash $radio_dir/v2rskenda_esitusloendeid.sh"

sudo -u $linux_username bash $radio_dir/v2rskenda_esitusloendeid.sh

printf "\nVõimalikud find veateated on paigaldusskripti käivitades normaalsed.\nNeed tähendavad, et kasutajal $linux_username pole paigaldusfailide kaustale ligipääsu.\nNii ongi hea.\n"
