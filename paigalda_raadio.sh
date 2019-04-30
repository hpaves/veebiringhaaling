#!/bin/bash
# Autor: Henri Paves
# Versioon: 0.1
# Otstarve: Paigaldab automaatselt ringhäälingu komponendid, küsides kasutajalt võimalikult vähe. Seadistamisel sõltub teistest skriptidest.
# Juhend: bash paigalda_raadio.sh <linux_kasutajanimi>
# Argument linux_kasutajanimi all on mõeldud tavakasutajat, kelle kontoga toimub failide haldamine.

# Butt paigalduse versioon sõltub käsitsi määratud URList. Vajadusel tuleb URL uuendada:
latest_butt_url="https://sourceforge.net/projects/butt/files/butt/butt-0.1.17/butt-0.1.17.tar.gz/download"

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
source $installer_directory/$repository_name/installation_functions.sh
source $installer_directory/$repository_name/configuration_functions.sh
check_for_root_privileges
make_line_number_variable
# exit_with_error ${LINENO}

# printf "Kontrollin kas süsteem on ajakohane...\n"
# apt-get update > /dev/null 2>&1 && apt-get full-upgrade -y || exit_with_error ${LINENO}
# printf "Süsteem on ajakohane.\n"

apt_install curl
apt_install ffmpeg
apt_install sudo
# apt_install audacity
apt_install ufw
apt_install icecast2
apt_install liquidsoap
install_butt
install_youtubedl
install_regular_website
apt-get clean && apt-get autoremove -y

bash $installer_directory/seadista_raadio.sh "$linux_username" || exit_with_error ${LINENO}

reboot_prompt