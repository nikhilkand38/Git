#ifndef SAFETY_CONTROLLER_H
#define SAFETY_CONTROLLER_H

#ifdef __cplusplus
extern "C" {
#endif

/* Simple, output for deterministic testing */
typedef struct {
    int safeSpeed;     /* Selected safe speed */
    int safeTorque;    /* Torque command after safety oversight (0 if fault) */
    int faultActive;   /* 1 if any fault condition is active, else 0 */
} SafetyOutput;


SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd);
int SafetyController_SelfTest(int simulatedSensor);

#ifdef __cplusplus
}
#endif

#endif /* SAFETY_CONTROLLER_H */