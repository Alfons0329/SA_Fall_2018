#!/bin/sh
rm -f "show_partial_time.txt"
echo "" > "show_partial_time.txt"
substr=$(dialog --inputbox --stdout "Input a substring of time to search: " 200 200 2)
subtime=$(echo "$substr" | awk -f "awk_parsetime_pt.sh")
line=$(wc -l < "time_data.txt")

for i in $(seq 1 $line);
do
    cur_time=$(cat "time_data.txt" | awk -v cur_row="$i" ' BEGIN { FS=","; i=0 } { ++i; if(i==cur_row){ for(j=1; j<=NF; ++j) printf("%s ",$j); } } ') #extract the time of current class
    nfcnt=$(echo "$subtime" | awk ' { FS=" " } { printf("%d",NF) } ')
    free_class=$(cat "cos_data.txt" | awk -v cur_row="$i" ' BEGIN { FS=","; i=0 } { ++i; if(i==cur_row){ printf("%s",$0) } } ')

    for j in $cur_time
    do
        for k in $subtime
        do

           # echo "j $j k $k name $free_class"
            if [ $j = $k ];
            then
                let "nfcnt-=1"
            fi
        done
    done

    if [ $nfcnt -eq 0 ];
    then
        echo "$free_class" >> "show_partial_time.txt"
    fi
done

sed -i.bak 's/,,/,/g' "show_partial_time.txt"
dialog --title "Classes that matched for the input time \"$subtime\" : " --textbox "show_partial_time.txt" 200 200
