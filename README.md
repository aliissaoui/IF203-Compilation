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

To compile all the files: Use the commande 'make' in the root repository

After the command make, use the command:
        ./compil.sh tst/test.myc
this will create two files in tst/ : test.c and test.h

You can delete unnecessary files, and created ones with the command 'make clean'.

* test.c and test.h are still not able to be compiled with gcc for the moment.