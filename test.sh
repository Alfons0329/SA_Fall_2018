#!/bin/sh
ls -ARl | awk 'BEGIN{ fn=0 }{if(NF >= 9){fn++}} END{printf("%d and %d \n",fn ,NR)}'
