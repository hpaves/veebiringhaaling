#!/bin/bash
# Author: Henri Paves
# Version: 0.1
# Application: Repository for variables.
# Instructions: Not meant to be executed independently.
# How to reference: source global_variables.sh

user_homedir=/home/$linux_username
webcasting_user_group=veebiringhaaling

website_base_dir="/var/www/html"
website_index_location="$website_base_dir/index.php"

configuration_script_file_name=seadista_raadio.sh
playlist_refresh_script_file_name=v2rskenda_esitusloendeid.sh

# The three variables below are also staticly defined in v2rskenda_esitusloendeid.sh
# due to file access privilege and security reasons
public_dir_name=avalik
radio_dir_name=raadio
default_playlist_name=esitusloendid.txt
# end static duplicates

radio_dir=$user_homedir/$radio_dir_name
recording_dir_name=salvestused
sounds_folder_name=helid
music_dir_name=muusika
jingle_dir_name=teated
replay_dir_name=jarelkuulamine

icecast_default_file_copy="$installer_directory/mallid/icecast.xml"
butt_template_file_location="$installer_directory/mallid/.buttrc"
liquidsoap_template_file_location="$installer_directory/mallid/raadio.liq"
youtubedl_template_file_location="$installer_directory/mallid/config"

icecast_conf_file_location="/etc/icecast2/icecast.xml"
butt_conf_file_location="$user_homedir/.buttrc"
liquidsoap_conf_file_location="/etc/liquidsoap/raadio.liq"
youtubedl_conf_file_location="$user_homedir/.config/youtube-dl/config"

default_audio_file_name=vaikimisi.ogg

server_data_reminder_file_name=serveri_andmed.txt
youtube_archive_file_name=youtube_allalaadimiste_arhiiv.txt
replay_listing=jarelkuulamise_nimekiri.txt

default_stream_name=raadio
default_ogg_stream_name=raadio.ogg
default_mp3_stream_name=raadio
live_stream_name=otse-eeter
