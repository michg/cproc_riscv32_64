#
# Makefile for Libs
RESDIR = ../bin/
CC=../../cproc/cproc
AS=../../elftools/minias/minias
LD=../../elftools/neatld/nld
AR =../../elftools/ar/ar
CFLAGS = -mrv32 -S



CSRCS = $(wildcard *.c)
ASRCS = $(patsubst %.c,%.s,$(CSRCS))
OSRCS = $(patsubst %.c,%.o,$(CSRCS))
OBJS = $(addprefix $(RESDIR), $(OSRCS))
BIN = $(RESDIR)libari6432.a $(RESDIR)libari6464.a

.PHONY:		all
.PRECIOUS: $(RESDIR)%.s

all:		$(BIN)

$(RESDIR)%.s:%.c
	$(CC) -o $(basename $@).tmp $(CFLAGS) $<
	cpp -include ../../defs.inc $(basename $@).tmp -o $@

$(RESDIR)%.o:$(RESDIR)%.s
	$(AS) -o $@ $<

$(BIN):$(OBJS)
	$(AR) -rcs $@ $^
	rm -f $(OBJS)

$(RESDIR)libari6464.a:
	cp $(RESDIR)libari6432.a $@
