#include "io.h"
int a;
int *ptr;
void add(int* ptr)
{
    *ptr=5;
}

int main()
{ 
   ptr = &a;
  *ptr = 10;
  puti(a);
  putc('\n');
  add(ptr); 
  puti(a);
  putc('\n');
  return 0;
}
