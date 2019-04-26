#!/bin/bash
# Autor: Henri Paves
# Versioon: 0.1
# Otstarve: Loob igast endaga samal tasemel olevast kaustast esitusnimekirjad
# Juhend: bash v2rskenda_esitusloendeid.sh

# juurkasutaja õiguste kontroll https://wiki.itcollege.ee/index.php/Bash_n%C3%A4ide
if [ $UID -eq 0 ]
then
    printf "$(basename $0) tuleb käivitada tavakasutaja õigustes.\n"
    exit 1
fi

playlist_repository="$PWD/esitusnimekirjad.txt"

if [[ -r $playlist_repository && -w $playlist_repository ]]
then
    youtube-dl -a $playlist_repository
else
    printf "Skript katkes kuna ei saa esitusnimekirjade faili lugeda/kirjutada.\n" && exit 1
fi

printf "\n"

for dir in $(ls -d -- */ | cut -f1 -d'/')
do
    # kausta sisu tingimuslik kontroll: https://stackoverflow.com/a/17902737
    if [[ -r $dir && -w $dir && $(ls -A $dir) ]]
    then
        find $(pwd)/$dir -iname "*.ogg" > $dir.m3u
        printf "$dir.m3u on nüüd loodud või ajakohane.\n"
    fi
done


