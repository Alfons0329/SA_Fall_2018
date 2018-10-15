#!/bin/sh
rm -f "show_partial.txt"
substr=$(dialog --inputbox --stdout "Input a substring of class to search: " 200 200 2)
cat "cos_data.txt" | grep $substr > "show_partial.txt"
dialog --title "Classes that matched for the input string \"$substr\" : " --textbox "show_partial.txt" 200 200
