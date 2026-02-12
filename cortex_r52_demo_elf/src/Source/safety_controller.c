#include "winAMS_Spmc.h"

#line 10 "C:\\Users\\user_kpit\\Documents\\winAMS_CM1\\UnitTestDemo\\CasePlayer2Demo\\Source\\safety_controller.h"
typedef struct {
int safeSpeed;
int safeTorque;
int faultActive;
} SafetyOutput;
#line 27
SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd);
#line 5 "C:\\Users\\user_kpit\\Documents\\winAMS_CM1\\UnitTestDemo\\CasePlayer2Demo\\Source\\safety_controller.c"
static int clamp_int(int v, int min, int max) {
WinAMS_SPMC_C0("safety_controller.c/clamp_int",6);if ((WinAMS_SPMC_C1("safety_controller.c/clamp_int",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("safety_controller.c/clamp_int",1,(WinAMS_SPMC_Exp(0,(v < min))),1,3) || WinAMS_SPMC_resVal))){ WinAMS_SPMC_C1("safety_controller.c/clamp_int",4); return min;} WinAMS_SPMC_C1("safety_controller.c/clamp_int",6);
WinAMS_SPMC_C0("safety_controller.c/clamp_int",7);if ((WinAMS_SPMC_C1("safety_controller.c/clamp_int",7)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("safety_controller.c/clamp_int",3,(WinAMS_SPMC_Exp(0,(v > max))),1,7) || WinAMS_SPMC_resVal))){ WinAMS_SPMC_C1("safety_controller.c/clamp_int",8); return max;} WinAMS_SPMC_C1("safety_controller.c/clamp_int",10);
WinAMS_SPMC_C0("safety_controller.c/clamp_int",8);return v;
}
#line 11
SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd)
{
SafetyOutput out = {0, 0, 0};
#line 16
int spd = clamp_int(speed, -1000000, 1000000);
int limit = clamp_int(maxSpeed, -1000000, 1000000);
int tq = clamp_int(torqueCmd, -1000000, 1000000);
#line 21
WinAMS_SPMC_C0("SafetyController",21);if ((WinAMS_SPMC_C1("SafetyController",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",4,(!WinAMS_SPMC_Exp(0,(sensorOK)!=0)),1,3) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",4),WinAMS_SPMC_C0("SafetyController",22),out.faultActive = 1;
WinAMS_SPMC_C0("SafetyController",23),out.safeSpeed = 0;
WinAMS_SPMC_C0("SafetyController",24),out.safeTorque = 0;
WinAMS_SPMC_C0("SafetyController",25);return out;
} WinAMS_SPMC_C1("SafetyController",6);
#line 29
WinAMS_SPMC_C0("SafetyController",29);if ((WinAMS_SPMC_C1("SafetyController",7)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",10,(WinAMS_SPMC_Exp(0,(spd > limit))),1,7) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",8),WinAMS_SPMC_C0("SafetyController",30),out.faultActive = 1;
} WinAMS_SPMC_C1("SafetyController",9);
#line 34
WinAMS_SPMC_C0("SafetyController",34);if ((WinAMS_SPMC_C1("SafetyController",10)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",12,(WinAMS_SPMC_Exp(0,(out.faultActive)!=0)),1,10) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",11),WinAMS_SPMC_C0("SafetyController",35),out.safeSpeed = spd;
WinAMS_SPMC_C0("SafetyController",36),out.safeTorque = 0;
} else {
 WinAMS_SPMC_C1("SafetyController",12),WinAMS_SPMC_C0("SafetyController",38),out.safeSpeed = spd;
WinAMS_SPMC_C0("SafetyController",39),out.safeTorque = tq;
} WinAMS_SPMC_C1("SafetyController",13);
#line 42
WinAMS_SPMC_C0("SafetyController",42);return out;
}
