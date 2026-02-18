
# WinAMS Usage Guide — Fault‑Tolerant Motor Speed Monitor

This guide assumes you have built `build/safety_controller.o` using the provided Makefile.

## 1) Create a Project and Add Object Code
1. Open **WinAMS** → Create a new project.
2. Add binary/object: select `build/safety_controller.o`.
3. Confirm that symbols are visible (compiled with `-g`).

## 2) Select Function Under Test
- Choose function: `SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd)`

## 3) Define Inputs/Outputs
- **Inputs**: `speed`, `maxSpeed`, `sensorOK`, `torqueCmd`
- **Outputs** (struct `SafetyOutput` fields): `safeSpeed`, `safeTorque`, `faultActive`

## 4) Import Test Cases
- Import CSV: `tests/test_cases.csv`
- Map columns to parameters/expected outputs:
  - Inputs → `speed`, `maxSpeed`, `sensorOK`, `torqueCmd`
  - Expected Outputs → `exp_safeSpeed`, `exp_safeTorque`, `exp_faultActive`

> If WinAMS requests a specific format, configure the CSV mapping accordingly. The included CSV uses plain headers to make mapping trivial.

## 5) Execute & Review
- Run all test cases.
- View coverage → Target **C0/C1/MC/DC**.
- Export report as evidence (PDF/HTML) if needed.

## 6) Tips
- Keep compiler optimization at `-O0` to simplify MC/DC instrumentation and line mapping.
- If you later link an ELF, ensure debug info (`-g`) remains and avoid LTO.
- For more complex demos, add state (e.g., latched faults, hold counters) to increase decision complexity.
