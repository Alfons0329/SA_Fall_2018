#!/bin/sh
ls -ARlS | awk '{if(NF>=9) printf("%s \n", $0)}' | sort -nr -k 5 | awk 'BEGIN{ total_dir=0; total_file=0; total_size=0} { if($1~/^d.*/){++total_dir;} else if($1!/^d.*/){ total_size+=$5; ++total_file; if(total_file <= 5){ printf("%d:%d %s \n",total_file , $5, $9); } } } END{ printf("Dir num: %d \nFile num:%d \nTotal: %d ",total_dir, total_file, total_size);}'
#ls -ARlS | awk '{if(NF>=9) printf("%s \n", $0)}' | sort -nr -k 5 | awk -f akt.sh

