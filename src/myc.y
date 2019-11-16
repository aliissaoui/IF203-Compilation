%code requires{
#include "src/Table_des_symboles.h"
#include "src/Attribute.h"
 }

%{
#include <stdio.h>
#include "src/Attribute.h"

extern int yylex();
extern int yyparse();

void yyerror (char* s) {
  printf ("%s\n",s);
}

int reg_count=0;
type current_type;

%}

%union { 
	attribute val;
}
%token <val> NUMI NUMF
%token TINT TFLOAT STRUCT
%token <val> ID
%token AO AF PO PF PV VIR
%token RETURN VOID EQ
%token <val> IF ELSE WHILE

%token <val> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR

%token END

%left DIFF EQUAL SUP INF       // low priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
 
%type <val> exp vir vlist typename aff var_decl type


%start prog  


%%


prog : block                  {}
;

block:
decl_list inst_list            {}
;

// I. Declarations

decl_list : decl decl_list     {}
| decl                         {}
|                              {} // we needed to add it to recognize file end.
;

decl: var_decl PV              {}
| struct_decl PV               {}
| fun_decl                     {}
;

// I.1. Variables
var_decl : type vlist          {}
;

// I.2. Structures
struct_decl : STRUCT ID struct {}
;

struct : AO attr AF            {}
;

attr : type ID                 {}
| type ID PV attr              {}

// I.3. Functions

fun_decl : type fun            {}
;

fun : fun_head fun_body        {}
;

fun_head : ID PO PF            {}
| ID PO params PF              {}
;

params: type ID vir params     {}
| type ID                      {}

vlist: ID vir vlist            {}
| ID                           {printf("%s;\n", $1 -> name);}
;

vir : VIR                      {printf("VIR\n");$$=$<val>-1; printf(",");}
;

fun_body : AO block AF         {}
;

// I.4. Types
type
: typename pointer             {}
| typename                     {}
;

typename

: TINT                          { current_type = INT;
                                  printf("int ");}

| TFLOAT                        { current_type = FLOAT;
                                  printf("float ");}

| VOID                          { current_type = TVOID;}

| STRUCT ID                     {}
;

pointer
: pointer STAR                 {}
| STAR                         {}
;


// II. Intructions

inst_list: inst PV inst_list   {}
| inst                         {}
|                              {}
;

inst:
  
  AO block AF                 {}
| aff                         {}
| ret                         {}
| cond                        {}
| loop                        {}
| PV                          {}
;


// II.1 Affectations

aff : ID EQ exp               {printf("%s = ri%d;\n", $1->name, $3->reg_number);}
| exp STAR EQ exp             {}
;


// II.2 Return
ret : RETURN exp              {}
| RETURN PO PF                {}
;

// II.3. Conditionelles
cond :
if bool_cond stat else stat   {}
|  if bool_cond stat          {}
;

stat:
AO block AF                   {}
;

;


bool_cond : PO exp PF         {}
;

if : IF                       {}
;

else : ELSE                   {}
;

// II.4. Iterations

loop : while while_cond inst  {}
;

while_cond : PO exp PF        {}

while : WHILE                 {}
;


// II.3 Expressions
exp
// II.3.0 Exp. arithmetiques
: MOINS exp %prec UNA         {}
| exp PLUS exp                { $$=plus_attribute($1,$3);
                                $$->reg_number = reg_count++;
                                printf( "ri%d = ri%d + ri%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);}
| exp MOINS exp               { $$=minus_attribute($1,$3);
                                $$->reg_number = reg_count++;
                                printf( "ri%d = ri%d - ri%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);}
| exp STAR exp                { $$=mult_attribute($1,$3);
                                $$->reg_number = reg_count++;
                                printf( "ri%d = ri%d * ri%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);}
| exp DIV exp                 { $$=div_attribute($1,$3);
                                $$->reg_number = reg_count++;
                                printf( "ri%d = ri%d / ri%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);}
| PO exp PF                   { $$=new_attribute();
                                $$->reg_number = reg_count++;
                                $$ = $2;
                                printf( "(ri%d);\n", $$->reg_number);}
| ID                          { $$=new_attribute(); 
                                $$->reg_number = reg_count++;
                                $$->name=$1; printf("ri%d = %s;\n", $$->reg_number, yylval.val->name);}
| NUMI                        { $$=new_attribute();
                                $$->reg_number = reg_count++;
                                $$->type_val = TINT;
                                $$->int_val = yylval.val -> int_val;
                                printf("int ri%d;\n", $$->reg_number);
                                printf("ri%d = %d;\n", $$->reg_number, yylval.val -> int_val);}
| NUMF                        { $$=new_attribute();
                                $$->reg_number = reg_count++;
                                $$->type_val = TFLOAT;
                                $$->float_val = yylval.val -> float_val;
                                printf("float ri%d;\n", $$->reg_number);
                                printf("ri%d = %f;\n", $$->reg_number, yylval.val -> float_val);}

// II.3.1 Déréférencement

| STAR exp %prec UNA          {}

// II.3.2. Booléens

| NOT exp %prec UNA           {}
| exp INF exp                 { $$ = new_attribute();
                                $$->reg_number = reg_count++;
                                $$ = $1 < $3;
                                printf("exp-> exp INF exp: %i < %i;\n", $1 -> int_val, $3 -> int_val);}
| exp SUP exp                 { $$ = new_attribute();
                                $$->reg_number = reg_count++;
                                $1 > $3;
                                printf("exp-> exp SUP exp: %i > %i;\n", $1 -> int_val, $3 -> int_val);}
| exp EQUAL exp               { $$ = new_attribute();
                                $$->reg_number = reg_count++;
                                $1 == $3;
                                printf("exp-> exp EQUAL exp: %i == %i;\n", $1 -> int_val, $3 -> int_val);}
| exp DIFF exp                { $$ = new_attribute();
                                $$->reg_number = reg_count++;
                                $1 != $3;
                                printf("exp-> exp DIFF exp: %i != %i;\n", $1 -> int_val, $3 -> int_val);}
| exp AND exp                 { $$ = new_attribute();
                                $$->reg_number = reg_count++;
                                $1 && $3;
                                printf("exp-> exp AND exp: %i && %i;\n", $1 -> int_val, $3 -> int_val);}
| exp OR exp                  { $$ = new_attribute();
                                $$->reg_number = reg_count++;
                                $1 || $3;
                                printf("exp-> exp OR exp: %i || %i;\n", $1 -> int_val, $3 -> int_val);}

// II.3.3. Structures

| exp ARR ID                  {}
| exp DOT ID                  {}

| app                         {}
;
       
// II.4 Applications de fonctions

app : ID PO args PF;

args :  arglist               {}
|                             {}
;

arglist : exp VIR arglist     {}
| exp                         {}
;
%%

int main () {
  return yyparse ();

} 

