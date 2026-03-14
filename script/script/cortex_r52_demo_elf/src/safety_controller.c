#include "safety_controller.h"

extern void WinAMS_SPMC_Init(void);/*updated to support WinAMS */

int main(void)
{
    WinAMS_SPMC_Init();
    while(1)
    {
        /* comment */
    }
}
/* Internal clamp utility to keep values predictable in tests */
static int clamp_int(int value, int min, int max)
{
    if (value< min) {
        return min;
    } else if (value > max) {
        return max;
    } else {
        return value;
    }
}

/* Optional self-test stub: returns 1 (pass) for now.
   Verify sensors, ranges, and configuration.
*/
int SafetyController_SelfTest(int simulatedSensor)
{
    int result;

    if (simulatedSensor == 1) {
        result = 1;
    } else {
        result = 0;
    }
    return result;
}

SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd)
{
    SafetyOutput out;
    int spd;
    int limit;
    int tq;
    int selftest_result;

    out.faultActive = 0;
    out.safeSpeed   = 0;
    out.safeTorque  = 0;

    /* Call self test (unused result for now, but may be logged) */
    selftest_result = SafetyController_SelfTest(sensorOK);
    (void)selftest_result;

    /* Normalize unrealistic inputs for stable test expectations */
    spd   = clamp_int(speed,     -1000000, 1000000);
    limit = clamp_int(maxSpeed,  -1000000, 1000000);
    tq    = clamp_int(torqueCmd, -1000000, 1000000);

    /* 1) Sensor failure is highest priority */
    if (!sensorOK) {
        out.faultActive = 1;
        out.safeSpeed = 0;     /* Force to 0 when sensor failed */
        out.safeTorque = 0;    /* Cut torque */
        return out;
    }

    /* 2) Overspeed check */
    if (spd > limit) {
        out.faultActive = 1;
    }

    /* 3) Output selection */
    if (out.faultActive) {
        out.safeSpeed = spd;   /* Keep measured speed visible for logging/diagnostics */
        out.safeTorque = 0;    /* Enforce torque cut when fault */
    } else {
        out.safeSpeed = spd;   /* Normal operation */
        out.safeTorque = tq;   /* Pass-through torque */
    }

    return out;
}
 