#!/bin/bash
# WMV Render Script
export DISPLAY=:0
PATH=$PATH:/usr/local/bin
COUNT_HTML=0
COUNT_JPG=0

#make directory if doesn't exist
mkdir -p ../jpg/

osascript -e 'quit app "/Applications/Google Chrome.app"';

sleep 5s; 

for d in ../banners-to-screenshots/*; do

  if [ -d "$d" ]; then

    open -a "Google Chrome" --args --kiosk

    sleep 3s;

    output=$(awk '{gsub(/\.*/,X,$0);gsub(/.*\-/,Y,$0);print $0}' <<<"$d");

    IFS='x' read -r -a size <<< "$output";
    IFS='/' read -r -a fullname <<< "$d";

    width="${size[0]}";
    height="${size[1]}";
    filename="${fullname[2]}";

    if [ -f "$d/index.html" ];
    then

      (( COUNT_HTML++ ))

      open -a "Google Chrome" $d/index.html

      sleep 0.100s;

      ffmpeg -vsync 2 -f avfoundation -i 2:0 -t 35 -c:v mpeg4 -vtag xvid -qscale:v 0 screen.avi;

      ### SCREENSHOT MAKER ######
      
      mkdir -p ../jpg/"$filename";
      for COUNT_JPG in $(seq -f "%02g" 1 30);
      do
        ffmpeg -y -i screen.avi -filter:v "crop=$width:$height:0:0" -ss 00:00:"$COUNT_JPG" -vframes 1 -q:v 2 '../jpg/'"$filename"'/'"$filename"'-'"$COUNT_JPG"'.jpg' </dev/null;
      done

      ### SCREENSHOT MAKER ######

      rm -f screen.avi

      screenshot_list="$screenshot_list"$'\n'"- $filename";

    mv $d ../completed/
    fi
  fi
done

osascript -e 'quit app "/Applications/Google Chrome.app"'

if [ ! -z "$screenshot_list" ] ;then

clear;

  echo "Created Screenshots for the following banners:";

  echo "$screenshot_list";

  echo $'\n'"Now watching banners-to-screenshots folder for changes...";

cat <<EOF >../_logs/$(date +"%d-%m-%Y_%H.%M.%S").txt
Created Screenshots for the following banners:
$screenshot_list

EOF

unset screenshot_list;

fi

exit 0