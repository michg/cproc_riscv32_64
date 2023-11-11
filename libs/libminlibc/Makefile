RESDIR = ../bin/
CC = ../../cproc/cproc
AS = ../../elftools/minias/minias
AR = ../../elftools/ar/ar
C_FILES := $(wildcard *.c)
O32_FILES := $(patsubst %.c,%.o32,$(C_FILES))
O64_FILES := $(patsubst %.c,%.o64,$(C_FILES))
OBJS32 = $(addprefix $(RESDIR), $(O32_FILES))
OBJS64 = $(addprefix $(RESDIR), $(O64_FILES))
LIB32 := $(RESDIR)libminlibc32.a
LIB64 := $(RESDIR)libminlibc64.a
CFLAGS32 =  -mrv32 -S -nostdinc -I include
CFLAGS64 =  -S -nostdinc -I include
 
all: $(LIB32) $(LIB64)
.PRECIOUS: $(RESDIR)%.s32 $(RESDIR)%.s64

clean:
	$(RM) -f $(OBJ)

$(LIB32): $(OBJS32)
	$(AR) -rcs $(LIB32) $(OBJS32)
	rm -f $(OBJS32)

$(LIB64): $(OBJS64)
	$(AR) -rcs $(LIB64) $(OBJS64)
	rm -f $(OBJS64)

$(RESDIR)%.s32:%.c
	$(CC) -o $(basename $@).t32 $(CFLAGS32) $<
	cpp -include ../../defs.inc $(basename $@).t32 -o $@

$(RESDIR)%.o32:$(RESDIR)%.s32
	$(AS) -o $@ $<

$(RESDIR)%.s64:%.c
	$(CC) -o $(basename $@).t64 $(CFLAGS64) $<
	cpp -include ../../defs.inc $(basename $@).t64 -o $@

$(RESDIR)%.o64:$(RESDIR)%.s64
	$(AS) -o $@ $< 
