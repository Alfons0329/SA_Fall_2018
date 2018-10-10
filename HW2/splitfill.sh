BEGIN { 
    FS="," 
} 
{ 
    for(nf_cnt=1; nf_cnt<=NF-1; ++nf_cnt)
    { 
        if(length(nf_cnt)<13)
        { 
            printf("%s", $nf_cnt); 
            for(j=13-length($nf_cnt) ;j>=0; --j)
            { 
                printf(" ");  
            }
            printf(",")
        } 
        else
        { 
            printf("%s,", $nf_cnt); 
        }
        # printf("NFCNT=[%d] NF=[%d],", nf_cnt, NF) 
    } 
    printf("\n");
    # printf("NF=[%d] \n", NF); 
}