#!/bin/sh

json_file="class.json"
parsed_first="cos_data.txt"
parsed_second="time_data.txt"
data_base="db.txt"
table=""
table_option=0
choose=0
#----------------------------------------------------gen timtable and data for buildlist------------------------------------------------------------#
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
    for i in 1 2 3 4 5 6 7
    do
        for j in "M" "N" "A" "B" "C" "D" "X" "E" "F" "G" "H" "Y" "I" "J" "K" "L"
        do
            echo $i$j"," >> $table
        done
    done
}

#----------------------------------------------------init------------------------------------------------------------#
init() {
    echo "class table does not exist "
    curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data \
    'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crs \
    name=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' >> class.json

    #----------------------------------------------------JSON parsing------------------------------------------------------------#
    #JSON parsing, parse cos_ename, cos_time(including location after - mark)
    #use this parsing function with awk and sed to output the value of certain field

    #use the " as file delimitor to extract whole class time
    cat $json_file | awk ' BEGIN { FS="[\"]" } { for( nf_cnt=0; nf_cnt<NF; nf_cnt++ ){ if( $(nf_cnt)~/cos_time/) { printf("%s", $(nf_cnt+2)) } else if( $(nf_cnt)~/cos_ename/){ print ",", $(nf_cnt+2) } } } ' > $parsed_first

    #remove some unnecessary things for better data processing
    cat $parsed_first | sed -E -i.bak 's/   //g' $parsed_first
    cat $parsed_first | sed -i.bak 's/317// ; s/--//' $parsed_first

    #rearrange the data, make 3CD5G-EC115 to 3CD5G,EC115 such that , can be used as th delimiter
    cat $parsed_first | sed -i.bak  's/\, /,/g ; s/-/,/g' $parsed_first

    #extract the time from 2G5CD-EC115,3IJK-EC222 to 2G 2C 5D 3I 3J 3K
    #cat $parsed_first | less
    rm -f $parsed_second
    cat $parsed_first | awk 'BEGIN {FS=","} {  for( nf_cnt=0; nf_cnt<=NF; nf_cnt++ ){ if(nf_cnt==NF){ printf("\n") } else if(nf_cnt && (nf_cnt % 2 == 1)){ printf("%s,",$nf_cnt) } } } ' | awk -f awk_parsetime.sh > $parsed_second

    paste -d'|' $parsed_first $parsed_second > $data_base
    cat $data_base | sed -i.bak 's/,,/,/g' $data_base

    table="selected_time.txt"
    gen_table

    table="selected_loc.txt"
    gen_table
    gen_menu

}

#--------------------------------------------------------write back db and check collision-------------------------------------#
#--------------------------------------------------------global variable for database processing-------------------------------#
sel=999 #current row of selected class
sel_name=""
sel_time=""
conf=0
quit=0
#--------------------------------------------------------global variable for database processing-------------------------------#
write_db() {
    cp "menu_db.txt" "menu_db_bk.txt"
    tr -d '\n' < "menu_db_bk.txt"
    sed -i.bak 's/\\//g' "menu_db_bk.txt"
    menu_db=$(cat "menu_db_bk.txt")

    sel=$(dialog --stdout --buildlist "Choose one" 200 200 200 $menu_db)

    #extracted the class name from the cos_name.txt with the selected number
    quit=$?
    if [ $quit -eq 1 ];
    then
        if [ $conf -eq 1 ];
        then
            #restore the backup if press cancel after class confliction since without this, class table will lost
            cp "selected_time_bk.txt" "selected_time.txt"
            cp "selected_loc_bk.txt" "selected_loc.txt"

            return
        else
            #press cancel without confliction, just return since the selected_time is successfully write back
            return
        fi
    fi

    rm -f "cur_selected.txt" "conflict.txt"
    touch "cur_selected.txt" "conflict.txt"

    table="cur_selected.txt"
    gen_table
    conf=0

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
        dialog --title "Conflict class as follows: " --textbox "conflict.txt" 200 200

        #back up the current one to prevent data loss if press cancel after class conflict
        cp "selected_time.txt" "selected_time_bk.txt"
        cp "selected_loc.txt" "selected_loc_bk.txt"
    else
        table="selected_time.txt"
        gen_table

        table="selected_loc.txt"
        gen_table

        #re-generate the menu for current legal class selection write back
        gen_menu

        #no conflict, write back to the class already selected
        for i in $sel
        do
            sel_time=$(cat "time_data.txt" | awk -v sel_row="$i" ' BEGIN { i=0 } { ++i; if(i==sel_row){ printf("%s", $0) } } ')
            sel_time_parsed=$(echo "$sel_time" | sed ' s/,/ /g ')

            sel_name=$(cat "cos_data.txt" | awk -v sel_row="$i" '  BEGIN { i=0; FS="," } { ++i; if(i==sel_row){ printf("%s", $NF) } } ')

            sel_loc=$(cat "cos_data.txt" | awk -v sel_row="$i" ' BEGIN { i=0; FS="," } { ++i; if(i==sel_row) { for(j=1;j<=NF;j++){ if(j%2==0){ printf("%s ",$j) } } } }')
            #check the time conflict write back to the current selected class
            for j in $sel_time_parsed
            do
                sed -E -i.bak "s/$j/$j,$sel_name/" "selected_time.txt"
                sed -E -i.bak "s/$j/$j,$sel_loc/" "selected_loc.txt"
            done

            #change the menu_db from off to on if the current selection is legal
            sed -i.bak "$i s/off/on/" "menu_db.txt"
        done
    fi
}

#-----------------------------------------------work flow-------------------------------------------------------------#
start_only=0
print_type=1
choose=4
while true;
do
    if [ -e "class.json" ];
    then
        echo "class table exists!"
    else
        init
    fi

    if [ "$choose" -eq 2 ];
    then
        break
    fi

    if [ "$choose" -eq 0 ]; #add class
    then
        write_db
    elif [ "$choose" -eq 3 ]; #option
    then

        get=$(dialog --title --stdout "Options" --menu "Choose one" 200 200 10 \
            1 "Normal with Class Name" 2 "Normal with Class Location" 3 "Less Important Time with Class Name" 4 "Less Important Time with Class Location" 5 "Course for Free Time" 6 "Partial Name Search" 7 "Partial Time Search" )
        if [ $? -ne 1 ];
        then
            print_type=$get
        fi
    fi

    if [ $quit -eq 0 ] && [ $conf -eq 1 ];
    then
        start_only=0 #nop since without this, cant run on macOS for debugging
    else
        if [ $print_type -eq 5 ];
        then
            sh "free_time.sh"
        elif [ $print_type -eq 6 ];
        then
            sh "partial_name.sh"
        elif [ $print_type -eq 7 ];
            sh "partial_time.sh"
        then
        else
            sh "print_table.sh" $print_type
            dialog --stdout  --title "Main menu" --ok-label "Add Class" --extra-button --extra-label "Option" --help-button --help-label "Exit" --textbox "show.txt" 200 200
            choose=$?
        fi
    fi
done
