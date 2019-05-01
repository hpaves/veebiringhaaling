#!/bin/bash
# Author: Henri Paves
# Version: 0.1
# Application: Repository for functions.
# Instructions: Not meant to be executed independently.
# How to reference: source configuration_functions.sh

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

configure_ufw () {
    ufw enable
    ufw allow 80
    ufw allow 8000
}

update_index_html_element () {
    sed -i s/'<'$1'>.*<\/'$1'>'/'<'$1'>'$2'<\/'$1'>'/ $website_index_location || exit_with_error ${LINENO}
}

configure_website () {
    mkdir_if_not_there_already $website_base_folder/saated || exit_with_error ${LINENO}
    chmod -R 644 $website_base_folder/* || exit_with_error ${LINENO}
    chmod 755 $website_base_folder/css || exit_with_error ${LINENO}
    chmod -R 644 $website_base_folder/css/* || exit_with_error ${LINENO}

    mkdir_if_not_there_already $website_base_folder/saated
    ln -s $website_base_folder/saated $radio_dir/$public_dir_name/saated
    chmod 775 $website_base_folder/saated || exit_with_error ${LINENO}
    chmod -R 664 $website_base_folder/saated/*
    chown -R www-data:www-data $website_base_folder
    rm $website_base_folder/index.html

    if [ ! $(groups $linux_username | grep www-data) ]
    then
        usermod -a -G www-data $linux_username || exit_with_error ${LINENO}
    fi

    if radio_owner=$(whiptail --inputbox --title "Who's radio is this?" "\nRaadio kodulehele on vaja pealkirja.\n\nVaikimisi on selleks 'Meie oma raadio'.\n\nSiia sisesta kelle raadioga on tegu. Raadio tüübi saad määrata järgmises aknas.\n" 17 60 "Meie oma" 3>&1 1>&2 2>&3)
    then
        sed -i s/'<h1 class="display-3 text-white text-handwriting text-uppercase">.*<\/h1>'/'<h1 class="display-3 text-white text-handwriting text-uppercase">'$radio_owner'<\/h1>'/ $website_index_location || exit_with_error ${LINENO}
    fi

    if radio_type=$(whiptail --inputbox --title "What kind of radio is this?" "\nNüüd määra kodulehe pealkirja jaoks raadio tüüp.\n\nNäiteks: veebiraadio, kooliraadio, jne.\n\nVõib ka lihtsalt raadio.\n" 17 60 "raadio" 3>&1 1>&2 2>&3)
    then
        sed -i s/'<h1 class="display-1 text-success text-uppercase title-margin-fix">.*<\/h1>'/'<h1 class="display-1 text-success text-uppercase title-margin-fix">'$radio_type'<\/h1>'/ $website_index_location || exit_with_error ${LINENO}
    fi

    sed -i s%'<audio id="stream" xmlns="http://www.w3.org/1999/xhtml" controls="controls" preload="none"><source src="http://'.*'" type="audio/mpeg" /></audio>'%'<audio id="stream" xmlns="http://www.w3.org/1999/xhtml" controls="controls" preload="none"><source src="http://'$(private_ipv4):$icecast_port/$default_stream_name'" type="audio/mpeg" /></audio>'% $website_index_location || exit_with_error ${LINENO}

    sed -i s%'<audio id="recordings" xmlns="http://www.w3.org/1999/xhtml" controls="controls" preload="none"><source src="http://'.*?'/'%'<audio id="recordings" xmlns="http://www.w3.org/1999/xhtml" controls="controls" preload="none"><source src="http://'$(private_ipv4)'/'% $website_index_location || exit_with_error ${LINENO}

    sed -i s/'<title>.*<\/title>'/'<title>'$radio_owner' '$radio_type'<\/title>'/ $website_index_location || exit_with_error ${LINENO}

}
