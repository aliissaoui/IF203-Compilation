all		:	myc

myc.tab.h myc.tab.c :	src/myc.y
			bison -v -d src/myc.y

lex.yy.c	:	src/myc.l myc.tab.h
			flex src/myc.l

myc		:	lex.yy.c myc.tab.c src/Table_des_symboles.c src/Table_des_chaines.c src/Attribute.c
			gcc -o myc lex.yy.c myc.tab.c src/Attribute.c src/Table_des_symboles.c src/Table_des_chaines.c

clean		:
			rm -f lex.yy.c *.o myc.tab.h myc.tab.c myc *~ myc.output a.out
			rm -f tst/*.c tst/*.h tst/tst tst/tst_if tst/tst_if_else tst/tst_while tst/rec tst/fibo
			rm -f tst/fun_diff_param tst/fun_same_param tst/fun_two_params tst/fun_without_param tst/point_decl tst/point_aff
