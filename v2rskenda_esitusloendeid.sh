#!/bin/bash
# Autor: Henri Paves
# Versioon: 0.1
# Otstarve: Loob igast endaga samal tasemel olevast kaustast esitusloendeid
# Juhend: bash v2rskenda_esitusloendeid.sh
# Käivita see fail tavakasutajana.

# kasutaja root ei peaks tegelema helifailide haldamisega
check_for_root_privileges_absence () {
    if [ $UID -eq 0 ]
    then
        printf "$(basename $0) tuleb käivitada tavakasutaja õigustes.\n"
        exit 1
    fi
}

# reanumbri muutuja tekitamine https://stackoverflow.com/a/29081598
make_line_number_variable () {
    PS4=':$LINENO+'
}

check_for_root_privileges_absence
make_line_number_variable
# exit_with_error ${LINENO}

# duplikaatmuutujad failis global_variables.sh
public_dir_name=avalik
radio_dir_name=raadio
default_playlist_name=esitusloendid.txt
# duplikaatmuutjate lõpp

public_dir="$HOME/$radio_dir_name/$public_dir_name"
playlist_repository="$HOME/$radio_dir_name/$default_playlist_name"

# pidev muutuste kontroll https://stackoverflow.com/a/28338077
if [[ $(find $HOME/$radio_dir_name/ -mmin -2 -type f -print) ]]
then
    if [[ -r $playlist_repository && -w $playlist_repository ]]
    then
        # miks cron ei tea tavalisi käske https://unix.stackexchange.com/a/65456
        /usr/local/bin/youtube-dl -a $playlist_repository
    else
        printf "Skript katkes kuna ei saa esitusloendite faili lugeda/kirjutada.\n" && exit 1
    fi

    printf "\n"

    for dir in $(find $public_dir -maxdepth 1 -mindepth 1 -type d | grep -Po "[^\/]*$" )
    do
        # kausta sisu tingimuslik kontroll: https://stackoverflow.com/a/17902737
        if [[ $(ls -A $public_dir/$dir) ]]
        then
            find $public_dir/$dir -iname "*.ogg" > $public_dir/$dir.m3u
            printf "$dir.m3u on nüüd loodud või ajakohane.\n"
        fi
    done
fi
