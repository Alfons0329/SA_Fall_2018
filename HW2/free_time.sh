#!/bin/sh

#search the freetime from selected_time.txt and store them in the 'free_time_arr'

free_time_arr=""
free_time_arr=$(cat "selected_time.txt" | awk ' BEGIN { FS="," } { if(NF<=2) { printf("%s ", $1); } } ')

#use the free_time_arr to search all the class with that time, with O(MN) time complexity where M is the # of element in free_time-arr and N is the #of row in class_data.txt
rm -f "show_free.txt"
touch "show_free.txt"

line=$(wc -l < "time_data.txt")

for i in $(seq 1 $line);
do
    cur_time=$(cat "time_data.txt" | awk -v cur_row="$i" ' BEGIN { FS=","; i=0 } { ++i; if(i==cur_row){ for(j=1; j<=NF; ++j) printf("%s ",$j); } } ') #extract the time of current class
    nfcnt=$(cat "time_data.txt" | awk -v cur_row="$i" ' BEGIN { FS=","; i=0 } { ++i; if(i==cur_row){ printf("%d",NF-1) } } ')
    free_class=$(cat "cos_data.txt" | awk -v cur_row="$i" ' BEGIN { FS=","; i=0 } { ++i; if(i==cur_row){ printf("%s",$0) } } ')

    for j in $cur_time
    do
        for k in $free_time_arr
        do
            if [ $j = $k ];
            then
                let  "nfcnt-=1" > /dev/null
            fi
        done
    done

    if [ $nfcnt -eq 0 ];
    then
        echo "$free_class" >> "show_free.txt"
    fi
done

sed -i.bak 's/,,/,/g' "show_free.txt"
dialog --title "Available free time classes as follows: " --textbox "show_free.txt" 200 200
