#!/bin/bash

## delphicraft backup script
## note: run this script as sudo to access database and web folders
##   and rclone destination should be configured for the sudo user

## set directories
homedir='/home/ubuntu/bungee-server'
databases='/var/lib/mysql'
webroot='/var/www'
webserver='/etc/nginx/sites-available'

## set rclone destination
rclonedest='delphicraft'

## get date
today=$(date +"%Y_%m_%d")
today=${today//_/}

## back up servers
while read server megs; do

    echo 'zipping: '$server
    zip -qr $homedir'/backups/'$today'_'$server'.zip' $homedir'/servers/'$server -x "*/\.jar"

    echo 'backing up: '$server
    rclone copy $homedir'/backups/'$today'_'$server'.zip' $rclonedest':'$today'_server_'$server

    echo 'complete: '$server

done < $homedir/config/serverlist


## back up webroot
echo 'zipping: web'
zip -qr $homedir'/backups/'$today'_www.zip' $webroot

echo 'backing up: web'
rclone copy $homedir'/backups/'$today'_www.zip' $rclonedest':'$today'_www'

echo 'complete: web'


## back up webserver configs
echo 'zipping: webserver'
zip -qr $homedir'/backups/'$today'_webserver.zip' $webserver

echo 'backing up: webserver'
rclone copy $homedir'/backups/'$today'_webserver.zip' $rclonedest':'$today'_webserver'

echo 'complete: webserver'


## back up database
echo 'zipping: database'
for f in $databases/*; do
    if [[ -d "$f" && ! -L "$f" ]]; then
      zip -qur $homedir'/backups/'$today'_database.zip' $f
    fi
done

echo 'backing up: database'
rclone copy $homedir'/backups/'$today'_database.zip' $rclonedest':'$today'_database'

echo 'complete: database'


## clean up
rm $homedir'/backups/'*
echo 'backup folder cleaned up'
echo 'all backups complete'