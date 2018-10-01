#!/bin/sh
ls -ARlS | awk '{if(NF>=9) printf("%s \n", $0)}' | sort -nr -k 5 | awk -f akt.sh

#'BEGIN{ fn=0 }{if(NF >= 1){fn++; print $0, fn}} END{printf("%d and %d \n",fn ,NR)}'
#

