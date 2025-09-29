#include "stdio.h"
typedef struct { long long l; char b; } Slb;
Slb lb = { 123, 'z' };

void fn8(int p0, int p1, int p2, int p3, int p4, int p5, int p6, int p7, Slb *s) {
    printf(" { %lld, '%c' }\r\n ", s->l, s->b);
}
int main()
{
  fn8(0,0,0,0,0,0,0,0,&lb);
  return 0;
}