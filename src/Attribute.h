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
  int bool;
  int label;
  
};

typedef struct ATTRIBUTE * attribute;



struct PILE 
{
  attribute tab[SIZE];
  int head;
};

typedef struct PILE  pile;




void push(attribute x);
attribute pop();


attribute new_attribute ();
/* returns the pointeur to a newly allocated (but uninitialized) attribute value structure */

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

#endif

