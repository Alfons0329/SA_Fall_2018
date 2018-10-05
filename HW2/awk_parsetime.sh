BEGIN {
    i=0;
    j=0;
    k=0;

}
{
    split($0, char, "")
    # for(i=1; i<=length($0); i++)
    # {
    #     printf("char %c \n", char[i] <= "9" ? char[i] + 48 : char[i])
    # }
    printf("|")
    for(i=1; i<=length($0); i++)
    {
        # printf("i is now? %d value %c\n", i, char[i]);
        if(char[i]<="9" && char[i]>="0")
        {
            for(j=i+1; char[j]>"9"; j++)
            {
                printf("%s%s~",char[i],char[j])
            }
            i=j-1;
        }
    }
    printf("\n")
}

