#!/bin/bash
# Autor: Henri Paves
# Versioon: 0.1
# Otstarve: Loob igast endaga samal tasemel olevast kaustast esitusloendeid
# Juhend: bash v2rskenda_esitusloendeid.sh

# juurkasutaja õiguste kontroll https://wiki.itcollege.ee/index.php/Bash_n%C3%A4ide
if [ $UID -eq 0 ]
then
    printf "$(basename $0) tuleb käivitada tavakasutaja õigustes.\n"
    exit 1
fi

sounds_directory="/home/$USER/helid"
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
    if [[ $(ls -A $($sounds_directory/$dir)) ]]
    then
        find $sounds_directory/$dir -iname "*.ogg" > $sounds_directory/$dir.m3u
        printf "$dir.m3u on nüüd loodud või ajakohane.\n"
    fi
done
