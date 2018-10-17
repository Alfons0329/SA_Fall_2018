#!/bin/sh
rm -f "show_partial_name.txt"
substr=$(dialog --inputbox --stdout "Input a substring of class to search: " 200 200 )
cat "cos_data.txt" | grep $substr > "show_partial_name.txt"
sed -i.bak 's/,,/,/g' "partial_time.txt"
dialog --title "Classes that matched for the input string \"$substr\" : " --textbox "show_partial_name.txt" 200 200

