# SAHW2 Notes
## Problem 1 Steps
* First using `ls -ARl` to list all the file details recursively where the result will usually look like this 
```
-A stands for almost all, which will exclude . and ..
-R stands for recursively listing
-l stands for long listing data
-S stands for sort bysize
```
```
./HW2:   (1 column)
total 8  (2 column)
-rw-rw-r-- 1 alfons alfons  42  十   1 16:19 2-1.sh (9 column)
-rw-rw-r-- 1 alfons alfons  42  十   1 16:19 2-1.sh (9 column)
-rw-rw-r-- 1 alfons alfons 145  十   1 17:12 HW2.md (9 column)
```
```

* Sort accodrin to numerical size value
```sh
sort -nkr 5
```

* Processing the output, **exclude the directory itself** 
```sh

BEGIN 
{
    file=0;
    dir=0;
    sz=0;

{
    if($0~/^-.*/)
    {
        file++;
        sz+=$5; #5th column stands for file size
        if(file<=5)
        {
            printf("%d:%d %s\n", file, $5, $9) #list the top5 files
        }
    }
    else if($0~/^d.*/) 
    {
        dir++;
    }
}

END 
{
    printf("Dir num: %D \nFile num: %d\nTotal: %d \n", dir, file, sz);
}


```
## Problem2 steps

curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data
'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crs
name=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**’