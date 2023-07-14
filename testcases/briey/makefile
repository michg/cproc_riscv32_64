RESDIR = result/
CC=../../cproc/cproc
AS=../../elftools/minias/minias
LD=../../elftools/neatld/nld
AR = ../../elftools/ar/ar
CFLAGS = -S -I include

LIBS = ../../libs/bin/libmathhf.a

CSRCS = es.c
ASRCS = start.s
OSRCS = start.o es.o
OBJS = $(addprefix $(RESDIR), $(OSRCS))
BIN = $(RESDIR)firmware.bin

.PHONY:		all

.PRECIOUS:$(RESDIR)%.s

all:$(RESDIR) $(LIBS) $(BIN)


$(RESDIR):
	mkdir -p $@

$(RESDIR)%.s:%.c
	$(CC) -mrv32 -S -o $(basename $@).tmp $<
	cpp -include ../../defs.inc $(basename $@).tmp -o $@


$(RESDIR)%.o:%.s
	$(AS) -o $@ $<

$(RESDIR)%.o:$(RESDIR)%.s
	$(AS) -o $@ $<

$(BIN):$(OBJS) $(LIBS)
	$(LD) -mc=0x80000000 -ns -ne -t $(RESDIR)map.txt -o $@ $^
	$(LD) -mc=0x80000000 -o $(RESDIR)firm.elf $^
	python3 mkhex.py $(RESDIR)firmware.bin


clean:
		rm -f -r $(RESDIR)
