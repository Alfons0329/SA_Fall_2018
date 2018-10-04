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
parsed_first="parsed_json.txt"
parsed_second="time_to_cos.txt"
data_base="db.txt"

#use the  , : } as file delimitor
cat $json_file | awk ' BEGIN { FS="[,;}{:]" } { for( nf_cnt=0; nf_cnt<NF; nf_cnt++ ){ if( $(nf_cnt)~/"cos_time"/) { printf("%s", $(nf_cnt+1)) } else if( $(nf_cnt)~/"cos_ename"/){ print ",", $(nf_cnt+1) } } } ' > $parsed_first
cat $parsed_first | sed  's/\"//g; s/\-/\,/g' > $parsed_second
cat $parsed_second | awk 'BEGIN { FS="[,\n]"; RS="" } {  for( nf_cnt=0; nf_cnt<NF; nf_cnt++ ){ if($nf_cnt ~/^[1-9].*/){ print "time: " $nf_cnt } } }'

