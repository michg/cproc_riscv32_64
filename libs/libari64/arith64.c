#define u32 unsigned int
#define s32 int

typedef struct {
	u32 lo;
	u32 hi;
} u64;

typedef struct {
	u32 lo;
	s32 hi;
} s64;

int ceql_di(u64 x, u64 y) { return ((x.hi == y.hi) && (x.lo == y.lo)); }
int cnel_di(u64 x, u64 y) { return ((x.hi != y.hi) || (x.lo != y.lo)); }

int cugtl_di(u64 x, u64 y) {
	return ((x.hi > y.hi) || ((x.hi == y.hi) && (x.lo > y.lo)));
}

int cugel_di(u64 x, u64 y) {
	return ((x.hi > y.hi) || ((x.hi == y.hi) && (x.lo >= y.lo)));
}

int cultl_di(u64 x, u64 y) {
	return ((x.hi < y.hi) || ((x.hi == y.hi) && (x.lo < y.lo)));
}

int culel_di(u64 x, u64 y) {
	return ((x.hi < y.hi) || ((x.hi == y.hi) && (x.lo <= y.lo)));
}

int csgtl_di(s64 x, s64 y) {
	return ((x.hi > y.hi) || ((x.hi == y.hi) && (x.lo > y.lo)));
}

int csgel_di(s64 x, s64 y) {
	return ((x.hi > y.hi) || ((x.hi == y.hi) && (x.lo >= y.lo)));
}

int csltl_di(s64 x, s64 y) {
	return ((x.hi < y.hi) || ((x.hi == y.hi) && (x.lo < y.lo)));
}

int cslel_di(s64 x, s64 y) {
	return ((x.hi < y.hi) || ((x.hi == y.hi) && (x.lo <= y.lo)));
}

u64 shl_di(u64 w, int b) {

	b &= 63;
	if (b >= 32) {
		w.hi = w.lo << (b - 32);
		w.lo = 0;
	} else if (b) {
		w.hi = (w.lo >> (32 - b)) | (w.hi << b);
		w.lo <<= b;
	}
	return w;
}

u64 sar_di(u64 w, int b) {
	b &= 63;
	if (b >= 32) {
		w.lo = w.hi >> (b - 32);
		w.hi = (s32)w.hi >> 31; // 0xFFFFFFFF or 0
	} else if (b) {
		w.lo = (w.hi << (32 - b)) | (w.lo >> b);
		w.hi >>= b;
	}
	return w;
}

u64 shr_di(u64 w, int b) {

	b &= 63;
	if (b >= 32) {
		w.lo = w.hi >> (b - 32);
		w.hi = 0;
	} else if (b) {
		w.lo = (w.hi << (32 - b)) | (w.lo >> b);
		w.hi >>= b;
	}
	return w;
}

u64 add_di(u64 a, u64 b) {
	u32 carry;
	u64 res;
	res.lo = a.lo + b.lo;
	carry = (res.lo < a.lo) ? 1 : 0;
	res.hi = a.hi + b.hi;
	res.hi += carry;
	return res;
}

u64 sub_di(u64 a, u64 b) {
	u32 carry;
	u64 res;
	res.lo = a.lo - b.lo;
	carry = (a.lo < res.lo) ? 1 : 0;
	res.hi = a.hi - b.hi;
	res.hi -= carry;
	return res;
}

s64 neg_di(s64 a) {
	s64 res;
	res.hi = ~a.hi;
	res.lo = ~a.lo + 1;
	if (res.lo == 0)
		res.hi++;
	return res;
}

u64 extsw_di(u32 a) {
	u64 res;
	res.hi = (s32)a >> 31;
	res.lo = a;
	return res;
}

u64 extuw_di(u32 a) {
	u64 res;
	res.lo = a;
	res.hi = 0;
	return res;
}

u64 extsh_di(s32 a) {
	u64 res;
	res.hi = (s32)a >> 31;
	res.lo = a << 16;
	res.lo >>= 16;
	res.hi = a >> 31;
	return res;
}

u64 extuh_di(u32 a) {
	u64 res;
	res.lo = a << 16;
	res.lo >>= 16;
	res.hi = 0;
	return res;
}

u64 extub_di(u32 a) {
	u64 res;
	res.lo = a << 24;
	res.lo >>= 24;
	res.hi = 0;
	return res;
}

u64 and_di(u64 a, u64 b) {
	u64 res;
	res.lo = a.lo & b.lo;
	res.hi = a.hi & b.hi;
	return res;
}

u64 or_di(u64 a, u64 b) {
	u64 res;
	res.lo = a.lo | b.lo;
	res.hi = a.hi | b.hi;
	return res;
}

void storel_di(u64 a, u32 b) {
	*(unsigned int *)b = a.lo;
	*(unsigned int *)(b + 4) = a.hi;
}

u64 loadl_di(u32 a) {
	u64 res;
	res.lo = *(unsigned int *)a;
	res.hi = *(unsigned int *)(a + 4);
	return res;
}

u64 load_di(u32 a) {
	u64 res;
	res.lo = *(unsigned int *)a;
	res.hi = *(unsigned int *)(a + 4);
	return res;
}

u64 mul_di(u64 a, u64 b) {
	u64 res, mid64;
	u32 alo, blo, rmid;
	s32 ahi, bhi;
	ahi = (s32)a.lo >> 16;
	bhi = (s32)b.lo >> 16;
	alo = a.lo & 0xffff;
	blo = b.lo & 0xffff;
	res.hi = ahi * bhi;
	res.lo = alo * blo;
	rmid = ahi * blo + alo * bhi;
	res = add_di(res, shl_di((u64){.hi = (s32)rmid >> 31, .lo = rmid}, 16));
	return res;
}

int clz_si(u32 a) {
	int b, n = 0;
	b = !(a & 0xffff0000) << 4;
	n += b;
	a <<= b;
	b = !(a & 0xff000000) << 3;
	n += b;
	a <<= b;
	b = !(a & 0xf0000000) << 2;
	n += b;
	a <<= b;
	b = !(a & 0xc0000000) << 1;
	n += b;
	a <<= b;
	return n + !(a & 0x80000000);
}

int clz_di(u64 w) {
	int res;
	if (w.hi)
		return clz_si(w.hi);
	else
		return 32 + clz_si(w.lo);
}

u64 udivmod_di(u64 a, u64 b, u64 *c) {
	if ((b.hi > a.hi) || ((b.hi == a.hi) && (b.lo > a.lo))) // divisor > numerator?
	{
		if (c)
			*c = a; // remainder = numerator
		return (u64){.hi = 0, .lo = 0}; // quotient = 0
	}
	if (!(b.hi)) // divisor is 32-bit
	{
		if (b.lo == 0) // divide by 0
		{
			char x = 0;
			x = 1 / x; // force an exception
		}
		if (b.lo == 1) // divide by 1
		{
			if (c)
				*c = (u64){.hi = 0, .lo = 0}; // remainder = 0
			return a; // quotient = numerator
		}
		if (!(a.hi)) // numerator is also 32-bit
		{
			if (c) // use generic 32-bit operators
				*c = (u64){.hi = 0, .lo = a.lo % b.lo};
			return (u64){.hi = 0, .lo = a.lo / b.lo};
	}
	}

// let's do long division
	char bits = clz_di(b) - clz_di(a) + 1; // number of bits to iterate (a and b are non-zero)
	u64 rem = shr_di(a, bits); // init remainder
	a = shl_di(a, 64 - bits); // shift numerator to the high bit
	int carry = 0; // start with wrap = 0
	u64 res;
	while (bits-- > 0) // for each bit
	{
		rem = shl_di(rem, 1);
		rem.lo |= a.hi >> 31; // shift numerator MSB to remainder LSB
		a = shl_di(a, 1); // shift out the numerator, shift in wrap
		if (carry)
			a.lo |= 1;
		carry = culel_di(b, rem); // wrap = (b > rem) ? 0 : 0xffffffffffffffff (via sign extension)
		if (carry)
			rem = sub_di(rem, b); // if (wrap) rem -= b
	}
	if (c)
		*c = rem; // maybe set remainder
	res = shl_di(a, 1);
	res.lo = (carry) ? res.lo | 1 : res.lo;
	return res; // return the quotient
}

u64 udiv_di(u64 a, u64 b) { return udivmod_di(a, b, (void *)0); }


s64 div_di(s64 a, s64 b) {
	char signa, signb;
	u64 au, bu;
	s64 r;
	signa = a.hi >> 31;
	signb = b.hi >> 31;
	au = *(u64 *)&(signa ? neg_di(a) : a);
	bu = *(u64 *)&(signb ? neg_di(b) : b);
	r = *(s64 *)&(udivmod_di(au, bu, (void *)0));
	return (signa ^ signb) ? neg_di(r) : r;
}

u64 urem_di(u64 a, u64 b) {
	u64 r;
	udivmod_di(a, b, &r);
	return r;
}

s64 rem_di(s64 a, s64 b) {
	u64 ru;
	s64 rs;
	char signa, signb;
	u64 au, bu;
	signa = a.hi >> 31;
	signb = b.hi >> 31;
	au = *(u64 *)&(signa ? neg_di(a) : a);
	bu = *(u64 *)&(signb ? neg_di(b) : b);
	udivmod_di(au, bu, &ru);
	rs = *(s64 *)&ru;
	return (signa ^ signb) ? neg_di(rs) : rs;
}
