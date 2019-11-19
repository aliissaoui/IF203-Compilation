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

#define SIZE 15

typedef enum {INT, FLOAT, TVOID} type;

struct ATTRIBUTE {
  char * name;
  int int_val;
  float float_val;
  type type_val;
  int reg_number;
  
  /* other attribute's fields can goes here */ 
  int _else;

};

typedef struct ATTRIBUTE * attribute;



struct STACK 
{
  attribute tab[SIZE];
  int head;
};

typedef struct STACK stack;


stack vlist_stack;
stack fun_stack;



void initialize_stack(stack* s);
void push(attribute x, stack* s);
attribute pop(stack* s);
int is_empty(stack* s);
int last_argument(stack* s);


void initialize_vlist();
void push_vlist(attribute x);
attribute pop_vlist();
int is_empty_vlist();


void initialize_fun();
void push_fun(attribute x);
attribute pop_fun();
int is_empty_fun();
int last_argument_fun();





attribute new_attribute ();
/* returns the pointeur to a newly allocated (but uninitialized) attribute value structure */

int new_reg_num();
int new_label();
void write_type(type t);

attribute plus_attribute(attribute x, attribute y);
attribute mult_attribute(attribute x, attribute y);
attribute minus_attribute(attribute x, attribute y);
attribute div_attribute(attribute x, attribute y);
attribute neg_attribute(attribute x);
attribute inf_attribute(attribute x, attribute y);
attribute sup_attribute(attribute x, attribute y);
attribute equal_attribute(attribute x, attribute y);
attribute diff_attribute(attribute x, attribute y);
attribute and_attribute(attribute x, attribute y);
attribute or_attribute(attribute x, attribute y);

void write_type(type t);
void write_type_c(type t);

#endif

