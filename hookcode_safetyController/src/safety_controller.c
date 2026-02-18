#include "winAMS_Spmc.h"

#line 9 "C:\\winAMS_CM1\\case2player\\Source\\safety_controller.h"
typedef struct {
int safeSpeed;
int safeTorque;
int faultActive;
} SafetyOutput;
#line 26
SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd);
int SafetyController_SelfTest(void);
#line 4 "C:\\winAMS_CM1\\case2player\\Source\\safety_controller.c"
static int clamp_int(int v, int min, int max)
{
if ((WinAMS_SPMC_C1("safety_controller.c/clamp_int",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("safety_controller.c/clamp_int",1,(WinAMS_SPMC_Exp(0,(v < min))),1,3) || WinAMS_SPMC_resVal))){ WinAMS_SPMC_C1("safety_controller.c/clamp_int",4); return min;} WinAMS_SPMC_C1("safety_controller.c/clamp_int",6);
if ((WinAMS_SPMC_C1("safety_controller.c/clamp_int",7)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("safety_controller.c/clamp_int",3,(WinAMS_SPMC_Exp(0,(v > max))),1,7) || WinAMS_SPMC_resVal))){ WinAMS_SPMC_C1("safety_controller.c/clamp_int",8); return max;} WinAMS_SPMC_C1("safety_controller.c/clamp_int",10);
return v;
}
#line 14
int SafetyController_SelfTest(void)
{
int simulatedSensor = 1;
int result = 1;
#line 19
if ((WinAMS_SPMC_C1("SafetyController_SelfTest",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController_SelfTest",3,(WinAMS_SPMC_Exp(0,(simulatedSensor == 1))),1,3) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController_SelfTest",4),result = 1;
} else {
 WinAMS_SPMC_C1("SafetyController_SelfTest",5),result = 0;
} WinAMS_SPMC_C1("SafetyController_SelfTest",6);
return result;
}
#line 27
SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd)
{
#line 30
SafetyOutput out;
int spd;
int limit;
int tq;
int selftest_result;
#line 37
out.faultActive = 0;
out.safeSpeed = 0;
out.safeTorque = 0;
#line 42
selftest_result = SafetyController_SelfTest();
(void)selftest_result;
#line 46
spd = clamp_int(speed, -1000000, 1000000);
limit = clamp_int(maxSpeed, -1000000, 1000000);
tq = clamp_int(torqueCmd, -1000000, 1000000);
#line 51
if ((WinAMS_SPMC_C1("SafetyController",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",22,(!WinAMS_SPMC_Exp(0,(sensorOK)!=0)),1,3) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",4),out.faultActive = 1;
out.safeSpeed = 0;
out.safeTorque = 0;
return out;
} WinAMS_SPMC_C1("SafetyController",6);
#line 59
if ((WinAMS_SPMC_C1("SafetyController",7)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",28,(WinAMS_SPMC_Exp(0,(spd > limit))),1,7) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",8),out.faultActive = 1;
} WinAMS_SPMC_C1("SafetyController",9);
#line 64
if ((WinAMS_SPMC_C1("SafetyController",10)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",30,(WinAMS_SPMC_Exp(0,(out.faultActive)!=0)),1,10) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",11),out.safeSpeed = spd;
out.safeTorque = 0;
} else {
 WinAMS_SPMC_C1("SafetyController",12),out.safeSpeed = spd;
out.safeTorque = tq;
} WinAMS_SPMC_C1("SafetyController",13);
#line 72
return out;
}
