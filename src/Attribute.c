#include "Attribute.h"

#include <stdlib.h>
#include <stdio.h>

static int reg_count=0;

attribute new_attribute ( type t) {
  attribute r;
  r  = malloc (sizeof (struct ATTRIBUTE));
  r->reg_number = reg_count++;
  r->type_val = t;
  write_type(t);
  printf(" ri%d;\n", r->reg_number);
  return r;
};


attribute plus_attribute(attribute x, attribute y) {
  attribute r = new_attribute(x->type_val);
  /* unconditionally adding integer values */
  r -> int_val = x -> int_val + y -> int_val;
  return r;
};

attribute mult_attribute(attribute x, attribute y){
  attribute r = new_attribute(x->type_val);
  /* unconditionally adding integer values */
  r -> int_val = x -> int_val * y -> int_val;
  return r;
};

attribute minus_attribute(attribute x, attribute y){
  attribute r = new_attribute(x->type_val);
  /* unconditionally adding integer values */
  r -> int_val = x -> int_val - y -> int_val;
  return r;
};

attribute div_attribute(attribute x, attribute y){
  attribute r = new_attribute(x->type_val);
  /* unconditionally adding integer values */
  r -> int_val = x -> int_val % y -> int_val;
  return r;
};

attribute neg_attribute(attribute x){
  attribute r = new_attribute(x->type_val);
  /* unconditionally adding integer values */
  r -> int_val = -(x -> int_val);
  return r;
};

void write_type(type t){
  if ( t == INT )
    printf("int ");
  else if ( t == FLOAT)
    printf("float ");
}