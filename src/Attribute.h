/*
 *  Attribute.h
 *
 *  Created by Janin on 10/2019
 *  Copyright 2018 LaBRI. All rights reserved.
 *
 *  Module for a clean handling of attibutes values
 *
 */

#ifndef ATTRIBUTE_H
#define ATTRIBUTE_H

#define CAPACITY 10

typedef enum {INT, FLOAT, TVOID} type;

struct ATTRIBUTE {
  char * name;
  int int_val;
  float float_val;
  type type_val;
  int reg_number;

  /* other attribute's fields can goes here */
  int _else;
  int stars;

};

typedef struct ATTRIBUTE * attribute;



struct STACK
{
  attribute *tab;
  int head;
  int capacity;
};

typedef struct STACK stack;


stack vlist_stack;
stack fun_stack;


void initialize_vlist();
void push_vlist(attribute x);
attribute pop_vlist();
int is_empty_vlist();
attribute head_vlist();
int last_argument_vlist();

void initialize_fun();
void push_fun(attribute x);
attribute pop_fun();
int is_empty_fun();
int last_argument_fun();
attribute head_fun();


attribute new_attribute ();
/* returns the pointeur to a newly allocated (but uninitialized) attribute value structure */

int new_reg_num();
int new_label();
void write_type(attribute r);
void write_type_c(attribute r);
void write_stars(attribute r);
void write_func( attribute r);
void write_aff(attribute r, attribute s, int reg_num);
void write_aff_p(attribute r, attribute s, int reg_num);
int apply_fun_with_param( attribute r, attribute back);
int apply_fun_without_param(attribute r, attribute back);

attribute plus_attribute(attribute x, attribute y);
attribute mult_attribute(attribute x, attribute y);
attribute minus_attribute(attribute x, attribute y);
attribute div_attribute(attribute x, attribute y);
attribute neg_attribute(attribute x);
attribute bool_attribute(attribute x, char* op, attribute y);

#endif
