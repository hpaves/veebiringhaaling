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

repository_name=varamu

source $installer_directory/$repository_name/global_variables.sh
source $installer_directory/$repository_name/general_functions.sh
source $installer_directory/$repository_name/configuration_functions.sh
check_for_root_privileges
make_line_number_variable
# exit_with_error ${LINENO}

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

read_icecast_data
update_icecast_default_values
configure_butt
configure_liquidsoap
configure_youtubedl
print_icecast_data
icecast_password_save_option
ask_for_youtube_url
configure_website

chown -R $linux_username:$linux_username $user_homedir/. || exit_with_error ${LINENO}
chown -R :veebiringhaaling $radio_dir/$public_dir_name || exit_with_error ${LINENO}
chmod -R 754 $radio_dir/$public_dir_name || exit_with_error ${LINENO}
chmod -R 750 $radio_dir/salvestused || exit_with_error ${LINENO}

bash $installer_directory/$repository_name/add_cronjob_user_x_job_y.sh root "0 3 * * 6 /usr/local/bin/youtube-dl -U"
bash $installer_directory/$repository_name/add_cronjob_user_x_job_y.sh $linux_username "* * * * * /bin/bash $radio_dir/v2rskenda_esitusloendeid.sh"

sudo -u $linux_username bash $radio_dir/v2rskenda_esitusloendeid.sh

printf "\nVõimalikud find veateated on paigaldusskripti käivitades normaalsed.\nNeed tähendavad, et kasutajal $linux_username pole paigaldusfailide kaustale ligipääsu, mida ei peagi olema."
