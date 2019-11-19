#!/bin/bash
make clean && make        
( ./myc < $1 ) > tmp.txt

file=$(echo $1 | sed -e "s/.myc//g")
inc=$(echo $file | sed -e "s/tst\///g" )

echo "#include <stdio.h>
#include \"$inc.h\"
" > $file.c


echo "#ifndef TEST_H
#define TEST_H
" > $file.h

grep _.h_ tmp.txt | sed -e "s/_.h_//g" >> $file.h
grep -v _.h_ tmp.txt >> $file.c


echo "
return 0;
}" >> $file.c
echo "
#endif" >> $file.h

gcc $file.c -o $file