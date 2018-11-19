#!/bin/sh
f_name="six.txt"
if [ -e "$f_name" ];
then
    echo "666" >> "$f_name"
else
    touch "$f_name"
    echo "666" >> "$f_name"
fi
