#!/bin/bash

message="[linux_auto] bug fixed"
while getopts 'm:M:' opt
do
    case $opt in
        m|M)    message="$OPTARG";;
        *)      echo "[Error] illegal option input"
                exit;;
    esac
done

echo $message
git add -u
git commit -m "$message"
git push
