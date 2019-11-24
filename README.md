#########################        COMPILATION PROJECT       ###########################

                            Saturday 16 November 2019

Project Coordinator: Janin David
Group:
        Ali Issaoui & Imad Boutgayout

#########################      Description       ##########################

In This project you will find two folders and a script 'compil.sh':
    src: Contains all the source files 
    tst: Contains a file to test: test.myc
         and will after compilation contain the files: test.c & test.h
    compil: necessary for the execution

#########################       Execution       ########################### 

- you can use the command:
        ./compil.sh tst/file.myc

this command will create tree files in tst/ : file.c and file.h test
"test" is the executable automatically generated with gcc compilation of file.c

- You can compile the compiler using the commande make.

- You can delete unnecessary files, and created ones with the command 'make clean'.

NB: you can use any file name .myc, the code generated and the executable named test.
Example:
        
        compilation:
                ./compil.sh tst/toto.myc => tst/toto.c + tst/toto.h + tst/test  
        Execution:
                ./tst/test