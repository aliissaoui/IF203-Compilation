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
%type <val> attr struct

%start prog


%%


prog : block                  {}
;

block:
decl_list inst_list            {}
;

// I. Declarations

decl_list : decl decl_list     {
                                    }
|                              { }
;

decl: var_decl PV              {}
| struct_decl PV               {}
| fun_decl                     {}
;

// I.1. Variables
var_decl : type vlist          {  while( !is_empty_vlist() ){
                                    $2 = pop_vlist();
                                    $2 -> reg_number = new_reg_num();
                                    $2 -> type_val = $1->type_val;
                                    $2 -> permanent = 1;
                                    set_symbol_value($2->name, $2);
                                    if ($1->type_val != TSTRUCT){
                                      write_type($1);
                                    }
                                    else {
                                      printf("_.h_struct %s ", $1->name);
                                    }
                                    printf("%s, ri%d;\n", $2->name, $2->reg_number);}
                                }
;

// I.2. Structures
struct_decl : STRUCT ID struct {}
;

struct : AO attr AF            { printf("_.h_struct %s{\n", $<val>0->name);
                                 while( !is_empty_struct() ){
                                    $2->int_val++;
                                    head_struct()->reg_number = new_reg_num();
                                    set_symbol_value(head_struct()->name, head_struct());
                                    $$ = pop_struct();
                                    printf("  ");
                                    write_type($$);
                                    printf("%s;\n", $$->name);
                                  }
                                printf("_.h_};\n");}
;

attr : type ID                 { initialize_struct();
                                 $2->stars = $1->stars;
                                 $2->type_val = $1->type_val;
                                 push_struct($2);}
| type ID PV attr              { $$ = $1;
                                 $2->type_val = $1->type_val;
                                 $2->stars = $1->stars;
                                 push_struct($2);}

// I.3. Functions

fun_decl : type fun            {finish_func();} // to go back to the backup symbole table
;

fun : fun_head fun_body        {}
;

fun_head : ID PO PF            { $1 -> permanent = 1;
                                 set_symbol_value($1->name, $1);
                                 declare_func();
                                 write_func($1);
                                 }
| ID PO params PF              {  $1->type_val = $<val>0->type_val;
                                  $1 -> permanent = 1;
                                  set_symbol_value($1->name, $1);
                                  write_type_c($1);
                                  printf("%s( ", $1->name);
                                  $3->int_val=0;
                                  declare_func(); // to start a new symbole table
                                  while( !last_argument_fun() ){
                                    $3->int_val++;
                                    head_fun()->reg_number = new_reg_num();
                                    head_fun()->permanent = 1;
                                    set_symbol_value(head_fun()->name, head_fun());
                                    $$ = pop_fun();
                                    write_type_c($$);
                                    printf("%s, ", $$->name);
                                  }
                                  $3->int_val++;
                                  head_fun()->reg_number = new_reg_num();
                                  head_fun()->permanent = 1;
                                  set_symbol_value(head_fun()->name, head_fun());
                                  $$ = pop_fun();
                                  printf("_.f1_");
                                  write_type_c($$);
                                  printf("%s ){\n", $$->name);
                                  declar_params($3->int_val);
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

vlist: ID vir vlist            { push_vlist($1);}

| ID                           { initialize_vlist();
                                 push_vlist($1); }
;

vir : VIR                      {}
;

fun_body : AO block AF         {printf("_.f2_}\n\n");}
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

| STRUCT ID                     { $$ = new_attribute();
                                  $$->type_val = TSTRUCT;
                                  $$->name = $2->name;
                                  }
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

aff : ID EQ exp               { printf("//in aff\n");
                                $1 = get_symbol_value($1->name);
                                write_aff($1, $3, get_symbol_value($1->name)->reg_number);
                                }
| ID EQ STAR exp             { printf("//in aff pointer\n");
                                $1 = get_symbol_value($1->name);  // I inversed EQ and STAR
                                write_aff_p($1, $3, get_symbol_value($1->name)->reg_number);}
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
                                  printf("goto l%d;\nl%d:;\n", $$->int_val, $<val>0->int_val);
                                }
                              }
;


bool_cond : PO exp PF         { $$ = $2;
                                $$->int_val = new_label();
                                $$->_else = 0;
                                printf("if ( !ri%d ) goto l%d;\n",
                                $2->reg_number, $$->int_val);}
;

if : IF                       {}
;

else : ELSE                   { $$ = new_attribute();
                                $$->_else = 1; }
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

| exp PLUS exp                { $$ = plus_attribute($1,$3); }
| exp MOINS exp               { $$ = minus_attribute($1,$3); }
| exp STAR exp                { $$ = mult_attribute($1,$3); }
| exp DIV exp                 { $$ = div_attribute($1,$3); }

| PO exp PF                   { $$ = $2; }

| ID                          { $$ = get_symbol_value($1->name);}

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
| exp INF exp                 { $$ = bool_attribute($1, "<", $3); }
| exp SUP exp                 { $$ = bool_attribute($1, ">", $3); }
| exp EQUAL exp               { $$ = bool_attribute($1, "==", $3); }
| exp DIFF exp                { $$ = bool_attribute($1, "!=", $3); }
| exp AND exp                 { $$ = bool_attribute($1, "&&", $3); }
| exp OR exp                  { $$ = bool_attribute($1, "||", $3); }

// II.3.3. Structures

| exp ARR ID                  {}
| exp DOT ID                  {}

| app                         { $$ = $1; }
;

// II.4 Applications de fonctions

app : ID PO args PF           { $$ = $3; }

args :  arglist               { $$ = new_attribute();
                                $$->reg_number=apply_fun_with_param(get_symbol_value(($<val>-1)->name), $<val>-1);}

|                             { $$ = new_attribute();
                                $$->reg_number = apply_fun_without_param(get_symbol_value(($<val>-1)->name), $<val>-1);}


;

arglist : exp VIR arglist     { push_fun($1);}
| exp                         { initialize_fun();
                                 push_fun($1);}
;
%%

int main () {

  return yyparse ();

}
