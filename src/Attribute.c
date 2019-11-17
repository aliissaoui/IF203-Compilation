#include "Attribute.h"

#include <stdlib.h>
#include <stdio.h>

static int reg_count=0;


pile p;


void push(attribute x){
  p.head++;
  p.tab[p.head] = x;
}

attribute pop(){
  p.head--;
}


attribute new_attribute () {
  attribute r;
  r  = malloc (sizeof (struct ATTRIBUTE));
  r->reg_number = reg_count++;
  return r;
};

attribute plus_attribute(attribute x, attribute y) {
  attribute r = new_attribute( );
  if ( x->type_val == y->type_val){
    write_type(x->type_val);
    printf("ri%d;\n", r->reg_number);
  }
  else {
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  return r;
};

attribute mult_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  /* unconditionally adding integer values */
  if ( x->type_val == y->type_val){
    write_type(x->type_val);
    printf("ri%d;\n", r->reg_number);
  }
  else {
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  return r;
};

attribute minus_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  /* unconditionally adding integer values */
  if ( x->type_val == y->type_val){
    write_type(x->type_val);
    printf("ri%d;\n", r->reg_number);
  }
  else {
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  return r;
};

attribute div_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  /* unconditionally adding integer values */
  r -> int_val = x -> int_val % y -> int_val;
  return r;
};

attribute neg_attribute(attribute x){
  attribute r = new_attribute();
  /* unconditionally adding integer values */
  r -> int_val = -(x -> int_val);
  printf("\nfloat ri%d;\n", r->reg_number);
  return r;
};

attribute inf_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  printf("\nint ri%d;\n", r->reg_number);
};

attribute sup_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  printf("\nint ri%d;\n", r->reg_number);
};

attribute equal_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  printf("\nint ri%d;\n", r->reg_number);
};

attribute diff_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  printf("\nint ri%d;\n", r->reg_number);
};

attribute and_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  printf("\nint ri%d;\n", r->reg_number);
};

attribute or_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  printf("\nint ri%d;\n", r->reg_number);
};




void write_type(type t){
  if ( t == INT )
    printf("int ");
  else if ( t == FLOAT)
    printf("float ");
}