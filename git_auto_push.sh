#!/bin/bash

message="[linux_auto] bug fixed"
echo $message
while getopts 'm:M:' opt
do
    case $opt in
        m|M)    message="$OPTARG";;
        *)      echo "[Error] illegal option input"
                exit;;
    esac
done

git add -u
git commit -m "$message"
git push
