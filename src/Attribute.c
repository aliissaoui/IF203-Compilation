#include "Attribute.h"

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>

int reg_count = 0;
int label_count = 0;

//QUEUE
void initialize_stack(stack *s)
{
  s->head = 0;
  s->capacity = CAPACITY;
  s->tab = malloc(sizeof(attribute) * CAPACITY);
  assert(s->tab != NULL);
}

void push(attribute x, stack *s)
{
  if (s->head < s->capacity)
  {
    s->head++;
    s->tab[s->head] = x;
  }
  else
  {
    s->tab = realloc(s->tab, sizeof(attribute) * CAPACITY * 2);
    assert(s->tab != NULL);
    s->capacity *= 2;
    s->head++;
    s->tab[s->head] = x;
  }
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

void initialize_struct()
{
  initialize_stack(&struct_stack);
}

void push_struct(attribute x)
{
  push(x, &struct_stack);
}

attribute pop_struct()
{
  return pop(&struct_stack);
}

attribute head_struct()
{
  return head(&struct_stack);
}

int is_empty_struct()
{
  return is_empty(&struct_stack);
}

int last_argument_struct()
{
  return last_argument(&struct_stack);
}

// ATTRIBUTES
attribute new_attribute()
{
  attribute r;
  r = malloc(sizeof(struct ATTRIBUTE));
  r->stars = 0;
  r->name = "1r";
  r->permanent = 0;
  return r;
};

void cond_free2(attribute x, attribute y)
{
  if (!x->permanent)
  {
    free(x);
  }
  if (!y->permanent)
  {
    free(y);
  }
}

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

void write_func(attribute r)
{
  write_type(r);
  printf("%s();\n", r->name);
  write_type_c(r);
  printf("_.f1_%s(){\n", r->name);
}

void write_aff(attribute r, attribute s, int reg_num)
{
  printf("ri%d = ri%d;\n", reg_num, s->reg_number);
  printf("%s = ri%d;\n", r->name, s->reg_number);
  if (r->type_val == INT)
    printf("printf(\"%s = %%d\\n\", %s);\n", r->name, r->name);
  else
    printf("printf(\"%s = %%f\\n\", %s);\n", r->name, r->name);
}

void write_aff_p(attribute r, attribute s, int reg_num)
{
  printf("ri%d = *ri%d;\n", reg_num, s->reg_number);
  printf("%s = *ri%d;\n", r->name, s->reg_number);
  if (r->type_val == INT)
    printf("printf(\"%s = *%%d\\n\", %s);\n", r->name, r->name);
  else
    printf("printf(\"%s = *%%f\\n\", %s);\n", r->name, r->name);
}

int apply_fun_with_param(attribute r, attribute back)
{
  if (r->type_val != TVOID)
  {
    r->reg_number = new_reg_num();
    write_type_c(r);
    printf("ri%d;\n", r->reg_number);
    printf("ri%d = ", r->reg_number);
  }
  printf("%s\( ", back->name);
  while (!last_argument_fun())
  {
    if (strcmp(head_fun()->name, "1r"))
      printf("%s, ", pop_fun()->name);
    else
      printf("ri%d, ", pop_fun()->reg_number);
  }
  if (strcmp(head_fun()->name, "1r"))
    printf("%s );\n", pop_fun()->name);
  else
    printf("ri%d );\n", pop_fun()->reg_number);
  int n = r->reg_number;
  free(r);
  return n;
}

int apply_fun_without_param(attribute r, attribute back)
{
  if (r->type_val != TVOID)
  {
    r->reg_number = new_reg_num();
    write_type_c(r);
    printf("ri%d;\n", r->reg_number);
    printf("ri%d = ", r->reg_number);
  }
  printf("%s\();\n", back->name);
  int n = r->reg_number;
  free(r);
  return n;
}

attribute plus_attribute(attribute x, attribute y)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  if (x->type_val == y->type_val)
  {
    if (x->stars != y->stars)
    {
      if (  x->stars && !y->stars)
      {
        r->stars = y->stars;
      }
      else if ( x->stars && !y->stars)
      {
        r->stars = x->stars;
      }
      else
      {
        printf("Forbiden operation: pointer + pointer\n");
        exit(0);
      }
    }
    write_type_c(x);
    write_stars(x);
    r->type_val = x->type_val;
    printf("ri%d;\n", r->reg_number);
  }
  else
  {
    if (x->type_val == FLOAT && x->stars && y->type_val == INT && !y->stars)
    {
      r->stars = x->stars;
    }
    else if (y->type_val == FLOAT && y->stars && x->type_val == INT && !x->stars)
    {
      r->stars = y->stars;
    }
    else
    {
      printf("Forbiden opetation: pointer + float Or pointer + pointer");
    }
    r->type_val = FLOAT;
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  printf("ri%d = ri%d + ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  cond_free2(x, y);
  return r;
};

attribute mult_attribute(attribute x, attribute y)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  if (x->type_val == y->type_val)
  {
    r->type_val = x->type_val;
    write_type_c(x);
    printf("ri%d;\n", r->reg_number);
  }
  else
  {
    r->type_val = FLOAT;
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  printf("ri%d = ri%d * ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  cond_free2(x, y);
  return r;
};

attribute minus_attribute(attribute x, attribute y)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  if ( x->stars != y->stars ){
    printf("Forbidden operation\n");
    exit(0);
  }
  else {
    if (x->type_val == y->type_val)
    {
      r->type_val = x->type_val;
      write_type_c(x);
      printf("ri%d;\n", r->reg_number);
    }
    else if (x->stars == 0)
    {
      r->type_val = FLOAT;
      printf("\nfloat ri%d;\n", r->reg_number);
    }
    else {
      r->type_val = INT;
      printf("\nint ri%d;\n", r->reg_number);
    }
    printf("ri%d = ri%d - ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
    cond_free2(x, y);
  }
  return r;
};

attribute div_attribute(attribute x, attribute y)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  if (x->type_val == y->type_val)
  {
    r->type_val = x->type_val;
    write_type_c(x);
    printf("ri%d;\n", r->reg_number);
  }
  else
  {
    r->type_val = FLOAT;
    printf("\nfloat ri%d;\n", r->reg_number);
  }
  printf("ri%d = ri%d / ri%d;\n", r->reg_number, x->reg_number, y->reg_number);
  cond_free2(x, y);
  return r;
};

attribute neg_attribute(attribute x)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r->type_val = x->type_val;
  write_type_c(r);
  printf("ri%d;\n", r->reg_number);
  printf("ri%d = - ri%d", r->reg_number, x->reg_number);
  if (!x->permanent)
  {
    free(x);
  }
  return r;
};

attribute bool_attribute(attribute x, char *op, attribute y)
{
  attribute r = new_attribute();
  r->reg_number = new_reg_num();
  r->type_val = INT;
  write_type_c(r);
  printf("ri%d;\n", r->reg_number);
  printf("ri%d = ri%d %s ri%d;\n", r->reg_number, x->reg_number, op, y->reg_number);
  return r;
};
