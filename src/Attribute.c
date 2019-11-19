#include "Attribute.h"

#include <stdlib.h>
#include <stdio.h>

int reg_count=0;
int label_count=0;

void initialize_vlist(){
  vlist_stack.head = 0;
}

void push_vlist(attribute x){
  vlist_stack.head++;
  vlist_stack.tab[vlist_stack.head] = x;
}

attribute pop_vlist(){
  attribute x = vlist_stack.tab[vlist_stack.head];
  vlist_stack.head--;
  return x;
}

int is_empty_vlist(){
  return (vlist_stack.head == 0);
}


void initialize_fun(){
  fun_stack.head = 0;
}

void push_fun(attribute x){
  fun_stack.head++;
  fun_stack.tab[fun_stack.head] = x;
}

attribute pop_fun(){
  attribute x = fun_stack.tab[fun_stack.head];
  fun_stack.head--;
  return x;
}

int is_empty_fun(){
  return (fun_stack.head == 0);
}

int last_argument_fun(){
  return (fun_stack.head == 1);
}



attribute new_attribute () {
  attribute r;
  r  = malloc (sizeof (struct ATTRIBUTE));
  r->stars = 0;
  return r;
};

int new_reg_num() {
  return reg_count++;
}

int new_label() {
//  printf("//label created : %d\n", label_count);
  return label_count++;
}

void write_type(type t){
  if ( t == INT )
    printf("_.h_int ");
  else if ( t == FLOAT)
    printf("_.h_float ");
}

void write_type_c(type t){
  if ( t == INT )
    printf("int ");
  else if ( t == FLOAT)
    printf("float ");
}

void write_stars(attribute r){
  for( int i=0; i<r->stars; i++){
    printf("*");
  }
}

attribute plus_attribute(attribute x, attribute y) {
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  if ( x->type_val == y->type_val){
    write_type_c(x->type_val);
    printf("ri%d;\n", r->reg_number);
  }
  else {
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  printf( "ri%d = ri%d + ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute mult_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  /* unconditionally adding integer values */
  if ( x->type_val == y->type_val){
    write_type_c(x->type_val);
    printf("ri%d;\n", r->reg_number);
  }
  else {
    printf("\nfloat ri%d;\n", r->reg_number);
  }

  printf( "ri%d = ri%d * ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute minus_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  /* unconditionally adding integer values */
  if ( x->type_val == y->type_val) {
    write_type_c(x->type_val);
    printf("ri%d;\n", r->reg_number);
  }
  else {
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  printf( "ri%d = ri%d - ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute div_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  /* unconditionally adding integer values */
  if ( x->type_val == y->type_val) {
    write_type_c(x->type_val);
    printf("ri%d;\n", r->reg_number);
  }
  else {
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  printf( "ri%d = ri%d / ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute neg_attribute(attribute x){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  /* unconditionally adding integer values */
  r -> type_val = x -> type_val;
  write_type_c(r->type_val);
  printf("ri%d;\n", r->reg_number);
  printf( "ri%d = - ri%d", r->reg_number, x->reg_number);
  return r;
};

attribute inf_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  write_type_c(r->type_val);
  printf("ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d < ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute sup_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  write_type_c(r->type_val);
  printf("ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d > ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute equal_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  write_type_c(r->type_val);
  printf("ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d == ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute diff_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  write_type_c(r->type_val);
  printf("ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d != ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute and_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  write_type_c(r->type_val);
  printf("ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d && ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute or_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  write_type_c(r->type_val);
  printf("ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d || ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};



// free registers
// rassembler les opérations booléens dans une seule fonction
// cast variables
// register declaration local in functions
// what do we need to declare in .h