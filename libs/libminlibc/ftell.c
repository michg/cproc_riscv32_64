/* 
 * Copyright (C) 2014, Galois, Inc.
 * This sotware is distributed under a standard, three-clause BSD license.
 * Please see the file LICENSE, distributed with this software, for specific
 * terms and conditions.
 */
#include <stdio.h>
#include <errno.h>

long ftell(FILE *stream __attribute__((unused)))
{
  printf("ftell\n");
  errno = EBADF;
  return -1;
}
