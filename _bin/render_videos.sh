#!/bin/bash
# WMV Render Script
export DISPLAY=:0
PATH=$PATH:/usr/local/bin
COUNT_HTML=0
COUNT_GIF=0
COUNT_JPG=0
DSIZE[0]="large"
DSIZE[1]="medium"
DSIZE[2]="small"

#make directory if doesn't exist
mkdir -p ../mp4/
mkdir -p ../wmv/

osascript -e 'quit app "/Applications/Google Chrome.app"';

sleep 5s;

for d in ../banners-to-videos/*; do

  if [[ "${d}" == *.csv* ]]; then
    
    open -a "Google Chrome" --args --kiosk

    sleep 3s;

    while IFS='' read -r line || [[ -n "$line" ]]; do

      IFS=',' read -ra CELTRA <<< "$line";

      for i in "${DSIZE[@]}"
      do

        if [[ "${CELTRA[1]}" == *landscape* ]]; then
          open -a "Google Chrome" "${CELTRA[1]}"'&size='"$i";
        else
          open -a "Google Chrome" "${CELTRA[1]}"'&size='"$i"'&showBrowserBars=true';
        fi

        if [[ "${CELTRA[1]}" == *Tablet* ]]; then

	        if [ "$i" = "large" ]; then
	        	cwidth="850";
	        	cheight="1200";
	        elif [ "$i" = "medium" ]; then
	        	cwidth="820";
	        	cheight="1166";
	        else
	        	cwidth="650";
	        	cheight="1166";
	        fi

        elif [[ "${CELTRA[1]}" == *Phone* ]]; then

	    	  if [ "$i" = "large" ]; then
	        	cwidth="472";
	        	cheight="954";
	        elif [ "$i" = "medium" ]; then
	        	cwidth="434";
	        	cheight="882";
	        else
	        	cwidth="379";
	        	cheight="784";
	        fi

        fi

        if [[ "${CELTRA[1]}" == *landscape* ]]; then

          if [[ "${CELTRA[1]}" == *Tablet* ]]; then

            if [ "$i" = "large" ]; then
              cwidth="1414";
              cheight="843";
            elif [ "$i" = "medium" ]; then
              cwidth="1159";
              cheight="813";
            else
              cwidth="1159";
              cheight="653";
            fi

          elif [[ "${CELTRA[1]}" == *Phone* ]]; then

            if [ "$i" = "large" ]; then
              cheight="472";
              cwidth="954";
            elif [ "$i" = "medium" ]; then
              cheight="434";
              cwidth="882";
            else
              cheight="379";
              cwidth="784";
            fi

          fi

        fi

        #echo "crop=$cwidth:$cheight:2:0"

        rm -f screen.avi;

        sleep 2s;

        ffmpeg -vsync 2 -f avfoundation -i 2: -t 35 -c:v mpeg4 -vtag xvid -qscale:v 0 screen.avi </dev/null;

        ffmpeg -y -i screen.avi -filter:v "crop=$cwidth:$cheight:2:0" -qscale:v 0 -vcodec wmv2 '../wmv/'"${CELTRA[0]}"'_'"$i"'.wmv' </dev/null;

        ffmpeg -y -i screen.avi -filter:v "crop=$cwidth:$cheight:2:0" -c:v libx264 -crf 19 -preset slow -c:a aac -strict experimental -b:a 192k -ac 2 '../mp4/'"${CELTRA[0]}"'_'"$i"'.mp4' </dev/null;

        rm -f screen.avi

        wmv_list="$wmv_list"$'\n'"- ${CELTRA[0]}"'_'"$i"'.wmv';

      done
    
    done < "$d"

    osascript -e 'quit app "/Applications/Google Chrome.app"';

    mv $d ../completed/

  fi

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

      ffmpeg -vsync 2 -f avfoundation -i 2:0 -t 35 -c:v mpeg4 -vtag xvid -qscale:v 0 screen.avi </dev/null;

      ffmpeg -y -i screen.avi -filter:v "crop=$width:$height:0:0" -qscale:v 0 -vcodec wmv2 '../wmv/'"$filename"'.wmv' </dev/null;

      ffmpeg -y -i screen.avi -filter:v "crop=$width:$height:0:0" -c:v libx264 -crf 19 -preset slow -c:a aac -strict experimental -b:a 192k -ac 2 '../mp4/'"$filename"'.mp4' </dev/null;

      rm -f screen.avi

      wmv_list="$wmv_list"$'\n'"- $filename"'.wmv';

    fi

    if [ -f "$d/backup.gif" ]
    then

      (( COUNT_GIF++ ))

#HERE
    
      cp gif.html $d/gif.html

      open -a "Google Chrome" $d/gif.html

#HERE
      sleep 0.100s;

      ffmpeg -vsync 2 -f avfoundation -i 2:0 -t 35 -c:v mpeg4 -vtag xvid -qscale:v 0 screen.avi  </dev/null;

      ffmpeg -y -i screen.avi -filter:v "crop=$width:$height:0:0" -qscale:v 0 -vcodec wmv2 '../wmv/'"$filename"'_Gif.wmv' </dev/null;

      ffmpeg -y -i screen.avi -filter:v "crop=$width:$height:0:0" -c:v libx264 -crf 19 -preset slow -c:a aac -strict experimental -b:a 192k -ac 2 '../mp4/'"$filename"'_Gif.mp4' </dev/null;

      rm -f screen.avi
      rm -f $d/gif.html
      
      wmv_gif_list="$wmv_gif_list"$'\n'"- $filename"'_Gif.wmv';
    fi

    mv $d ../completed/

  fi
done

osascript -e 'quit app "/Applications/Google Chrome.app"'

if [ ! -z "$wmv_list" ] || [ ! -z "$wmv_gif_list" ];then

clear;

  echo "Created $COUNT_HTML HTML videos:";

  echo "$wmv_list";

  echo $'\n'"Created $COUNT_GIF Gif videos:";

  echo "$wmv_gif_list";

  echo $'\n'"Now watching banners-to-videos folder for changes...";

cat <<EOF >../_logs/$(date +"%d-%m-%Y_%H.%M.%S").txt
Created $COUNT_HTML HTML videos:
$wmv_list

Created $COUNT_GIF Gif videos:
$wmv_gif_list
EOF

unset wmv_list;
unset wmv_gif_list;

fi

exit 0