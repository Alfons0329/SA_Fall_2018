#!/bin/sh
#ls -ARlS | awk '{if(NF>=9) printf("%sn", $0)}' | sort -nr -k 5 | awk -f akt.sh
ls -ARlS | awk '{if(NF>=9) printf("%sn", $0)}' | sort -nr -k 5 | awk 'BEGIN { total_dir=0 total_file=0 total_size=0 }{ if($0~/^d.*/){ #printf(" %s is %d th directoryn", $0, ++total_dir) ++total_dir} else if($0!/^d.*/){total_size += $5 if(total_file < 5){ #printf("%s is %d th big file with size %d and total size %dn", $0, ++total_file, $5, total_size) printf("%d:%d %sn", ++total_file, $5, $9)}}} END { printf("Dir num: %d\nFile num:%d\nTotal: %d ",total_dir, total_file, total_size)}'



