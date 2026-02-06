cmake_minimum_required(VERSION 3.16)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
project(cortex_r52_calc C ASM)
 
set(SOURCES
    main.c
    vector.s
    MCAL/src/mcal_types.c
    BSP/src/uart.c
    SERVICES/src/calc_service.c
    APP/src/app.c
)
 
include_directories(
    MCAL/inc
    BSP/inc
    SERVICES/inc
    APP/inc
)
 
add_executable(application.elf ${SOURCES})
 
set_target_properties(application.elf PROPERTIES
    LINK_FLAGS "-T ${CMAKE_SOURCE_DIR}/linker.ld -nostdlib -Wl,--gc-sections"
)