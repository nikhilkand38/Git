AS	= arm-none-eabi-as
CC	= arm-none-eabi-gcc
OBJCOPY	= arm-none-eabi-objcopy
 
# ============================

# Compiler flags (FIXED)

# ============================

CFLAGS	= \
	-mcpu=cortex-r52 \
	-mthumb \
	-g \
	-O0 \
	-ffreestanding \
	-fno-builtin \
	-fno-inline \
	-fno-omit-frame-pointer \
	-fdata-sections \
	-ffunction-sections \
	-nostdlib \
	-nostartfiles
 
# ============================

# Linker flags (FIXED)

# ============================

LDFLAGS	= \
	-T src/linker.ld \
	-Wl,--no-gc-sections
 
# ============================

# Targets

# ============================

all:	$(BUILD_DIR)/combined_app.elf

$(BUILD_DIR)/combined_app.elf: \
	$(BUILD_DIR)/vectors.o \
	$(BUILD_DIR)/main.o \
	$(BUILD_DIR)/calculator.o \
	$(BUILD_DIR)/winAMS_Spmc.o
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@
	$(OBJCOPY) -O binary $@ $(BUILD_DIR)/combined_app.bin
 
# ============================

# Object files

# ============================

$(BUILD_DIR)/vectors.o:	src/vectors.s
	$(AS) -mcpu=cortex-r52 -g $< -o $@
 
$(BUILD_DIR)/main.o: src/main.c src/calculator.h
	$(CC) $(CFLAGS) -c $< -o $@
 
$(BUILD_DIR)/calculator.o: src/calculator.c src/calculator.h
	$(CC) $(CFLAGS) -c $< -o $@
 
$(BUILD_DIR)/winAMS_Spmc.o: src/winAMS_Spmc.c
	$(CC) $(CFLAGS) -c $< -o $@
 
clean:
	rm -rf $(BUILD_DIR)/*.o $(BUILD_DIR)/*.elf $(BUILD_DIR)/*.bin

 
