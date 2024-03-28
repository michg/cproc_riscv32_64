#include "stdio.h"

void varargs(long long arg1, ...)
{
	__builtin_va_list ap;
	long long i;

	__builtin_va_start(ap, arg1);
	for (i = arg1; i >= 0; i = __builtin_va_arg(ap, long long))
	printf("%lld\r\n",i);
	__builtin_va_end(ap);
}

int main()
{
	varargs(0x100000000ll, 0x200000000ll, -1ll);
	return 0;
}