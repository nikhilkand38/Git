#ifndef SAFETY_CONTROLLER_H
#define SAFETY_CONTROLLER_H

#ifdef __cplusplus
extern "C" {
#endif

// Simple, POD output for deterministic testing
typedef struct {
    int safeSpeed;     // Selected safe speed
    int safeTorque;    // Torque command after safety oversight (0 if fault)
    int faultActive;   // 1 if any fault condition is active, else 0
} SafetyOutput;

// Fault‑Tolerant Motor Speed Monitor
// Inputs:
//  - speed: current measured speed (e.g., RPM or scaled units)
//  - maxSpeed: configured overspeed threshold (same units as speed)
//  - sensorOK: boolean (0/1) — 1 if sensor healthy, 0 if failed
//  - torqueCmd: requested torque (arbitrary units)
// Behavior:
//  - If sensor failed → fault=1, safeSpeed=0, safeTorque=0
//  - Else if overspeed (speed > maxSpeed) → fault=1, safeTorque=0 (speed is passed through)
//  - Else → fault=0, pass through speed & torque
// Designed to exercise MC/DC on conditions.
SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd);
int SafetyController_SelfTest(void);

#ifdef __cplusplus
}
#endif

#endif // SAFETY_CONTROLLER_H