#include "Attribute.h"

#include <stdlib.h>
#include <stdio.h>

int reg_count=0;
int label_count=0;


pile initialise_pile(){
  p.head = 0;
}

void push(attribute x){
  p.head++;
  p.tab[p.head] = x;
}

attribute pop(){
  attribute x = p.tab[p.head];
  p.head--;
  return x;
}

int is_empty_pile(){
  if (p.head == 0)
    return 1;
  return 0;
}


attribute new_attribute () {
  attribute r;
  r  = malloc (sizeof (struct ATTRIBUTE));
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
    printf("int ");
  else if ( t == FLOAT)
    printf("float ");
}

attribute plus_attribute(attribute x, attribute y) {
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  if ( x->type_val == y->type_val){
    write_type(x->type_val);
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
    write_type(x->type_val);
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
    write_type(x->type_val);
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
    write_type(x->type_val);
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
  printf("\nfloat ri%d;\n", r->reg_number);
  printf( "ri%d = - ri%d", r->reg_number, x->reg_number);
  return r;
};

attribute inf_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  printf("\nint ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d < ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute sup_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  printf("\nint ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d > ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute equal_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  printf("\nint ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d == ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute diff_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  printf("\nint ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d != ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute and_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  printf("\nint ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d && ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute or_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r -> type_val = INT;
  printf("\nint ri%d;\n", r->reg_number);
  printf( "ri%d = ri%d || ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};



// free registers
// vlist (pile?)
// header identification