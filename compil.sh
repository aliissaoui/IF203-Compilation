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

#script to write all the functions before main
treat_function()
{
i=0
while IFS= read -r line
do
    case "$line" in
       *_.f1_*)  printf "%s\n" "$line";
                i=1;;
       *_.f2_*) printf "_.f1_%s\n" "${line:5}";
                i=0;;
       *)  if [ $i -eq 1 ]; then
                printf "_.f1_%s\n" "$line"
            else
                printf "%s\n" "$line"
            fi ;;

    esac
done < tmp.txt
}

treat_function > tmp2.txt

grep _.h_ tmp2.txt | sed -e "s/_.h_//g" >> $file.h
grep _.f1_ tmp2.txt | sed -e "s/_.f1_//g" >> $file.c

echo "
int main(){" >> $file.c
grep -v _.h_ tmp2.txt | grep -v _.f1_  >> $file.c


echo "
return 0;
}" >> $file.c
echo "
#endif" >> $file.h
rm tmp2.txt tmp.txt
gcc $file.c -o $file
