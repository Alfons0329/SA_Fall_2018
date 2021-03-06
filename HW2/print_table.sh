#!/bin/sh
rm -f "show.txt"

#------------------------------------------global variables---------------------------------------------#
none="x"
point='.'
boundary="|" #1 + class name 13 + blank_short
blank_short="  "
blank_long="            " #day + 12 + blank_short
time_split="=  " #1 + 2
long_split="==============  " #12 + 2

monday="Mon"
tuesday="Tue"
wednesday="Wed"
thursday="Thu"
friday="Fri"
saturday=""
sunday=""

thistime=""
to_cat="final_show.txt"
#------------------------------------------global variables---------------------------------------------#

#Use sed to make 13 character a line and next line, split with ',' as delimiter
gen_table() {
    rm -f "empty_time.txt"
    touch "empty_time.txt"
    for i in 1 2 3 4 5 6 7
    do
        for j in "M" "N" "A" "B" "C" "D" "X" "E" "F" "G" "H" "Y" "I" "J" "K" "L"
        do
            echo $i$j >> "empty_time.txt"
        done
    done
}

parse_name() {
    cp "selected_time.txt" "show_name_tmp.txt"
    cp "selected_loc.txt" "show_loc_tmp.txt"

    #remove the time to merge later
    sed -E -i.bak 's/[1-9][A-Z],//g' "show_name_tmp.txt"
    sed -E -i.bak 's/[1-9][A-Z],//g' "show_loc_tmp.txt"

    #split the string every 13 character long
    sed -E -i.bak 's/(.{13})/\1\,/g' "show_name_tmp.txt"
    sed -E -i.bak 's/(.{13})/\1\,/g' "show_loc_tmp.txt"

    #padding the white space
    cat "show_name_tmp.txt" | awk -f splitfill.sh > "show_name_processed.txt"
    cat "show_loc_tmp.txt" | awk -f splitfill.sh > "show_loc_processed.txt"

    #merge time and the processed(padded with white space here)
    paste -d',' "empty_time.txt" "show_name_processed.txt" > "final_show.txt"
    paste -d',' "empty_time.txt" "show_loc_processed.txt" > "final_show_loc.txt"
}

#auery according to the selected time and put in what to print
find_assign() {
    #monday
    to_put=$(cat $to_cat | awk -v sel_row="1$thistime" ' BEGIN{ FS="," } { if($1~sel_row){ printf("%s,%s,%s,%s", $2, $3, $4, $5) } } ')

    name1=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($1)==13){ print $1; } else{ print"x.           " } }')
    name2=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($2)==13){ print $2; } else{ print".            " } }')
    name3=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($3)==13){ print $3; } else{ print".            " } }')
    name4=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($4)==13){ print $4; } else{ print".            " } }')

    #tuesday
    to_put=$(cat $to_cat | awk -v sel_row="2$thistime" ' BEGIN{ FS="," } { if($1~sel_row){ printf("%s,%s,%s,%s", $2, $3, $4, $5) } } ')

    name5=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($1)==13){ print $1; } else{ print"x.           " } }')
    name6=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($2)==13){ print $2; } else{ print".            " } }')
    name7=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($3)==13){ print $3; } else{ print".            " } }')
    name8=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($4)==13){ print $4; } else{ print".            " } }')

    #wednesday
    to_put=$(cat $to_cat | awk -v sel_row="3$thistime" ' BEGIN{ FS="," } { if($1~sel_row){ printf("%s,%s,%s,%s", $2, $3, $4, $5) } } ')

    name9=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($1)==13){ print $1; } else{ print"x.           " } }')
    name10=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($2)==13){ print $2; } else{ print".            " } }')
    name11=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($3)==13){ print $3; } else{ print".            " } }')
    name12=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($4)==13){ print $4; } else{ print".            " } }')

    #thursday
    to_put=$(cat $to_cat | awk -v sel_row="4$thistime" ' BEGIN{ FS="," } { if($1~sel_row){ printf("%s,%s,%s,%s", $2, $3, $4, $5) } } ')

    name13=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($1)==13){ print $1; } else{ print"x.           " } }')
    name14=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($2)==13){ print $2; } else{ print".            " } }')
    name15=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($3)==13){ print $3; } else{ print".            " } }')
    name16=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($4)==13){ print $4; } else{ print".            " } }')

    #friday
    to_put=$(cat $to_cat | awk -v sel_row="5$thistime" ' BEGIN{ FS="," } { if($1~sel_row){ printf("%s,%s,%s,%s", $2, $3, $4, $5) } } ')

    name17=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($1)==13){ print $1; } else{ print"x.           " } }')
    name18=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($2)==13){ print $2; } else{ print".            " } }')
    name19=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($3)==13){ print $3; } else{ print".            " } }')
    name20=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($4)==13){ print $4; } else{ print".            " } }')

    #for less important time, more to print, default no print
    name21=""
    name22=""
    name23=""
    name24=""
    name25=""
    name26=""
    name27=""
    name28=""

    if [ $print_type -ge 3 ]; #extended time table, assign saturday and sunday
    then
        #saturday
        to_put=$(cat $to_cat | awk -v sel_row="6$thistime" ' BEGIN{ FS="," } { if($1~sel_row){ printf("%s,%s,%s,%s", $2, $3, $4, $5) } } ')

        name21=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($1)==13){ print $1; } else{ print"x.           " } }')
        name22=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($2)==13){ print $2; } else{ print".            " } }')
        name23=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($3)==13){ print $3; } else{ print".            " } }')
        name24=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($4)==13){ print $4; } else{ print".            " } }')


        #sunday
        to_put=$(cat $to_cat | awk -v sel_row="7$thistime" ' BEGIN{ FS="," } { if($1~sel_row){ printf("%s,%s,%s,%s", $2, $3, $4, $5) } } ')

        name25=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($1)==13){ print $1; } else{ print"x.           " } }')
        name26=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($2)==13){ print $2; } else{ print".            " } }')
        name27=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($3)==13){ print $3; } else{ print".            " } }')
        name28=$(echo "$to_put" | awk 'BEGIN{ FS="," }{ if(length($4)==13){ print $4; } else{ print".            " } }')
    fi
}


print_firstline() {
    #extended time table, add saturday and sunday
    if [ $print_type -ge 3 ];
    then
        saturday="Sat"
        sunday="Sun"
        firstline=$none$blank_short$point$monday$blank_long$point$tuesday$blank_long$point$wednesday$blank_long$point$thursday$blank_long$point$friday$blank_long$point$saturday$blank_long$point$sunday$blanklong
    else
        firstline=$none$blank_short$point$monday$blank_long$point$tuesday$blank_long$point$wednesday$blank_long$point$thursday$blank_long$point$friday$blank_long
    fi

    printf "$firstline\n" >> "show.txt"
}

print_class() {
    #if to print less time, add sat sun and MNXY
    if [ $print_type -ge 3 ];
    then
        line1=$thistime$blank_short$boundary$name1$blank_short$boundary$name5$blank_short$boundary$name9$blank_short$boundary$name13$blank_short$boundary$name17$blank_short$boundary$name21$blank_short$boundary$name25$blank_short$boundary
        line2=$point$blank_short$boundary$name2$blank_short$boundary$name6$blank_short$boundary$name10$blank_short$boundary$name14$blank_short$boundary$name18$blank_short$boundary$name22$blank_short$boundary$name26$blank_short$boundary
        line3=$point$blank_short$boundary$name3$blank_short$boundary$name7$blank_short$boundary$name11$blank_short$boundary$name15$blank_short$boundary$name19$blank_short$boundary$name23$blank_short$boundary$name27$blank_short$boundary
        line4=$point$blank_short$boundary$name4$blank_short$boundary$name8$blank_short$boundary$name12$blank_short$boundary$name16$blank_short$boundary$name20$blank_short$boundary$name24$blank_short$boundary$name28$blank_short$boundary
    else
        line1=$thistime$blank_short$boundary$name1$blank_short$boundary$name5$blank_short$boundary$name9$blank_short$boundary$name13$blank_short$boundary$name17$blank_short$boundary
        line2=$point$blank_short$boundary$name2$blank_short$boundary$name6$blank_short$boundary$name10$blank_short$boundary$name14$blank_short$boundary$name18$blank_short$boundary
        line3=$point$blank_short$boundary$name3$blank_short$boundary$name7$blank_short$boundary$name11$blank_short$boundary$name15$blank_short$boundary$name19$blank_short$boundary
        line4=$point$blank_short$boundary$name4$blank_short$boundary$name8$blank_short$boundary$name12$blank_short$boundary$name16$blank_short$boundary$name20$blank_short$boundary
    fi

    printf "$line1\n" >> "show.txt"
    printf "$line2\n" >> "show.txt"
    printf "$line3\n" >> "show.txt"
    printf "$line4\n" >> "show.txt"
}

print_splitline() {
    #if print less time, add longer split line
    if [ $print_type -ge 3 ];
    then
        allsplit=$time_split$long_split$long_split$long_split$long_split$long_split$long_split$long_split$time_split
    else
        allsplit=$time_split$long_split$long_split$long_split$long_split$long_split$time_split
    fi
    printf "$allsplit\n" >> "show.txt"
}

#----------------------------------------------------init------------------------------------------------------------#
print_type=$1
gen_table
parse_name
print_firstline
#----------------------------------------------------different type of print-----------------------------------------#

if [ $1 -eq 1 ]; #type 1, normal time with class name
then
    for i in 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L'
    do
        thistime=$i
        to_cat="final_show.txt"
        find_assign
        print_class
        print_splitline
    done
elif [ $1 -eq 2 ]; #type 2 normal time with class location
then
    for i in 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L'
    do
        thistime=$i
        to_cat="final_show_loc.txt"
        find_assign
        print_class
        print_splitline
    done
elif [ $1 -eq 3 ]; #type 3 extended time with class name
then
     for i in 'M' 'N' 'A' 'B' 'C' 'D' 'X' 'E' 'F' 'G' 'H' 'Y' 'I' 'J' 'K' 'L'
     do
        thistime=$i
        to_cat="final_show.txt"
        find_assign
        print_class
        print_splitline
     done
elif [ $1 -eq 4 ]; #type 4 extended time with class location
then
    for i in 'M' 'N' 'A' 'B' 'C' 'D' 'X' 'E' 'F' 'G' 'H' 'Y' 'I' 'J' 'K' 'L'
    do
        thistime=$i
        to_cat="final_show_loc.txt"
        find_assign
        print_class
        print_splitline
    done
else
    for i in 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L'
    do
        thistime=$i
        to_cat="final_show.txt"
        find_assign
        print_class
        print_splitline
    done
fi

# 0 3 2

