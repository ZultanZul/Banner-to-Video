#!/bin/bash
# WMV Watch Script
export DISPLAY=:0
PATH=$PATH:/usr/local/bin

clear;

echo "watching banners-to-videos folder...";

fswatch -o -0 ../banners-to-videos | xargs -0 -n1 -I{} bash render_videos.sh

#exit 0