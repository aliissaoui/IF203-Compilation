#!/bin/bash
( ./myc < $1 ) > tmp.txt;


echo "#include <stdio.h>
#include \"test.h\"

int main(){
" > tst/test.c

echo "#ifndef TEST_H
#define TEST_H
" > tst/test.h


grep -w int tmp.txt >> tst/test.h
grep -w float tmp.txt >> tst/test.h
grep -w void tmp.txt >> tst/test.h
grep -v -w float tmp.txt | grep -v -w int | grep -v -w void >> tst/test.c


echo "
return 0;
}" >> tst/test.c
echo "
#endif" >> tst/test.h
rm tmp.txt