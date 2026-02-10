#ifndef HEALTH_SERVICE_H
#define HEALTH_SERVICE_H
 
#include "mcal_types.h"
 
void Health_Init(void);
SystemStatus_t Health_CheckCPU(void);
SystemStatus_t Health_CheckMemory(void);
SystemStatus_t Health_CheckTasks(void);
void Health_Report(void);
 
#endif
 