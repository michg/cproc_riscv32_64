RESDIR = ../bin/
CC = ../../cproc/cproc
AS = ../../elftools/minias/minias
AR = ../../elftools/ar/ar
C_FILES := $(wildcard *.c)
O_FILES := $(patsubst %.c,%.o,$(C_FILES))
OBJS = $(addprefix $(RESDIR), $(O_FILES)) 
LIBRARY := $(RESDIR)libminlibc.a
CFLAGS =  -mrv32 -S -nostdinc -I include
 
all: $(LIBRARY)
.PRECIOUS: $(RESDIR)%.s 

clean:
	$(RM) -f $(OBJ)

$(LIBRARY): $(OBJS)
	$(AR) -rcs $(LIBRARY) $(OBJS)
	rm -f $(OBJS) 

$(RESDIR)%.s:%.c
	$(CC) -o $(basename $@).tmp $(CFLAGS) $<
	cpp -include ../../defs.inc $(basename $@).tmp -o $@

$(RESDIR)%.o:$(RESDIR)%.s
	$(AS) -o $@ $< 
