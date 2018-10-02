#!/bin/sh
ls -ARlS | sort -nrk 5 | awk 'BEGIN{file=0; dir=0; sz=0;} { if($0~/^-.*/) {file++; sz+=$5;if(file<=5) {printf("%d:%d %s\n", file, $5, $9)}} else if($0~/^d.*/){dir++;} } END{ printf("Dir num: %d \nFile num: %d \nTotal: %d \n",dir, file, sz) }'
