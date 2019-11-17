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

type current_type;
int lab_count=0;
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

%left DIFF EQUAL SUP INF       // low priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
 
%type <val> exp vir vlist typename aff var_decl type stat cond bool_cond else


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
|                              {printf("l%d:\n", lab_count++);} // we needed to add it to recognize file end.
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

vlist: ID vir vlist            {  }
| ID                           {  write_type(current_type);
                                  printf("%s;\n", $1 -> name);}
;

vir : VIR                      {  write_type(current_type);
                                  printf("%s;\n", $$->name);}
;

fun_body : AO block AF         {}
;

// I.4. Types
type
: typename pointer             {}
| typename                     {}
;

typename

: TINT                          { current_type = INT;}

| TFLOAT                        { current_type = FLOAT;}

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

aff : ID EQ exp               { printf("%s = ri%d;\n", $1->name, $3->reg_number);
                                printf("printf(\"%s = %%d\\n\", %s);\n", $1->name, $1->name);
                                }
| exp STAR EQ exp             {}
;


// II.2 Return
ret : RETURN exp              {}
| RETURN PO PF                {}
;

// II.3. Conditionelles

cond :
if bool_cond stat else stat   { printf("l%d:\n", lab_count++); }
|  if bool_cond stat          { printf("l%d:\n", lab_count++); }
;

stat:
AO block AF                   { printf("goto l%d;\n", lab_count);}
;


bool_cond : PO exp PF         { $$ = $2;
                                printf("if ri%d goto l%d;\nif !ri%d goto l%d;\n", 
                                $2->reg_number, lab_count, $2->reg_number, lab_count+1);}
;

if : IF                       {}
;

else : ELSE                   {}
;

// II.4. Iterations

loop : while while_cond inst  {}
;

while_cond : PO exp PF        {printf("l%d:\nif ri%d goto l%d");}

while : WHILE                 {}
;


// II.3 Expressions
exp
// II.3.0 Exp. arithmetiques
: MOINS exp %prec UNA         {}

| exp PLUS exp                { $$=plus_attribute($1,$3);
                                printf( "ri%d = ri%d + ri%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);
                                }

| exp MOINS exp               { $$=minus_attribute($1,$3);                     
                                printf( "ri%d = ri%d - ri%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);
                                }

| exp STAR exp                { $$=mult_attribute($1,$3);                            
                                printf( "ri%d = ri%d * ri%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);
                                }

| exp DIV exp                 { $$=div_attribute($1,$3);
                                printf( "ri%d = ri%d / ri%d;\n", $$->reg_number, $1->reg_number, $3->reg_number);
                                }

| PO exp PF                   { $$ = $2;
                                printf("( %s )", $$->name);
                                }
                                
| ID                          { $$ = $1;
                                write_type($1->type_val);
                                printf("ri%d;\n", $$->reg_number);                                
                                printf("ri%d = %s;\n", $$->reg_number, yylval.val -> name);
                                }

| NUMI                        { $$=$1;
                                printf("int ri%d;\n", $$->reg_number);
                                printf("ri%d = %d;\n", $$->reg_number, $$->int_val);
                                }

| NUMF                        { $$=$1;
                                printf("float ri%d;\n", $$->reg_number);
                                printf("ri%d = %f;\n", $$->reg_number, $$->float_val);
                                }

// II.3.1 Déréférencement

| STAR exp %prec UNA          {}

// II.3.2. Booléens

| NOT exp %prec UNA           {}
| exp INF exp                 { $$ = new_attribute();
                                $$->bool = $1->int_val < $3->int_val;
                                printf("ri%d = ri%d < ri%d;\n", $$->reg_number, $1 -> reg_number, $3 -> reg_number);
                                }

| exp SUP exp                 { $$ = new_attribute();
                                $$->bool = $1->int_val > $3->int_val;
                                printf("ri%d = ri%d > ri%d;\n", $$->reg_number, $1 -> reg_number, $3 -> reg_number);
                                }

| exp EQUAL exp               { $$ = new_attribute();
                                
                                $$->bool = $1->int_val == $3->int_val;
                                printf("ri%d = ri%d == ri%d;\n", $$->reg_number, $1 -> reg_number, $3 -> reg_number);
                                }
| exp DIFF exp                { $$ = new_attribute();
                                
                                $$->bool = $1->int_val != $3->int_val;
                                printf("ri%d = ri%d != ri%d;\n", $$->reg_number, $1 -> reg_number, $3 -> reg_number);
                                }
| exp AND exp                 { $$ = new_attribute();
                                
                                $$->bool = $1->bool && $3->bool;
                                printf("ri%d = ri%d && ri%d;\n", $$->reg_number, $1 -> reg_number, $3 -> reg_number);
                                }
| exp OR exp                  { $$ = new_attribute();
                                
                                $$->bool = $1->bool || $3->bool;
                                printf("ri%d = ri%d || ri%d;\n", $$->reg_number, $1 -> reg_number, $3 -> reg_number);
                                }

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

