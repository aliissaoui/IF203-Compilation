%code requires{
#include "src/Table_des_symboles.h"
#include "src/Attribute.h"
 }

%{
#include <stdio.h>
#include "src/Attribute.h"
#include <string.h>

extern int yylex();
extern int yyparse();

void yyerror (char* s) {
  printf ("%s\n",s);
} 
int dec_count = 0, verif_count=0;

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
 
%type <val> exp type pointer STAR vir vlist typename aff var_decl decl_list
%type <val> cond stat bool_cond else while while_cond
%type <val> fun_head params args app

%start prog  


%%


prog : block                  {}
;

block:
decl_list inst_list            {}
;

// I. Declarations

decl_list : decl decl_list     { verif_count++;
                                 if (verif_count == dec_count)
                                    printf("int main(){\n");}
|                              { }
;

decl: var_decl PV              { dec_count++;}
| struct_decl PV               {}
| fun_decl                     {}
;

// I.1. Variables
var_decl : type vlist          {  while( !is_empty_vlist() ){
                                    write_type($1->type_val);
                                    write_stars($1);
                                    printf("%s;\n", pop_vlist()->name);}
                                }
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

fun_head : ID PO PF            { set_symbol_value($1->name, $1);
                                 write_type_c($1->type_val);
                                 printf("%s();\n", $1->name);
                                 write_type_c($1->type_val);
                                 printf("%s(){\n", $1->name);
                                 }
| ID PO params PF              {  set_symbol_value($1->name, $1);
                                  write_type_c($1->type_val);
                                  printf("%s( ", $1->name);
                                  while( !last_argument_fun() ){
                                    $$ = pop_fun();
                                    write_type_c($$->type_val);
                                    printf("%s, ", $$->name);
                                  }
                                  $$ = pop_fun();
                                  write_type_c($$->type_val);
                                  printf("%s ){\n", $$->name);
                                }
;

params: type ID vir params     { $$ = $1;
                                 $2->type_val = $1->type_val;
                                 $2->stars = $1->stars;
                                 push_fun($2); }
| type ID                      { initialize_fun();
                                 $2->stars = $1->stars;
                                 $2->type_val = $1->type_val;
                                 push_fun($2); }

vlist: ID vir vlist            {  push_vlist($1);}
| ID                           {  initialize_vlist();
                                  push_vlist($1); }
;

vir : VIR                      {}
;

fun_body : AO block AF         {printf("}\n\n");}
;

// I.4. Types
type
: typename pointer             { $$ = $2;
                                 $$->type_val = $1->type_val;
                                  }
| typename                     { $$ = $1; }
;

typename

: TINT                          { $$ = new_attribute();
                                  $$->type_val = INT; }

| TFLOAT                        { $$ = new_attribute();
                                  $$->type_val = FLOAT; }

| VOID                          { $$ = new_attribute();
                                  $$->type_val = TVOID; }

| STRUCT ID                     {}
;

pointer
: pointer STAR                 { $$=$1;
                                 $$->stars++; }
| STAR                         { $$ = new_attribute();
                                 $$->stars++;
                                }
;


// II. Intructions

inst_list: inst PV inst_list   {}
| inst                         {}
|                              {}
;

inst:

exp                           {}
| AO block AF                 {}
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
ret : RETURN exp              {printf("return ri%d;\n", $2->reg_number);}
| RETURN PO PF                {}
;

// II.3. Conditionelles

cond :
if bool_cond stat else stat   { printf("l%d:;\n", $3->int_val);}
|  if bool_cond stat          { printf("l%d:;\n", $3->int_val);}
;

stat:
AO block AF                   { if ( $<val>0->_else  == 0 ) {
                                  $$ = new_attribute();
                                  $$->int_val = new_label();
                                  printf("goto l%d;\nl%d:\n", $$->int_val, $<val>0->int_val);
                                }
                              }   
;


bool_cond : PO exp PF         { $$ = $2;
                                $$->int_val = new_label();
                                $$ -> _else = 0;
                                printf("if ( !ri%d ) goto l%d;\n", 
                                $2->reg_number, $$->int_val);}
;

if : IF                       {}
;

else : ELSE                   { $$ = new_attribute();
                                $$ -> _else = 1; }
;

// II.4. Iterations

loop : while while_cond inst  { printf("goto l%d;\nl%d:\n", $1->int_val, $2->int_val);}
;

while_cond : PO exp PF        { $$ = $2;                   
                                $$ -> int_val = new_label();
                                printf("if ( !ri%d ) goto l%d;\n", $$->reg_number, $$->int_val ); }

while : WHILE                 { $$ = new_attribute();
                                $$->int_val = new_label(); 
                                printf("l%d:;\n", $$->int_val);}
;


// II.3 Expressions
exp
// II.3.0 Exp. arithmetiques
: MOINS exp %prec UNA         {}

| exp PLUS exp                { $$=plus_attribute($1,$3); }
| exp MOINS exp               { $$=minus_attribute($1,$3); }
| exp STAR exp                { $$=mult_attribute($1,$3); }
| exp DIV exp                 { $$=div_attribute($1,$3); }

| PO exp PF                   { $$ = $2; }
                                
| ID                          { $$ = $1;
                                $$->reg_number = new_reg_num();
                                write_type_c($1->type_val);
                                printf("ri%d;\n", $$->reg_number);                                
                                printf("ri%d = %s;\n", $$->reg_number, yylval.val -> name);
                                }

| NUMI                        { $$ = $1;
                                $$->reg_number = new_reg_num();
                                printf("int ri%d;\n", $$->reg_number);
                                printf("ri%d = %d;\n", $$->reg_number, $$->int_val);
                                }

| NUMF                        { $$ = $1;
                                $$->reg_number = new_reg_num();
                                printf("float ri%d;\n", $$->reg_number);
                                printf("ri%d = %f;\n", $$->reg_number, $$->float_val);
                                }

// II.3.1 Déréférencement

| STAR exp %prec UNA          {}

// II.3.2. Booléens

| NOT exp %prec UNA           {}
| exp INF exp                 { $$ = inf_attribute($1, $3); }
| exp SUP exp                 { $$ = sup_attribute($1, $3); }
| exp EQUAL exp               { $$ = equal_attribute($1, $3); }
| exp DIFF exp                { $$ = diff_attribute($1, $3); }
| exp AND exp                 { $$ = and_attribute($1, $3); }
| exp OR exp                  { $$ = or_attribute($1, $3); }

// II.3.3. Structures

| exp ARR ID                  {}
| exp DOT ID                  {}

| app                         {  $$ = $1; }
;

// II.4 Applications de fonctions

app : ID PO args PF           { $$ = $3; }

args :  arglist               { $$ = get_symbol_value(($<val>-1)->name);
        
                                if( $$->type_val != VOID ){
                                  $$->reg_number = new_reg_num();
                                  write_type_c($$->type_val);
                                  printf("ri%d;\n", $$->reg_number);
                                  printf("ri%d = ", $$->reg_number);
                                }
                                printf("%s\( ", $<val>-1->name );
                                  while( !last_argument_fun() ){

                                    if ( strcmp(head_fun()->name,"1r") )
                                      printf("%s, ", pop_fun()->name);
                                    else
                                      printf("ri%d, ", pop_fun()->reg_number);
                                }
                                if ( strcmp(head_fun()->name,"1r") )
                                  printf("%s);\n", pop_fun()->name);
                                else
                                  printf("ri%d);\n", pop_fun()->reg_number);}
|                             {}
;

arglist : exp VIR arglist     { push_fun($1);}
| exp                         { initialize_fun();
                                 push_fun($1);}
;
%%

int main () {

  return yyparse ();

} 

