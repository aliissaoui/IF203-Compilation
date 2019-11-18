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
 
%type <val> exp vir vlist typename aff var_decl type stat cond bool_cond else while while_cond


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
var_decl : type vlist          {  while( !is_empty_vlist() ){
                                  write_type($1->type_val);
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

fun : fun_head fun_body        { } //printf("}\n");}
;

fun_head : ID PO PF            { }
                                  //  write_type(current_type);
                                  // printf("%s(){\n", $1->name);}
| ID PO params PF              { }
                                  // write_type(current_type);
                                  // printf("%s({\n", $1->name);
                                  // while( !last_param() ){
                                  //   write_type(current_type);
                                  //   printf("%s, ", pop_param()->name);
                                  // }
                                  // write_type(current_type);
                                  // printf("%s )", pop_param()->name);
                                  // }
;

params: type ID vir params     { }
| type ID                      {  }

vlist: ID vir vlist            {  push_vlist($1);}
| ID                           {  initialize_vlist();
                                  push_vlist($1);
                                }
;

vir : VIR                      { }
;

fun_body : AO block AF         {}
;

// I.4. Types
type
: typename pointer             {}
| typename                     {}
;

typename

: TINT                          { $$ = new_attribute();
                                  $$->type_val = INT;}

| TFLOAT                        { $$ = new_attribute();
                                  $$->type_val = FLOAT;}

| VOID                          { $$ = new_attribute();
                                  $$->type_val = TVOID;}

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
ret : RETURN exp              {printf("return ri%d;\n", $2->reg_number);}
| RETURN PO PF                {}
;

// II.3. Conditionelles

cond :
if bool_cond stat else stat   { printf("l%d:\n", $3->int_val);}
|  if bool_cond stat          { printf("l%d:\n", $3->int_val);}
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
                                printf("l%d:\n", $$->int_val);}
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
                                write_type($1->type_val);
                                printf("ri%d;\n", $$->reg_number);                                
                                printf("ri%d = %s;\n", $$->reg_number, yylval.val -> name);
                                }

| NUMI                        { $$ = $1;
                                $$->reg_number = new_reg_num();
                                printf("_.h_int ri%d;\n", $$->reg_number);
                                printf("ri%d = %d;\n", $$->reg_number, $$->int_val);
                                }

| NUMF                        { $$ = $1;
                                $$->reg_number = new_reg_num();
                                printf("_.h_float ri%d;\n", $$->reg_number);
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

| app                         {}
;

// II.4 Applications de fonctions

app : ID PO args PF;         

args :  arglist               {}
                              // printf("%s\(");
                              //  while( !last_argument_fun ){        // a faire
                              //  printf("%s, ", pop_fun()->name);
                              //  }
                              //  printf("%s );"), pop_fun()->name} // a faire
|                             {}
;

arglist : exp VIR arglist     {}
                                // push_fun($1);}
| exp                         {}
                                // initialise_fun_pile();
                                // push_fun($1);}
;
%%

int main () {

  return yyparse ();

} 

