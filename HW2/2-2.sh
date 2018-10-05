#!/bin/sh
#unit test: can crawl the course table, 1002 ok
if [ -e "class.json" ]; #check if the course exists
then
    echo "Course table exists "
else
    echo "Course table does not exist "
    curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data \
    'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crs \
    name=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' >> class.json
fi

#JSON parsing, parse cos_ename, cos_time(including location after - mark)
#use this parsing function with awk and sed to output the value of certain field

json_file="class.json"
parsed_first="cos_data.txt"
parsed_second="time_data.txt"
data_base="db.txt"
time_selected="selected_time.txt"

#use the  , : } as file delimitor
cat $json_file | awk ' BEGIN { FS="[\"]" } { for( nf_cnt=0; nf_cnt<NF; nf_cnt++ ){ if( $(nf_cnt)~/cos_time/) { printf("%s", $(nf_cnt+2)) } else if( $(nf_cnt)~/cos_ename/){ print ",", $(nf_cnt+2) } } } ' > $parsed_first
#cat $parsed_first | less
#dunno wtf cause 317 in it
cat $parsed_first | sed -i.bak 's/317// ; s/--/ /' $parsed_first
cat $parsed_first | sed -i.bak  's/\, /,/g ; s/-/,/g' $parsed_first
#extract the time from 2G5CD to 2G 5C 5D got problem here
#cat $parsed_first | less
cat $parsed_first | awk 'BEGIN {FS=","} {  for( nf_cnt=0; nf_cnt<=NF; nf_cnt++ ){ if(nf_cnt==NF){ printf("\n") } else if(nf_cnt && (nf_cnt % 2 == 1)){ printf("%s,",$nf_cnt) } } } ' #| awk -f awk_parsetime.sh > "awk_time.txt"
#remove the - from cos_data
#cat $parsed_first | sed -i.bak 's/^[0-9].*\-//g' $parsed_first

#paste $parsed_first $parsed_second > $data_base

for i in 1 2 3 4 5 6
do
    for j in "M" "N" "A" "B" "C" "D" "X" "E" "F" "G" "H" "I" "J" "K" "L"
    do
        echo $i$j",no" >> $time_selected
    done
done

