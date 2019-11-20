#include "Attribute.h"

#include <stdlib.h>
#include <stdio.h>

int reg_count = 0;
int label_count = 0;

//QUEUE
void initialize_stack(stack *s)
{
  s->head = 0;
}

void push(attribute x, stack *s)
{
  s->head++;
  s->tab[s->head] = x;
}

attribute pop(stack *s)
{
  attribute x = s->tab[s->head];
  s->head--;
  return x;
}

attribute head(stack *s)
{
  return s->tab[s->head];
}

int is_empty(stack *s)
{
  if (s->head == 0)
    return 1;
  return 0;
}

int last_argument(stack *s)
{
  if (s->head == 1)
    return 1;
  return 0;
}

void initialize_vlist()
{
  initialize_stack(&vlist_stack);
}

void push_vlist(attribute x)
{
  push(x, &vlist_stack);
}

attribute pop_vlist()
{
  return pop(&vlist_stack);
}

attribute head_vlist()
{
  return head(&vlist_stack);
}

int is_empty_vlist()
{
  return is_empty(&vlist_stack);
}

int last_argument_vlist()
{
  return last_argument(&vlist_stack);
}

void initialize_fun()
{
  initialize_stack(&fun_stack);
}

void push_fun(attribute x)
{
  push(x, &fun_stack);
}

attribute pop_fun()
{
  return pop(&fun_stack);
}

attribute head_fun()
{
  return head(&fun_stack);
}

int is_empty_fun()
{
  return is_empty(&fun_stack);
}

int last_argument_fun()
{
  return last_argument(&fun_stack);
}

// ATTRIBUTES
attribute new_attribute()
{
  attribute r;
  r = malloc(sizeof(struct ATTRIBUTE));
  r->stars = 0;
  r->name = "1r";
  return r;
};

int new_reg_num()
{
  return reg_count++;
}

int new_label()
{
  return label_count++;
}

//PRINTER
void write_type(attribute r)
{
  if (r->type_val == INT)
    printf("_.h_int ");
  else if (r->type_val == FLOAT)
    printf("_.h_float ");
  write_stars(r);
}

void write_type_c(attribute r)
{
  if (r->type_val == INT)
    printf("int ");
  else if (r->type_val == FLOAT)
    printf("float ");
}

void write_stars(attribute r)
{
  for (int i = 0; i < r->stars; i++)
  {
    printf("*");
  }
}

void write_func( attribute r)
{
  write_type(r);
  printf("%s();\n", r->name);
  write_type_c(r);
  printf("%s(){\n", r->name);
}

attribute plus_attribute(attribute x, attribute y)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  if (x->type_val == y->type_val)
  {
    write_type_c(x);
    printf("ri%d;\n", r->reg_number);
  }
  else
  {
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  printf("ri%d = ri%d + ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute mult_attribute(attribute x, attribute y)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  /* unconditionally adding integer values */
  if (x->type_val == y->type_val)
  {
    write_type_c(x);
    printf("ri%d;\n", r->reg_number);
  }
  else
  {
    printf("\nfloat ri%d;\n", r->reg_number);
  }

  printf("ri%d = ri%d * ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute minus_attribute(attribute x, attribute y)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  /* unconditionally adding integer values */
  if (x->type_val == y->type_val)
  {
    write_type_c(x);
    printf("ri%d;\n", r->reg_number);
  }
  else
  {
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  printf("ri%d = ri%d - ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute div_attribute(attribute x, attribute y)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  /* unconditionally adding integer values */
  if (x->type_val == y->type_val)
  {
    write_type_c(x);
    printf("ri%d;\n", r->reg_number);
  }
  else
  {
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  printf("ri%d = ri%d / ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  return r;
};

attribute neg_attribute(attribute x)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  /* unconditionally adding integer values */
  r->type_val = x->type_val;
  write_type_c(r);
  printf("ri%d;\n", r->reg_number);
  printf("ri%d = - ri%d", r->reg_number, x->reg_number);
  return r;
};

attribute bool_attribute(attribute x, char* op, attribute y)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r->type_val = INT;
  write_type_c(r);
  printf("ri%d;\n", r->reg_number);
  printf("ri%d = ri%d %s ri%d;\n", r->reg_number, x->reg_number, op, y->reg_number);
  return r;
};


// free registers
// instructions du genre a = f(a) + f(b); ne marche pas (même f)
// problem with functions without params
// problem: decl + inst inside functin => main de plus :(

//Questions
// cast variables ???
// what do we need to declare in .h ??
//functions declared inside main ??