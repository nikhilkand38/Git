
#include "safety_controller.h"

// Internal clamp utility to keep values predictable in tests
static int clamp_int(int v, int min, int max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
}

SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd)
{
    SafetyOutput out = {0, 0, 0};

    // Normalize unrealistic inputs for stable test expectations
    int spd = clamp_int(speed, -1000000, 1000000);
    int limit = clamp_int(maxSpeed, -1000000, 1000000);
    int tq = clamp_int(torqueCmd, -1000000, 1000000);

    // 1) Sensor failure is highest priority
    if (!sensorOK) {
        out.faultActive = 1;
        out.safeSpeed = 0;     // Force to 0 when sensor failed
        out.safeTorque = 0;    // Cut torque
        return out;
    }

    // 2) Overspeed check
    if (spd > limit) {
        out.faultActive = 1;
    }

    // 3) Output selection
    if (out.faultActive) {
        out.safeSpeed = spd;   // Keep measured speed visible for logging/diagnostics
        out.safeTorque = 0;    // Enforce torque cut when fault
    } else {
        out.safeSpeed = spd;   // Normal operation
        out.safeTorque = tq;   // Pass‑through torque
    }

    return out;
}
