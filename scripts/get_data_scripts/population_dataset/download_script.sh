#!/bin/bash

#
#   Advanced Databases Project
#
#   Bash script used to download the full population dataset
#   Download will be done by parts each part represent a year
#   After this script is finished run the script "conversion_files_script.sh"
#   in order to be able to run python script on downloaded data
#
#   Author: Quentin GOMES DOS REIS
#

mkdir csv
mkdir downloaded

for i in {1948..2023}; do
    # HTTP headers are needed in order to be able to download something
    # Nothing will be downloaded if absent
    curl "http://data.un.org/Handlers/DownloadHandler.ashx?DataFilter=tableCode:22;refYear:$i&DataMartId=POP&Format=csv&c=1,2,3,6,8,10,12,14,15,16&s=_countryEnglishNameOrderBy:asc,refYear:desc,areaCode:asc" \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8' \
  -H 'Accept-Language: fr-FR,fr;q=0.6' \
  -H 'Connection: keep-alive' \
  -H 'Referer: http://data.un.org/Data.aspx?d=POP&f=tableCode%3a22' \
  -H 'Sec-GPC: 1' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36' \
  --compressed \
  --insecure \
  --output "./downloaded/$i.zip"
  echo "$i.zip"
  unzip -q "./downloaded/$i.zip" -d "./csv/$i" &
done
