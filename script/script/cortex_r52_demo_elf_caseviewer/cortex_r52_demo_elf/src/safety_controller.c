#include "winAMS_Spmc.h"

#line 9 "C:\\winams1\\script\\cortex_r52_demo_elf\\src\\safety_controller.h"
typedef struct {
int safeSpeed;
int safeTorque;
int faultActive;
} SafetyOutput;
#line 16
SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd);
int SafetyController_SelfTest(int simulatedSensor);
#line 3 "C:\\winams1\\script\\cortex_r52_demo_elf\\src\\safety_controller.c"
extern void WinAMS_SPMC_Init(void);
#line 5
int main(void)
{(WinAMS_SPMC_CALL("main",1),
WinAMS_SPMC_C0("main",7),WinAMS_SPMC_Init());
while(WinAMS_SPMC_C0("main",8)||(WinAMS_SPMC_C1("main",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("main",3,(WinAMS_SPMC_Exp(0,(1)!=0)),1,3) || WinAMS_SPMC_resVal)))
{
#line 11
 WinAMS_SPMC_C1("main",4);} WinAMS_SPMC_C1("main",5);
}
#line 14
static int clamp_int(int value, int min, int max)
{
WinAMS_SPMC_C0("safety_controller.c/clamp_int",16);if ((WinAMS_SPMC_C1("safety_controller.c/clamp_int",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("safety_controller.c/clamp_int",1,(WinAMS_SPMC_Exp(0,(value< min))),1,3) || WinAMS_SPMC_resVal))) {
WinAMS_SPMC_C0("safety_controller.c/clamp_int",17); WinAMS_SPMC_C1("safety_controller.c/clamp_int",4);return min;
} else{WinAMS_SPMC_C0("safety_controller.c/clamp_int",18); if ((WinAMS_SPMC_C1("safety_controller.c/clamp_int",7)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("safety_controller.c/clamp_int",3,(WinAMS_SPMC_Exp(0,(value > max))),1,7) || WinAMS_SPMC_resVal))) {
WinAMS_SPMC_C0("safety_controller.c/clamp_int",19); WinAMS_SPMC_C1("safety_controller.c/clamp_int",8);return max;
} else {
WinAMS_SPMC_C0("safety_controller.c/clamp_int",21); WinAMS_SPMC_C1("safety_controller.c/clamp_int",10);return value;
} WinAMS_SPMC_C1("safety_controller.c/clamp_int",12);} WinAMS_SPMC_C1("safety_controller.c/clamp_int",13);
}
#line 28
int SafetyController_SelfTest(int simulatedSensor)
{
int result;
#line 32
WinAMS_SPMC_C0("SafetyController_SelfTest",32);if ((WinAMS_SPMC_C1("SafetyController_SelfTest",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController_SelfTest",1,(WinAMS_SPMC_Exp(0,(simulatedSensor == 1))),1,3) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController_SelfTest",4),WinAMS_SPMC_C0("SafetyController_SelfTest",33),result = 1;
} else {
 WinAMS_SPMC_C1("SafetyController_SelfTest",5),WinAMS_SPMC_C0("SafetyController_SelfTest",35),result = 0;
} WinAMS_SPMC_C1("SafetyController_SelfTest",6);
WinAMS_SPMC_C0("SafetyController_SelfTest",37);return result;
}
#line 40
SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd)
{
SafetyOutput out;
int spd;
int limit;
int tq;
int selftest_result;
#line 48
WinAMS_SPMC_C0("SafetyController",48),out.faultActive = 0;
WinAMS_SPMC_C0("SafetyController",49),out.safeSpeed = 0;
WinAMS_SPMC_C0("SafetyController",50),out.safeTorque = 0;
#line 53
WinAMS_SPMC_C0("SafetyController",53),selftest_result =(WinAMS_SPMC_CALL("SafetyController",1), SafetyController_SelfTest(sensorOK));
WinAMS_SPMC_C0("SafetyController",54),(void)selftest_result;
#line 57
WinAMS_SPMC_C0("SafetyController",57),spd =(WinAMS_SPMC_CALL("SafetyController",2), clamp_int(speed, -1000000, 1000000));
WinAMS_SPMC_C0("SafetyController",58),limit =(WinAMS_SPMC_CALL("SafetyController",3), clamp_int(maxSpeed, -1000000, 1000000));
WinAMS_SPMC_C0("SafetyController",59),tq =(WinAMS_SPMC_CALL("SafetyController",4), clamp_int(torqueCmd, -1000000, 1000000));
#line 62
WinAMS_SPMC_C0("SafetyController",62);if ((WinAMS_SPMC_C1("SafetyController",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",23,(!WinAMS_SPMC_Exp(0,(sensorOK)!=0)),1,3) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",4),WinAMS_SPMC_C0("SafetyController",63),out.faultActive = 1;
WinAMS_SPMC_C0("SafetyController",64),out.safeSpeed = 0;
WinAMS_SPMC_C0("SafetyController",65),out.safeTorque = 0;
WinAMS_SPMC_C0("SafetyController",66);return out;
} WinAMS_SPMC_C1("SafetyController",6);
#line 70
WinAMS_SPMC_C0("SafetyController",70);if ((WinAMS_SPMC_C1("SafetyController",7)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",29,(WinAMS_SPMC_Exp(0,(spd > limit))),1,7) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",8),WinAMS_SPMC_C0("SafetyController",71),out.faultActive = 1;
} WinAMS_SPMC_C1("SafetyController",9);
#line 75
WinAMS_SPMC_C0("SafetyController",75);if ((WinAMS_SPMC_C1("SafetyController",10)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",31,(WinAMS_SPMC_Exp(0,(out.faultActive)!=0)),1,10) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",11),WinAMS_SPMC_C0("SafetyController",76),out.safeSpeed = spd;
WinAMS_SPMC_C0("SafetyController",77),out.safeTorque = 0;
} else {
 WinAMS_SPMC_C1("SafetyController",12),WinAMS_SPMC_C0("SafetyController",79),out.safeSpeed = spd;
WinAMS_SPMC_C0("SafetyController",80),out.safeTorque = tq;
} WinAMS_SPMC_C1("SafetyController",13);
#line 83
WinAMS_SPMC_C0("SafetyController",83);return out;
}
