set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
 
set(TOOLCHAIN_PREFIX arm-none-eabi-)
 
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)
 
set(CMAKE_C_FLAGS "-mcpu=cortex-r52 -marm -ffreestanding -fno-builtin -nostdlib")
set(CMAKE_ASM_FLAGS "-mcpu=cortex-r52")

