sel_name=""
sel_time=""
sel_time_parsed=""

write_db() {
    #extracted the course name from the cos_name.txt with the selected number
    #``sel_name=$(cat "cos_data.txt" | awk ' BEGIN { i=0 } { ++i; if(i==$sel){ printf("%s", $NF) } } ')
    for i in "$sel"
    do
        echo "Selected row is ","$i"

        sel_time=$(cat "time_data.txt" | awk -v sel_row="$i" ' BEGIN { i=0 } { ++i; if(i==sel_rowl){ printf("%s", $0) } } ')
        sel_time_parsed=$(echo "$sel_time" | sed ' s/,/ /g ')

        echo "sel time parsed ", "$sel_time_parsed" | less

        sel_name=$(cat "cos_data.txt" | awk -v sel_row="$i" '  BEGIN { i=0; FS="," } { ++i; if(i==sel_rowl){ printf("%s", $NF) } } ')

        echo "sel name " , "$sel_name" | less

        #change the menu_db from off to on
        sed -E -i.bak "s/off/on/$i" "menu_db.txt"

        #change the selected time from no to yes and write the class name into it
        for j in "$sel_time_parsed"
        do
            sed -E -i.bak "s/"$j",no/"$j","$sel_name"/1" "selected_time.txt"
        done

    done

}