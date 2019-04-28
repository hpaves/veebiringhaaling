#!/bin/bash
# Autor: Henri Paves
# Versioon: 0.1
# Otstarve: Paigaldab automaatselt ringhäälingu komponendid, küsides kasutajalt võimalikult vähe. Seadistamisel sõltub teistest skriptidest.
# Juhend: bash paigalda_raadio.sh <linux_kasutajanimi>
# Argument linux_kasutajanimi all on mõeldud tavakasutajat, kelle kontoga toimub failide haldamine.

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
    echo $1
else
    printf "\nSkripti kasutus: bash $(basename $0) <linux_kasutajanimi>\n"
    printf "Mõeldud on tavakasutajat, kelle konto all toimub failide haldamine.\n\n"
    exit 1
fi

source $installer_directory/funktsioonide_varamu.sh
check_for_root_privileges
make_line_number_variable
# exit_with_error ${LINENO}

printf "Kontrollin kas süsteem on ajakohane...\n"
apt-get update > /dev/null 2>&1 && apt-get full-upgrade -y || exit_with_error ${LINENO}
printf "Süsteem on ajakohane.\n"

apt_install () {
    local appname=$1
    which $appname > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        printf "$appname pole paigaldatud. Paigaldame programmi $appname...\n"
        apt-get install $1 -y || exit_with_error
        printf "$appname paigaldatud\n"
    fi
}

apt_install curl
apt_install ffmpeg
apt_install sudo

install_butt () {
    which butt > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        printf "butt pole paigaldatud. Paigaldame programmi butt...\n"
        install_latest_butt || install_old_butt || exit_with_error
        printf "butt paigaldatud.\n"
    fi
}

install_latest_butt () {
    # butt install fix https://stackoverflow.com/questions/27955600/broadcast-using-this-tool-butt-install-issues
    apt-get install -y alsa-oss alsa-utils build-essential gcc libasound2 libdbus-1-dev libflac-dev libfltk1.3-dev libmp3lame-dev libogg-dev libopus-dev libsamplerate0-dev libsamplerate-dev libvorbis-dev portaudio19-dev  || exit_with_error ${LINENO}
    curl -LOJ https://sourceforge.net/projects/butt/files/butt/butt-0.1.17/butt-0.1.17.tar.gz/download -o $installer_directory|| exit_with_error ${LINENO}
    mkdir $installer_directory/butt_installer || exit_with_error ${LINENO}
    tar -xzf $installer_directory/butt-*.tar.gz -C $installer_directory/butt_installer --strip-components 1 || exit_with_error ${LINENO}
    cd $installer_directory/butt_installer || exit_with_error ${LINENO}
    ./configure --disable-aac || exit_with_error ${LINENO}
    make || exit_with_error ${LINENO}
    make install || exit_with_error ${LINENO}
    rm -rf $installer_directory/{butt-*.tar.gz,butt_installer}
}

install_old_butt () {
    apt-get install -y libfltk1.3-dev portaudio19-dev libopus-dev libmp3lame-dev libvorbis-dev libogg-dev libflac-dev libdbus-1-dev libsamplerate0-dev || exit_with_error ${LINENO}
    curl -LOJ https://sourceforge.net/projects/butt/files/butt/butt-0.1.13/butt_0.1.13-1-0ubuntu1~trusty_amd64.deb/download -o $installer_directory || exit_with_error ${LINENO}
    dpkg -i $installer_directory/butt*.deb || exit_with_error ${LINENO}
    rm $installer_directory/butt*.deb
}

install_youtubedl () {
    which youtube-dl > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        printf "youtube-dl pole paigaldatud. Paigaldame programmi youtube-dl...\n"
        curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl || exit_with_error ${LINENO}
        chmod a+rx /usr/local/bin/youtube-dl || exit_with_error ${LINENO}
        printf "youtube-dl paigaldatud.\n"
    fi
}

apt_install icecast2
apt_install liquidsoap
install_butt
install_youtubedl
apt-get clean && apt-get autoremove -y

bash $installer_directory/seadista_raadio.sh "$linux_username" && nano /home/$linux_username/raadio/helid/esitusloendid.txt && sudo -u $linux_username bash /home/$linux_username/raadio/helid/v2rskenda_esitusloendeid.sh || exit_with_error ${LINENO}
reboot
