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

find_installer_directory

source $installer_directory/funktsioonide_varamu.sh
check_for_root_privileges_absence
make_line_number_variable
# exit_with_error ${LINENO}

sounds_directory="$HOME/raadio/helid"
playlist_repository="$sounds_directory/esitusloendid.txt"

if [[ -r $playlist_repository && -w $playlist_repository ]]
then
    youtube-dl -a $playlist_repository
else
    printf "Skript katkes kuna ei saa esitusloendite faili lugeda/kirjutada.\n" && exit 1
fi

printf "\n"

for dir in $(find $sounds_directory -maxdepth 1 -mindepth 1 -type d | cut -f5 -d '/')
do
    # kausta sisu tingimuslik kontroll: https://stackoverflow.com/a/17902737
    if [[ $(ls -A $sounds_directory/$dir) ]]
    then
        find $sounds_directory/$dir -iname "*.ogg" > $sounds_directory/$dir.m3u
        printf "$dir.m3u on nüüd loodud või ajakohane.\n"
    fi
done
