#include "winAMS_Spmc.h"

#line 4 "C:\\Users\\winams_user\\Favorites\\Documents\\Git\\cortex_r52_calc\\cortex_r52_calc\\BSP\\inc\\uart.h"
void uart_init(void);
void uart_putc(char c);
void uart_puts(const char *s);
void uart_putnum(int num);
#line 10 "C:\\Users\\winams_user\\Favorites\\Documents\\Git\\cortex_r52_calc\\cortex_r52_calc\\BSP\\src\\uart.c"
void uart_init(void)
{
WinAMS_SPMC_C0("uart_init",12),(*(volatile unsigned int *)(0xE7C00000ul + 0x08)) = 0;
WinAMS_SPMC_C0("uart_init",13),(*(volatile unsigned int *)(0xE7C00000ul + 0x10)) = 434;
WinAMS_SPMC_C0("uart_init",14),(*(volatile unsigned int *)(0xE7C00000ul + 0x08)) = (1u << 0) | (1u << 1) | (1u << 2);
}
#line 17
void uart_putc(char c)
{
while (WinAMS_SPMC_C0("uart_putc",19)||(WinAMS_SPMC_C1("uart_putc",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("uart_putc",1,(WinAMS_SPMC_Exp(0,((*(volatile unsigned int *)(0xE7C00000ul + 0x04)) & 1u)!=0)),1,3) || WinAMS_SPMC_resVal))) { WinAMS_SPMC_C1("uart_putc",4);} WinAMS_SPMC_C1("uart_putc",5);
WinAMS_SPMC_C0("uart_putc",20),(*(volatile unsigned int *)(0xE7C00000ul + 0x00)) = (unsigned int)c;
}
#line 23
void uart_puts(const char *s)
{
while (WinAMS_SPMC_C0("uart_puts",25)||(WinAMS_SPMC_C1("uart_puts",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("uart_puts",1,(WinAMS_SPMC_Exp(0,(*s)!=0)),1,3) || WinAMS_SPMC_resVal))){(WinAMS_SPMC_CALL("uart_puts",1), WinAMS_SPMC_C1("uart_puts",4), uart_putc(*s++));} WinAMS_SPMC_C1("uart_puts",5);
}
#line 28
void uart_putnum(int num)
{
char buf[12];
int i = 0;
#line 33
WinAMS_SPMC_C0("uart_putnum",33);if ((WinAMS_SPMC_C1("uart_putnum",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("uart_putnum",2,(WinAMS_SPMC_Exp(0,(num == 0))),1,3) || WinAMS_SPMC_resVal))) {(WinAMS_SPMC_CALL("uart_putnum",1),
 WinAMS_SPMC_C1("uart_putnum",4),WinAMS_SPMC_C0("uart_putnum",34),uart_putc('0'));
WinAMS_SPMC_C0("uart_putnum",35);return;
} WinAMS_SPMC_C1("uart_putnum",6);
#line 38
WinAMS_SPMC_C0("uart_putnum",38);if ((WinAMS_SPMC_C1("uart_putnum",7)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("uart_putnum",6,(WinAMS_SPMC_Exp(0,(num < 0))),1,7) || WinAMS_SPMC_resVal))) {(WinAMS_SPMC_CALL("uart_putnum",2),
 WinAMS_SPMC_C1("uart_putnum",8),WinAMS_SPMC_C0("uart_putnum",39),uart_putc('-'));
WinAMS_SPMC_C0("uart_putnum",40),num = -num;
} WinAMS_SPMC_C1("uart_putnum",9);
#line 43
while (WinAMS_SPMC_C0("uart_putnum",43)||(WinAMS_SPMC_C1("uart_putnum",10)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("uart_putnum",11,(WinAMS_SPMC_Exp(0,(num > 0))),1,10) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("uart_putnum",11),WinAMS_SPMC_C0("uart_putnum",44),buf[i++] = (num % 10) + '0';
WinAMS_SPMC_C0("uart_putnum",45),num /= 10;
} WinAMS_SPMC_C1("uart_putnum",12);
#line 48
while (WinAMS_SPMC_C0("uart_putnum",48)||(WinAMS_SPMC_C1("uart_putnum",13)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("uart_putnum",15,(WinAMS_SPMC_Exp(0,(i--)!=0)),1,13) || WinAMS_SPMC_resVal))){(WinAMS_SPMC_CALL("uart_putnum",3), WinAMS_SPMC_C1("uart_putnum",14), uart_putc(buf[i]));} WinAMS_SPMC_C1("uart_putnum",15);
}
