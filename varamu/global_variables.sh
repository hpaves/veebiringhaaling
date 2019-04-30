#!/bin/bash
# Author: Henri Paves
# Version: 0.1
# Application: Repository for variables.
# Instructions: Not meant to be executed independently.
# How to reference: source global_variables.sh

user_homedir=/home/$linux_username
radio_dir=$user_homedir/raadio
public_dir_name=avalik

icecast_default_file_copy="$installer_directory/mallid/icecast.xml"
butt_template_file_location="$installer_directory/mallid/.buttrc"
liquidsoap_template_file_location="$installer_directory/mallid/raadio.liq"
youtubedl_template_file_location="$installer_directory/mallid/config"

icecast_conf_file_location="/etc/icecast2/icecast.xml"
butt_conf_file_location="$user_homedir/.buttrc"
liquidsoap_conf_file_location="/etc/liquidsoap/raadio.liq"
youtubedl_conf_file_location="$user_homedir/.config/youtube-dl/config"

website_base_folder="/var/www/html"
website_index_location="/var/www/html/index.*"
