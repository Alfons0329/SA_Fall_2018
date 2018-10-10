#!/bin/sh 
rm -f "show.txt"

#block width = 16 each

print_type=0
none="x"
point="."
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

thistime=""

name1="x."
name2="."
name3="."
name4="."

#Use sed to make 13 character a line and next line, split with, 
gen_table() {
    rm -f "empty_time.txt"
    touch "empty_time.txt"
    for i in 1 2 3 4 5 
    do
        for j in  "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L"
        do
            echo $i$j >> "empty_time.txt"
        done
    done
}

parse_name() {
    cp "selected_time.txt" "show_name_tmp.txt"
    #remove the time to merge later
    sed -E -i.bak 's/[1-9][A-Z],//g' "show_name_tmp.txt"
    #split the string every 13 character long
    sed -E -i.bak 's/(.{13})/\1\,/g' "show_name_tmp.txt"

    # rm -f "show_name_processed.txt"
    # touch "show_name_processed.txt"
    #padding the white space
    cat "show_name_tmp.txt" | awk -f splitfill.sh > "show_name_processed.txt"
    #printf("debug: %s i=[%d] NF=[%d]\n", $nf_cnt, i, NF) }
    paste -d',' "empty_time.txt" "show_name_processed.txt" > "final_show.txt"
    
}   

find_assign() {
    
    name1="x.           " # 2 + 11
    name2=".            " # 1 + 12
    name3=".            " # 1 + 12
    name4=".            " # 1 + 12

    to_put=$(cat "final_show.txt" | awk -v sel_row="$thistime" ' { if($0~/sel_row.*/) print $0 } ')
    
    cat "final_show.txt" | awk -v sel_row="$thistime" ' { if($0~/sel_row.*/) print $0 } '
    echo "$to_put" | sed 's/,/ /g'
    
    cnt=0
    for i in $to_put
    do
        case $cnt
            0 ) name1=$i ;;
            1 ) name2=$i ;;
            2 ) name3=$i ;;
            3 ) name4=$i ;;
        
        cnt=cnt+1
        esac
    done 
    echo "$name1, $name2, $name3, $name4"
}


print_firstline() {  
    firstline=$none$blank_short\
    $point$monday$blank_long\
    $point$tuesday$blank_long\
    $point$wednesday$blank_long\
    $point$thursday$blank_long\
    $point$friday$blank_long

    printf "$firstline\n" >> "show.txt"
}

print_class() {
    
    line1=$1$blank_short$boundary$name1$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary
    line2=$point$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary
    line3=$point$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary
    line4=$point$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary

    printf "$line1\n" >> "show.txt"
    printf "$line2\n" >> "show.txt"
    printf "$line3\n" >> "show.txt"
    printf "$line4\n" >> "show.txt"
}

print_splitline() {
    allsplit=$time_split$long_split$long_split$long_split$long_split$long_split$time_split
    printf "$allsplit\n" >> "show.txt"
}


gen_table
parse_name
print_firstline

for i in 1 2 3 4 5 
do
    for j in  "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L"
    do
        print_class $j
        print_splitline
    done
done
for i in  "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L"
do
    for j in 1 2 3 4 5
    do
        print_class $j
        print_splitline
    done 
done