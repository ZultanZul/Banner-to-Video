#!/bin/bash
# WMV Watch Script
export DISPLAY=:0
PATH=$PATH:/usr/local/bin

clear;
echo "Stay awake...";

#Stop system from sleeping for 6 hours
caffeinate -dims -t 216000;

exit 0