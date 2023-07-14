/* 
 * Copyright (C) 2014, Galois, Inc.
 * This sotware is distributed under a standard, three-clause BSD license.
 * Please see the file LICENSE, distributed with this software, for specific
 * terms and conditions.
 */
#include <ctype.h>

int isspace(int c)
{
  return ((c == ' ') || (c == '\n') || (c == '\t'));
}
