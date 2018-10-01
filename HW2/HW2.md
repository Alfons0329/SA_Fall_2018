# SAHW2 Notes
## Problem 1 Steps
* First using `ls -ARl` to list all the file details recursively where the result will usually look like this 
```
-A stands for almost all, which will exclude . and ..
-R stands for recursively listing
-l stands for 
```
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
awk {if(NF >= 9) printf("%s \n", $0)} # only output the result with filed >= 9 column from the piped data
```

* Sort accodrin
```sh
sort -nkr 5
```

* Processing the output, **exclude the directory itself** 
```sh
{
    BEGIN {
    total_dir=0
    total_file=0
    total_size=0
}
{
    if($0~/^d.*/){
        printf(" %s is %d th directory \n", $0, ++total_dir)
    }
    else if($0!/^d.*/) {
        total_size += $5
        printf("%s is %d th file with size %d and total size %d \n", $0, ++total_file, $5, total_size)
    }
}

END {
    printf("Dir num: %d\n",total_dir)
    printf("File num: %d\n", total_file)
    printf("Total: %d", total_size)
}
}

```


