/*
 *  Table des symboles.c
 *
 *  Created by Janin on 12/10/10.
 *  Copyright 2010 LaBRI. All rights reserved.
 *
 */

#include "Table_des_symboles.h"
#include "Attribute.h"

#include <stdlib.h>
#include <stdio.h>

/* The storage structure is implemented as a linked chain */

/* linked element def */

typedef struct elem
{
	sid symbol_name;
	attribute symbol_value;
	struct elem *next;
} elem;

/* linked chain initial element */
static elem *storage = NULL;
static elem *backup = NULL;

/* get the symbol value of symb_id from the symbol table */
attribute get_symbol_value(sid symb_id)
{
	elem *tracker = storage;

	/* look into the linked list for the symbol value */
	while (tracker)
	{
		if (tracker->symbol_name == symb_id)
			return tracker->symbol_value;
		tracker = tracker->next;
	}

	/* if not found does cause an error */
	fprintf(stderr, "Error : symbol %s is not a valid defined symbol\n", (char *)symb_id);
	exit(-1);
};

/* set the value of symbol symb_id to value */
attribute set_symbol_value(sid symb_id, attribute value)
{

	elem *tracker;

	/* look for the presence of symb_id in storage */

	tracker = storage;
	while (tracker)
	{
		//printf(" \nset value:  %s;\n", tracker->symbol_name);

		if (tracker->symbol_name == symb_id)
		{
			tracker->symbol_value = value;
			return tracker->symbol_value;
		}
		tracker = tracker->next;
	}

	/* otherwise insert it at head of storage with proper value */

	tracker = malloc(sizeof(elem));
	tracker->symbol_name = symb_id;
	tracker->symbol_value = value;
	tracker->next = storage;
	storage = tracker;
	return storage->symbol_value;
}

void declare_func()
{
	elem *tracker;
	elem *back;
	/* look for copying storage elements in backup */
	//printf("\n//in declare func\n");
	tracker = storage;
	while (tracker)
	{
		back = malloc(sizeof(elem));
		//printf("\n//set:  %s;\n", tracker->symbol_name);
		back->symbol_name = tracker->symbol_name;
		back->symbol_value = tracker->symbol_value;
		back->next = backup;
		backup = back;
		tracker = tracker->next;
	}
}

void finish_func()
{
	elem *tracker;
	elem *back;
	/* look for copying backup elements in storage */
	//printf("\n//in finish func\n");
	tracker = backup;
	while (tracker)
	{
		back = malloc(sizeof(elem));
		back->symbol_name = tracker->symbol_name;
		back->symbol_value = tracker->symbol_value;
		back->next = storage;
		storage = back;
		tracker = tracker->next;
	}
}

void declar_params(int nb_params){
	elem *tracker;
	tracker = storage;
	while (nb_params--)
	{
		write_type_c(tracker->symbol_value);
		printf(" ri%d = %s;\n", tracker->symbol_value->reg_number, tracker->symbol_name);
		tracker = tracker->next;
	}
}
