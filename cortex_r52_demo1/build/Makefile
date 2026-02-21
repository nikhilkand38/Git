# Minimal Makefile for building Cortex‑R52 object for WinAMS
# Usage:
#   make obj    # build safety_controller.o (recommended)
#   make lib    # build static library (optional)
#   make clean
 
CROSS ?= arm-none-eabi-
CC := $(CROSS)gcc
AR := $(CROSS)ar
 
CFLAGS := -mcpu=cortex-r52 -mfloat-abi=soft -O0 -g -ffunction-sections -fdata-sections -fno-builtin -std=c11 -Wall -Wextra
INCLUDES := -I../src
 
OBJDIR := .
SRCDIR := ../src
 
# Add winams_spmc.c to the sources for the build
SRCS := $(SRCDIR)/safety_controller.c $(SRCDIR)/winAMS_spmc.c
 
OBJS := $(SRCS:.c=.o)
 
.PHONY: all obj elf lib clean
 
all: obj elf
 
obj: $(OBJS)
 
# Compile the object files
$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@
 
# ------- Option 2: ELF using GCC built-in linker script (no .ld, no main) -------
elf: $(OBJS)
	$(CC) $(CFLAGS) -nostartfiles -nostdlib -Wl,-e,0x8000 \
		$(OBJS) -o safety_controller.elf
 
lib: obj
	$(AR) rcs $(OBJDIR)/libsafety_controller.a $(OBJS)
 
clean:
	rm -f $(OBJS) $(OBJDIR)/libsafety_controller.a $(OBJDIR)/safety_controller.elf