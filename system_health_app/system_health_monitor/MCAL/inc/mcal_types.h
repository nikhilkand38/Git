#ifndef MCAL_TYPES_H
#define MCAL_TYPES_H
 
typedef unsigned char uint8;
typedef unsigned int uint32;
typedef signed int sint32;
 
typedef enum {
    SYS_OK = 0,
    SYS_WARN,
    SYS_FAIL
} SystemStatus_t;
 
#endif