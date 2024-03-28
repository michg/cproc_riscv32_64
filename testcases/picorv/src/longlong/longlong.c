#include "stdio.h"

unsigned long long addl(unsigned long long a, unsigned long long b, unsigned long long c, unsigned long long d, unsigned long long e) {
return a + b + c + d + e;
}

int main()
{   unsigned long long res;
	unsigned long long a = 0x100000000ull;
	unsigned long long b = 0x200000000ull;
	unsigned long long c = 0x300000000ull;
	unsigned long long d = 0x400000000ull;
	unsigned long long e = 0x500000000ull;
	res = addl(a, b, c , d, e);
	printf("%llx\r\n", res);
	return 0;
}
