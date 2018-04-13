#!/bin/bash
# WMV Watch Script
export DISPLAY=:0
PATH=$PATH:/usr/local/bin

clear;

echo "watching banners-to-screenshots folder...";

fswatch -o -0 ../banners-to-screenshots | xargs -0 -n1 -I{} bash render_screenshots.sh

exit 0