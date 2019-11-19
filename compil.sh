#!/bin/bash
make clean && make        
( ./myc < $1 ) > tmp.txt


echo "#include <stdio.h>
#include \"test.h\"
" > tst/test.c


echo "#ifndef TEST_H
#define TEST_H
" > tst/test.h

grep _.h_ tmp.txt | sed -e "s/_.h_//g" >> tst/test.h
grep -v _.h_ tmp.txt >> tst/test.c


echo "
return 0;
}" >> tst/test.c
echo "
#endif" >> tst/test.h
rm tmp.txt

