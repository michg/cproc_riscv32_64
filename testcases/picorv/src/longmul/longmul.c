#include "io.h"
typedef struct uart {
unsigned int dr;
unsigned int sr;
unsigned int ack;
} UART;

unsigned long lmul(unsigned long a, unsigned long b)
{
  return a*b;
}

int main()
{
    unsigned long a = 0x123456789;
    unsigned long b = 0x4321;
    unsigned long c;
    c = lmul(a,b);
    puti(c);
    putc('\n');
    return 0;
}
