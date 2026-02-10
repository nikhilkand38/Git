#include "health_service.h"
#include "uart.h"
 
static uint32 cpu_counter = 0;
static uint32 mem_usage = 50;
static uint32 task_alive = 1;
 
void Health_Init(void)
{
    uart_puts("[Health] Init done\n");
}
 
SystemStatus_t Health_CheckCPU(void)
{
    cpu_counter++;
    if (cpu_counter % 5 == 0)
        return SYS_WARN;
    return SYS_OK;
}
 
SystemStatus_t Health_CheckMemory(void)
{
    mem_usage += 5;
    if (mem_usage > 80)
        return SYS_FAIL;
    return SYS_OK;
}
 
SystemStatus_t Health_CheckTasks(void)
{
    if (task_alive)
        return SYS_OK;
    return SYS_FAIL;
}
 
void Health_Report(void)
{
    uart_puts("\n[System Health Report]\n");
 
    SystemStatus_t cpu = Health_CheckCPU();
    SystemStatus_t mem = Health_CheckMemory();
    SystemStatus_t task = Health_CheckTasks();
 
    uart_puts("CPU Status: ");
    uart_putnum(cpu);
    uart_puts("\nMemory Status: ");
    uart_putnum(mem);
    uart_puts("\nTask Status: ");
    uart_putnum(task);
    uart_puts("\n---------------------\n");
}