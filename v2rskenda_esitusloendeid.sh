#!/bin/bash
# Autor: Henri Paves
# Versioon: 0.1
# Otstarve: Loob igast endaga samal tasemel olevast kaustast esitusloendeid
# Juhend: bash v2rskenda_esitusloendeid.sh
# Käivita see fail tavakasutajana.

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

check_for_root_privileges_absence () {
    if [ $UID -eq 0 ]
    then
        printf "$(basename $BASH_SOURCE) tuleb käivitada tavakasutaja õigustes.\n"
        exit 1
    fi
}

# reanumbri muutuja tekitamine https://stackoverflow.com/a/29081598
make_line_number_variable () {
    PS4=':$LINENO+'
}

find_installer_directory
check_for_root_privileges_absence
make_line_number_variable
# exit_with_error ${LINENO}

public_dir="$HOME/raadio/avalik"
playlist_repository="$HOME/raadio/esitusloendid.txt"

if [[ -r $playlist_repository && -w $playlist_repository ]]
then
    youtube-dl -a $playlist_repository
else
    printf "Skript katkes kuna ei saa esitusloendite faili lugeda/kirjutada.\n" && exit 1
fi

printf "\n"

for dir in $(find $public_dir -maxdepth 1 -mindepth 1 -type d | cut -f5 -d '/')
do
    # kausta sisu tingimuslik kontroll: https://stackoverflow.com/a/17902737
    if [[ $(ls -A $public_dir/$dir) ]]
    then
        find $public_dir/$dir -iname "*.ogg" > $public_dir/$dir.m3u
        printf "$dir.m3u on nüüd loodud või ajakohane.\n"
    fi
done
