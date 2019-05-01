#!/bin/bash
# Author: Henri Paves
# Version: 0.1
# Application: Repository for functions.
# Instructions: Not meant to be executed independently.
# How to reference: source installation_functions.sh

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
    curl -LJ $latest_butt_url -o $installer_directory/butt_installer.tar.gz || exit_with_error ${LINENO}
    mkdir $installer_directory/butt_installer || exit_with_error ${LINENO}
    tar -xzf $installer_directory/butt_installer.tar.gz -C $installer_directory/butt_installer --strip-components 1 || exit_with_error ${LINENO}
    cd $installer_directory/butt_installer || exit_with_error ${LINENO}
    ./configure --disable-aac || exit_with_error ${LINENO}
    make || exit_with_error ${LINENO}
    make install || exit_with_error ${LINENO}
    rm -rf $installer_directory/{butt_installer.tar.gz,butt_installer}
}

install_old_butt () {
    apt-get install -y libfltk1.3-dev portaudio19-dev libopus-dev libmp3lame-dev libvorbis-dev libogg-dev libflac-dev libdbus-1-dev libsamplerate0-dev || exit_with_error ${LINENO}
    curl -LJ https://sourceforge.net/projects/butt/files/butt/butt-0.1.13/butt_0.1.13-1-0ubuntu1~trusty_amd64.deb/download -o $installer_directory/butt_installer.deb || exit_with_error ${LINENO}
    dpkg -i $installer_directory/butt_installer.deb || exit_with_error ${LINENO}
    rm $installer_directory/butt_installer.deb
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

install_website_base () {
    # apachet ei saa which käsuga leida
    dpkg -l apache2 > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        printf "apache2 pole paigaldatud. Paigaldame programmi apache2...\n"
        apt-get install apache2 -y || exit_with_error ${LINENO}
        printf "apache2 paigaldatud.\n"
    fi

    apt_install php
    apt_install libapache2-mod-php7.0
}

install_regular_website () {
    install_website_base
    cp -r $installer_directory/daydream/* /var/www/html/
}

install_restricted_website () {
    install_website_base
    cp -r $installer_directory/daydream_restricted/* /var/www/html/
}

install_website_and_give_a_choice () {
    if whiptail --yesno --title "Website password restrictions?" "Loodavale veebiraadiole luuakse veebiliides, mille kaudu kasutajad seda kuulavad.\n\nKas kasutajad peaks raadiole ligipääsuks sisestama parooli?\n\nParooli määramine on kasulik näiteks haridusasutusele, kes tahab oma raadio internetis kättesaadavaks teha, kuid samas kuulajate ringi piirata.\n\n" 16 60 3>&1 1>&2 2>&3
    then
        install_restricted_website
    else
        install_regular_website
    fi
}
