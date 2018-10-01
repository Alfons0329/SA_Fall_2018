# SAHW2 Notes
## Problem 1 Steps
* First using `ls -A -R -l` to list all the file details recursively where the result will usually look like this 

```
./HW2:   (1 column)
total 8  (2 column)
-rw-rw-r-- 1 alfons alfons  42  十   1 16:19 2-1.sh (9 column)
-rw-rw-r-- 1 alfons alfons  42  十   1 16:19 2-1.sh (9 column)
-rw-rw-r-- 1 alfons alfons 145  十   1 17:12 HW2.md (9 column)
```
the #NF(number of fields) whill be 1 2 and 9, so we need the output field with 9 or more number of fields

* Then we have to pipe out the previous result to awk
```sh
awk {if(NF >= 9) print(%s)} # only output the result with filed >= 9 column from the piped data
```
ls -A -R -l | awk '{if(NF >= 9) {print -zsh} }' |  sort -n -k 5 -r 
