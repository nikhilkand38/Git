/* Simple, output for deterministic testing */
 struct {
    int safeSpeed;     /* Selected safe speed */
    int safeTorque;    /* Torque command after safety oversight (0 if fault) */
    int faultActive;   /* 1 if any fault condition is active, else 0 */
}