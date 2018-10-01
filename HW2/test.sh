#!/bin/sh
#ls -ARlS | awk '{if(NF>=9) printf("%s \n", $0)}' | sort -nr -k 5 | awk -f akt.sh
ls -ARlS | awk '{if(NF>=9) printf("%s \n", $0)}' | sort -nr -k 5 | awk 'BEGIN { \
    total_dir=0 \
    total_file=0 \
    total_size=0 \
} \
{ \
    if($0~/^d.*/){ \
       #printf(" %s is %d th directory \n", $0, ++total_dir) \
        ++total_dir \
    } \
    else if($0!/^d.*/){ \
        total_size += $5 \
        if(total_file < 5){ \
           #printf("%s is %d th big file with size %d and total size %d \n", $0, ++total_file, $5, total_size) \
           printf("%d:%d %s \n", ++total_file, $5, $9) \
        } \
    } \
} \

END { \
    printf("Dir num: %d\n",total_dir) \
    printf("File num: %d\n", total_file) \
    printf("Total: %d", total_size) \
}'



