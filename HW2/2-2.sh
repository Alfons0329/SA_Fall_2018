#!/bin/sh
#----------------------------------------------------JSON crawling------------------------------------------------------------#

json_file="class.json"
parsed_first="cos_data.txt"
parsed_second="time_data.txt"
data_base="db.txt"
table
gen_menu() {
    #processed with tag item for buildlist
    cat $data_base | awk ' BEGIN { FS="|"; i=0 } { printf("%d-%s off\\\n",++i , $1) } ' > "menu_db.txt"
    #display the menu dialog and remove space if use parameter
    sed -i.bak 's/ /_/g' "menu_db.txt"
    sed -i.bak 's/_off/ off/g' "menu_db.txt"
    sed -i.bak 's/-/ /g' "menu_db.txt"
}

gen_table() {
    rm -f $table
    for i in 1 2 3 4 5 6
    do
        for j in "M" "N" "A" "B" "C" "D" "X" "E" "F" "G" "H" "Y" "I" "J" "K" "L"
        do
            echo $i$j"," >> $table
        done
    done
}

init() {
    echo "Course table does not exist "
    curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data \
    'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crs \
    name=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' >> class.json

    #----------------------------------------------------JSON parsing------------------------------------------------------------#
    #JSON parsing, parse cos_ename, cos_time(including location after - mark)
    #use this parsing function with awk and sed to output the value of certain field


    #use the " as file delimitor to extract whole class time
    cat $json_file | awk ' BEGIN { FS="[\"]" } { for( nf_cnt=0; nf_cnt<NF; nf_cnt++ ){ if( $(nf_cnt)~/cos_time/) { printf("%s", $(nf_cnt+2)) } else if( $(nf_cnt)~/cos_ename/){ print ",", $(nf_cnt+2) } } } ' > $parsed_first

    #remove some unnecessary things, and remove the tab
    cat $parsed_first | sed -E -i.bak 's/   //g' $parsed_first
    cat $parsed_first | sed -i.bak 's/317// ; s/--//' $parsed_first

    #rearrange the data
    cat $parsed_first | sed -i.bak  's/\, /,/g ; s/-/,/g' $parsed_first

    #extract the time from 2G5CD-EC115,3IJK-EC222 to 2G 2C 5D 3I 3J 3K
    #cat $parsed_first | less
    rm -f $parsed_second
    cat $parsed_first | awk 'BEGIN {FS=","} {  for( nf_cnt=0; nf_cnt<=NF; nf_cnt++ ){ if(nf_cnt==NF){ printf("\n") } else if(nf_cnt && (nf_cnt % 2 == 1)){ printf("%s,",$nf_cnt) } } } ' | awk -f awk_parsetime.sh > $parsed_second

    paste -d'|' $parsed_first $parsed_second > $data_base
    cat $data_base | sed -i.bak 's/,,/,/g' $data_base

    table="selected_time.txt"
    gen_table
    gen_menu
}

#--------------------------------------------------------write back db and check collision-------------------------------------#

sel=999 #current selected course
conf=0 #is collided or not
sel_name=""
sel_time=""
quit=0
write_db() {
    cp "menu_db.txt" "menu_db_bk.txt"
    tr -d '\n' < "menu_db_bk.txt"
    sed -i.bak 's/\\//g' "menu_db_bk.txt"
    menu_db=$(cat "menu_db_bk.txt")
    echo "cast menudb"

    sel=$(dialog --stdout --buildlist "Choose one" 200 200 200 $menu_db)
    #extracted the course name from the cos_name.txt with the selected number
    if [ $? -eq 1 ];
    then
        echo "Quit"
        return
    fi


    rm -f "cur_selected.txt" "conflict.txt"
    touch "cur_selected.txt" "conflict.txt"

    table="cur_selected.txt"
    gen_table
    conf=0

    table="selected_time.txt"
    gen_table

    #push all the current selected data to "cur_selected.txt" ex: 3C,Math,English
    for i in $sel
    do
        sel_time=$(cat "time_data.txt" | awk -v sel_row="$i" ' BEGIN { i=0 } { ++i; if(i==sel_row){ printf("%s", $0) } } ')
        sel_time_parsed=$(echo "$sel_time" | sed ' s/,/ /g ')

        sel_name=$(cat "cos_data.txt" | awk -v sel_row="$i" '  BEGIN { i=0; FS="," } { ++i; if(i==sel_row){ printf("%s", $NF) } } ')
        #check the time conflict write back to the current selected class
        for j in $sel_time_parsed
        do
            sed -E -i.bak "s/$j/$j,$sel_name/" "cur_selected.txt"
        done

    done

    #cat "cur_selected.txt" | less

    #iterate through the current selected class and check whether the conflict exists
    cat "cur_selected.txt" | awk ' BEGIN { FS=","; conflict=0 } { if(NF>3){ conflict=1; printf("%s\n", $0) } } ' > "conflict.txt"

    #the conflict data is not null, conflict happens
    if [ -s "conflict.txt" ];
    then
        conf=1 #is conflicted
    fi

    #if there is a conflict, show the data of conflicted classes
    if [ $conf -eq 1 ];
    then
        conflicted_class=$(cat "conflict.txt")
        echo "Class conflicts"
        echo $conflicted_class | less
    else

        gen_menu
        #no conflict, write back to the class already selected
        for i in $sel
        do
            sel_time=$(cat "time_data.txt" | awk -v sel_row="$i" ' BEGIN { i=0 } { ++i; if(i==sel_row){ printf("%s", $0) } } ')
            sel_time_parsed=$(echo "$sel_time" | sed ' s/,/ /g ')

            sel_name=$(cat "cos_data.txt" | awk -v sel_row="$i" '  BEGIN { i=0; FS="," } { ++i; if(i==sel_row){ printf("%s", $NF) } } ')

            #check the time conflict write back to the current selected class
            for j in $sel_time_parsed
            do
                sed -E -i.bak "s/$j/$j,$sel_name/" "selected_time.txt"
            done

            #change the menu_db from off to on if the current selection is legal
            #echo "$sel_name,$sel_time,replace with $i"
            sed -i.bak "$i s/off/on/" "menu_db.txt"
        done

        echo "Current time table"
        cat "selected_time.txt" | awk ' BEGIN { i=0 } { ++i; printf("%s | ",$0); if(i%16==0){ printf("\n\n") } }' | less
    fi
}

#-----------------------------------------------work flow-------------------------------------------------------------#
for i in 1 2 3 4
do
    if [ -e "class.json" ];
    then
        echo "Course table exists!"
    else
        rm -f "class.json"
        init
    fi
    write_db
    if [ $? -eq 1 ];
    then
        break
    fi
done


