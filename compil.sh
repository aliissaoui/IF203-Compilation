#!/bin/bash
( ./myc < $1 ) > tmp.txt;


echo "#include <stdio.h>
#include \"tst/test.h\"

void main(){
" > tst/test.c

echo "#ifndef TEST_H
#define TEST_H
" > tst/test.h


grep int tmp.txt >> tst/test.h
grep float tmp.txt >> tst/test.h
grep void tmp.txt >> tst/test.h
grep -v float tmp.txt | grep -v int | grep -v void >> tst/test.c


echo "
}" >> tst/test.c
echo "
#endif TEST_H" >> tst/test.h
rm tmp.txt