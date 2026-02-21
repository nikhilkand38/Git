#include "winAMS_Spmc.h"

/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.h(9) */
typedef struct {
int safeSpeed;
int safeTorque;
int faultActive;
} SafetyOutput;
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.h(26) */
SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd);
int SafetyController_SelfTest(void);
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(4) */
static int clamp_int(int v, int min, int max)
{
if ((WinAMS_SPMC_C1("safety_controller.c/clamp_int",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("safety_controller.c/clamp_int",1,(WinAMS_SPMC_Exp(0,(v < min))
),1,3) || WinAMS_SPMC_resVal))){ WinAMS_SPMC_C1("safety_controller.c/clamp_int",4); return min;} WinAMS_SPMC_C1("safety_controller.c/clamp_int",6);
if ((WinAMS_SPMC_C1("safety_controller.c/clamp_int",7)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("safety_controller.c/clamp_int",3,(WinAMS_SPMC_Exp(0,(v > max))
),1,7) || WinAMS_SPMC_resVal))){ WinAMS_SPMC_C1("safety_controller.c/clamp_int",8); return max;} WinAMS_SPMC_C1("safety_controller.c/clamp_int",10);
return v;
}
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(14) */
int SafetyController_SelfTest(void)
{
int simulatedSensor = 1;
int result = 1;
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(19) */
if ((WinAMS_SPMC_C1("SafetyController_SelfTest",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController_SelfTest",3,(WinAMS_SPMC_Exp(0,(simulatedSensor == 1))
),1,3) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController_SelfTest",4),result = 1;
} else {
 WinAMS_SPMC_C1("SafetyController_SelfTest",5),result = 0;
} WinAMS_SPMC_C1("SafetyController_SelfTest",6);
return result;
}
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(27) */
SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd)
{
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(30) */
SafetyOutput out;
int spd;
int limit;
int tq;
int selftest_result;
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(37) */
out.faultActive = 0;
out.safeSpeed = 0;
out.safeTorque = 0;
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(42) */
selftest_result = SafetyController_SelfTest();
(void)selftest_result;
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(46) */
spd = clamp_int(speed, -1000000, 1000000);
limit = clamp_int(maxSpeed, -1000000, 1000000);
tq = clamp_int(torqueCmd, -1000000, 1000000);
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(51) */
if ((WinAMS_SPMC_C1("SafetyController",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",22,(!WinAMS_SPMC_Exp(0,(sensorOK)!=0)
),1,3) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",4),out.faultActive = 1;
out.safeSpeed = 0;
out.safeTorque = 0;
return out;
} WinAMS_SPMC_C1("SafetyController",6);
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(59) */
if ((WinAMS_SPMC_C1("SafetyController",7)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",28,(WinAMS_SPMC_Exp(0,(spd > limit))
),1,7) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",8),out.faultActive = 1;
} WinAMS_SPMC_C1("SafetyController",9);
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(64) */
if ((WinAMS_SPMC_C1("SafetyController",10)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",30,(WinAMS_SPMC_Exp(0,(out.faultActive)!=0)
),1,10) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",11),out.safeSpeed = spd;
out.safeTorque = 0;
} else {
 WinAMS_SPMC_C1("SafetyController",12),out.safeSpeed = spd;
out.safeTorque = tq;
} WinAMS_SPMC_C1("SafetyController",13);
/* C:\Users\DPG_user\Documents\cortex_r52_demo_elf\src\safety_controller.c(72) */
return out;
}
