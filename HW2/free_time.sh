#!/bin/sh

#search the freetime from selected_time.txt and store them in the 'free_time_arr'

free_time_arr=""
free_time_arr=$(cat "selected_time.txt" | awk ' BEGIN { FS="," } { if(NF<=2) { printf("%s ", $1); } } ')

#use the free_time_arr to search all the class with that time, with O(MN) time complexity where M is the # of element in free_time-arr and N is the #of row in class_data.txt

touch "show_free.txt"

line=$(wc -l < "time_data.txt")

db=$(cat "time_data.txt" | awk -v cur_free="$free_time_arr" 'BEGIN { FS="," } {   } ')

cnt=0
while true;
do
    cnt+=1
    echo "$cnt"


    if [ $cnt -eq $line ];
    then
        break
    fi
done


