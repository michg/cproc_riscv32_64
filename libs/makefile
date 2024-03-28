RESDIR = bin/
CC=../cproc/cproc
AS=../elftools/minias/minias
LD=../elftools/neatld/nld
AR = ../elftools/ar/ar
CFLAGS = -S -I include

LIBS = $(RESDIR)/libmathhf.a $(RESDIR)/libminlibc.a $(RESDIR)/libari64.a


.PHONY:		all

.PRECIOUS:$(RESDIR)%.s

all:$(RESDIR) $(LIBS)

$(LIBS):
	make -r -C libmath -f makehf
	make -r -C libminlibc
	make -r -C libari64

$(RESDIR):
	mkdir -p $@

clean:
	rm -f -r $(RESDIR)
