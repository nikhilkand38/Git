#include "winAMS_Spmc.h"

#line 9 "C:\\winams1\\demo\\Safety_control_withMAP_file\\case_player\\Source\\safety_controller.h"
typedef struct {
int safeSpeed;
int safeTorque;
int faultActive;
} SafetyOutput;
#line 26
SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd);
int SafetyController_SelfTest(int simulatedSensor);
#line 3 "C:\\winams1\\demo\\Safety_control_withMAP_file\\case_player\\Source\\safety_controller.c"
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
static int clamp_int(int v, int min, int max)
{
WinAMS_SPMC_C0("safety_controller.c/clamp_int",16);if ((WinAMS_SPMC_C1("safety_controller.c/clamp_int",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("safety_controller.c/clamp_int",1,(WinAMS_SPMC_Exp(0,(v < min))),1,3) || WinAMS_SPMC_resVal))) {
WinAMS_SPMC_C0("safety_controller.c/clamp_int",17); WinAMS_SPMC_C1("safety_controller.c/clamp_int",4);return min;
} else{WinAMS_SPMC_C0("safety_controller.c/clamp_int",18); if ((WinAMS_SPMC_C1("safety_controller.c/clamp_int",7)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("safety_controller.c/clamp_int",3,(WinAMS_SPMC_Exp(0,(v > max))),1,7) || WinAMS_SPMC_resVal))) {
WinAMS_SPMC_C0("safety_controller.c/clamp_int",19); WinAMS_SPMC_C1("safety_controller.c/clamp_int",8);return max;
} else {
WinAMS_SPMC_C0("safety_controller.c/clamp_int",21); WinAMS_SPMC_C1("safety_controller.c/clamp_int",10);return v;
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
#line 43
SafetyOutput out;
int spd;
int limit;
int tq;
int selftest_result;
#line 50
WinAMS_SPMC_C0("SafetyController",50),out.faultActive = 0;
WinAMS_SPMC_C0("SafetyController",51),out.safeSpeed = 0;
WinAMS_SPMC_C0("SafetyController",52),out.safeTorque = 0;
#line 55
WinAMS_SPMC_C0("SafetyController",55),selftest_result =(WinAMS_SPMC_CALL("SafetyController",1), SafetyController_SelfTest(sensorOK));
WinAMS_SPMC_C0("SafetyController",56),(void)selftest_result;
#line 59
WinAMS_SPMC_C0("SafetyController",59),spd =(WinAMS_SPMC_CALL("SafetyController",2), clamp_int(speed, -1000000, 1000000));
WinAMS_SPMC_C0("SafetyController",60),limit =(WinAMS_SPMC_CALL("SafetyController",3), clamp_int(maxSpeed, -1000000, 1000000));
WinAMS_SPMC_C0("SafetyController",61),tq =(WinAMS_SPMC_CALL("SafetyController",4), clamp_int(torqueCmd, -1000000, 1000000));
#line 64
WinAMS_SPMC_C0("SafetyController",64);if ((WinAMS_SPMC_C1("SafetyController",3)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",23,(!WinAMS_SPMC_Exp(0,(sensorOK)!=0)),1,3) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",4),WinAMS_SPMC_C0("SafetyController",65),out.faultActive = 1;
WinAMS_SPMC_C0("SafetyController",66),out.safeSpeed = 0;
WinAMS_SPMC_C0("SafetyController",67),out.safeTorque = 0;
WinAMS_SPMC_C0("SafetyController",68);return out;
} WinAMS_SPMC_C1("SafetyController",6);
#line 72
WinAMS_SPMC_C0("SafetyController",72);if ((WinAMS_SPMC_C1("SafetyController",7)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",29,(WinAMS_SPMC_Exp(0,(spd > limit))),1,7) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",8),WinAMS_SPMC_C0("SafetyController",73),out.faultActive = 1;
} WinAMS_SPMC_C1("SafetyController",9);
#line 77
WinAMS_SPMC_C0("SafetyController",77);if ((WinAMS_SPMC_C1("SafetyController",10)||(WinAMS_SPMC_Clr(1) || WinAMS_SPMC_Res("SafetyController",31,(WinAMS_SPMC_Exp(0,(out.faultActive)!=0)),1,10) || WinAMS_SPMC_resVal))) {
 WinAMS_SPMC_C1("SafetyController",11),WinAMS_SPMC_C0("SafetyController",78),out.safeSpeed = spd;
WinAMS_SPMC_C0("SafetyController",79),out.safeTorque = 0;
} else {
 WinAMS_SPMC_C1("SafetyController",12),WinAMS_SPMC_C0("SafetyController",81),out.safeSpeed = spd;
WinAMS_SPMC_C0("SafetyController",82),out.safeTorque = tq;
} WinAMS_SPMC_C1("SafetyController",13);
#line 85
WinAMS_SPMC_C0("SafetyController",85);return out;
}
