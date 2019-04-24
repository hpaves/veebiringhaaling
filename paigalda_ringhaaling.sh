#!/bin/bash
#Autor: Henri Paves 
#Versioon: 0.1
#Otstarve: Võimaldab kasutajal valida millised vabavaralise veebringhäälingu komponendid paigaldada
#Juhend: sudo bash paigalda_ringhaaling.sh

# juurkasutaja õiguste kontroll https://wiki.itcollege.ee/index.php/Bash_n%C3%A4ide
if [ $UID -ne 0 ]
then
    printf "$(basename $0) tuleb käivitada juurkasutaja õigustes.\n"
    exit 1
fi

error_stop () {
    printf "Skriptis tekkis viga ja see peatati.\n" && exit 1
}

printf "Värskendan kogu süsteemi...\n"
apt-get update > /dev/null 2>&1 && apt-get full-upgrade -y || error_stop
printf "Süsteem on ajakohane.\n"

install_butt () {
    which butt > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        printf "butt pole paigaldatud. Paigaldame programmi butt...\n"
        # uue ja vana korraga paigaldamine pole näpukas, vaid vajalik et programmi värskeim versioon tööle hakkaks
        install_latest_butt && install_old_butt || error_stop
        printf "butt paigaldatud.\n"
    fi
}

install_latest_butt () {
    # butt install fix https://stackoverflow.com/questions/27955600/broadcast-using-this-tool-butt-install-issues
    apt-get install -y alsa-oss alsa-utils build-essential gcc libasound2 libdbus-1-dev libflac-dev libfltk1.3-dev libmp3lame-dev libogg-dev libopus-dev libsamplerate0-dev libsamplerate-dev libvorbis-dev portaudio19-dev 
    wget --content-disposition https://sourceforge.net/projects/butt/files/butt/butt-0.1.17/butt-0.1.17.tar.gz/download
    mkdir butt_installer
    tar -xzf butt-*.tar.gz -C butt_installer --strip-components 1
    cd butt_installer
    ./configure --disable-aac
    make
    make install
}

install_old_butt () {
    apt-get install -y libfltk1.3-dev portaudio19-dev libopus-dev libmp3lame-dev libvorbis-dev libogg-dev libflac-dev libdbus-1-dev libsamplerate0-dev
    wget --content-disposition https://sourceforge.net/projects/butt/files/butt/butt-0.1.13/butt_0.1.13-1-0ubuntu1~trusty_amd64.deb/download
    dpkg -i butt*.deb
}

apt_install () {
    local appname=$1
    which $appname > /dev/null 2>&1

    if [ $? -ne 0 ]
    then
        printf "$appname pole paigaldatud. Paigaldame programmi $appname...\n"
        apt-get install $1 -y || error_stop
        printf "$appname paigaldatud\n"
    fi
}

# Toggleable flags to indicate choices - Dennis Williamson
# 2013-05-10 - https://serverfault.com/a/506704
choice () {
    local choice=$1
    if [[ ${opts[choice]} ]] # toggle
    then
        opts[choice]=
    else
        opts[choice]=+
    fi
}

software=("sudo" "icecast2" "butt" "liquidsoap" "mixxx")

PS3='Vali soovitud tarkvara: ' 
while :
do
    clear
    printf 'Icecast2 tuleb paigaldamisel kohe seadistada. Loe juhendit!\n'
    printf 'Valiku tegemiseks sisesta vastava programmi number ja vajuta sisestusklahvi.\n'
    printf 'Valiku tühistamiseks vali juba valitud programm uuesti.\n'
    printf 'Väljumiseks vajuta CTRL+C\n\n'
    options=("${software[0]} ${opts[1]}" \
              "${software[1]} ${opts[2]}" \
              "${software[2]} ${opts[3]}" \
              "${software[3]} ${opts[4]}" \
              "${software[4]} ${opts[5]}" \
              "Valmis")
    select opt in "${options[@]}"
    do
        case $opt in
            
            "${software[0]} ${opts[1]}")
                choice 1
                break
                ;;
            "${software[1]} ${opts[2]}")
                choice 2
                break
                ;;
            "${software[2]} ${opts[3]}")
                choice 3
                break
                ;;
            "${software[3]} ${opts[4]}")
                choice 4
                break
                ;;
            "${software[4]} ${opts[5]}")
                choice 5
                break
                ;;
            "Valmis")
                break 2
                ;;
            *) printf '%s\n' 'Sellist valikut ei olnud';;
        esac
    done
done

for opt in "${!opts[@]}"
do
    if [[ ${opts[opt]} ]] && [[ "${software[opt-1]}" =~ butt ]]
    then
        install_butt
    elif [[ ${opts[opt]} ]]
    then
      apt_install ${software[opt-1]}
    fi
done

apt-get clean && apt-get autoremove
printf "Kõik valitud tarkvara on paigaldatud.\n" 
