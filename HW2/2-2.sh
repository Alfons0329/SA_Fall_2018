#!/bin/sh
#unit test: can crawl the course table, 1002 ok
if [ -e "class.json" ]; #check if the course exists
then
    echo "Course table exists \n"
else
    echo "Course table does not exist \n"
    curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data \
    'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crs \
    name=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' >> class.json
fi

#JSON parsing, parse cos_ename, cos_time(including location after - mark)
#use this parsing function with awk and sed to output the value of certain field
function get_json_value()
{
    local json_file=$1
    local c_ename="cos_ename"
    local c_time="cos_time"

    local parsed_first="paserd_json.txt"

    #use the  , : } as file delimitor
    cat $json_file | awk ' BEGIN {FS="[,;}{:]"} { for( nf_cnt=0; nf_cnt<NF; nf_cnt++ ){ if( $(nf_cnt)~/"cos_ename"/) { printf("course ename: %s", $(nf_cnt+1)) } else if( $(nf_cnt)~/"cos_time"/){ print " | time:  ", $(nf_cnt+1) } } }' > $parsed_first
    #printf("course name %d, course time and location %d \n")
}

get_json_value class.json
