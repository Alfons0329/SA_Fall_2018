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

