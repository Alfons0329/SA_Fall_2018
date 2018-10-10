#!/bin/sh
rm -f "show1.txt"

none='x'
point='.'
boundary='|'
blank_short='               '
blank_long='                  '
time_split='= '
long_split='=================== '

monday='Mon'
tuesday='Tue'
wednesday='Wed'
thursday='Thu'
friday='Fri'

name1
name2
name3
name4

#Use sed to make 13 character a line and next line, split with, 
parse_name() {
    cp "selected_time.txt" "show_name.txt"
    sed -E -i.bak 's/(.{13})/\1\,/g' "show_name.txt" 
}   

find_assign() {
    
}


print_firstline() {  
    firstline=$none$blank_short$monday$boundary$blank_short$tuesday$boundary$blank_short$wednesday$boundary$blank_short$thursday$boundary$blank_short$friday$boundary
    printf "$firstline\n" >> "show1.txt"
}

print_class() {
    line1=$1$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary
    line2=$1$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary
    line3=$1$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary
    line4=$1$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary$blank_long$boundary
    printf "$line1\n" >> "show1.txt"
    printf "$line2\n" >> "show1.txt"
    printf "$line3\n" >> "show1.txt"
    printf "$line4\n" >> "show1.txt"
}

print_splitline() {
    allsplit=$time_split$long_split$long_split$long_split$long_split$long_split$time_split
    printf "$allsplit\n" >> "show1.txt"
}

print_firstline
print_splitline
