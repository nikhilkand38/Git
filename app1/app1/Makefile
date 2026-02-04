AS = arm-none-eabi-as
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
CFLAGS  = -mcpu=cortex-r52 -mthumb -O2 -ffreestanding -fno-builtin -nostdlib -nostartfiles
LDFLAGS = -T src/linker.ld -Wl,--gc-sections

all: $(BUILD_DIR)/application.elf

$(BUILD_DIR)/application.elf: $(BUILD_DIR)/vectors.o $(BUILD_DIR)/application.o
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@
	$(OBJCOPY) -O binary $@ $(BUILD_DIR)/application.bin

$(BUILD_DIR)/vectors.o: src/vectors.s
	$(AS) -mcpu=cortex-r52 $< -o $@

$(BUILD_DIR)/application.o: src/application.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)/*.o $(BUILD_DIR)/*.elf $(BUILD_DIR)/*.bin