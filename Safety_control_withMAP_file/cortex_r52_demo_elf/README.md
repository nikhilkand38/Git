
# WinAMS Demo: Fault‑Tolerant Motor Speed Monitor (Cortex‑R52)

This package contains a **minimal, safety‑oriented C module** that is perfect for demonstrating **WinAMS** machine‑code level unit testing and coverage (C0/C1/MC/DC) on **Cortex‑R52**.

## What’s Inside
- `src/` — The production code (`safety_controller.c/.h`)
- `tests/` — CSV test cases ready to import into WinAMS
- `build/Makefile` — Builds object (`.o`) and static lib (`.a`) using `arm-none-eabi-gcc`
- `winams/` — Step‑by‑step usage guide for WinAMS
- `scripts/compute_expected.py` — Helper to calculate expected outputs (optional)

## Quick Build (no linker/startup required)
```bash
# Pre‑req: GNU Arm Embedded Toolchain in PATH (arm-none-eabi-gcc)
make -C build obj
```
This produces `build/safety_controller.o` — load it directly in **WinAMS**.

> **Note**: For WinAMS unit tests, **no** linker script (`.ld`) or startup file is required. You are testing functions directly at the **machine‑code level**; WinAMS invokes them without a reset/boot flow.

## Targets
```bash
make -C build obj   # build object file only (recommended for WinAMS)
make -C build lib   # build static library (optional)
make -C build clean # remove build artifacts
```

## Function Under Test
```c
SafetyOutput SafetyController(int speed, int maxSpeed, int sensorOK, int torqueCmd);
```
See `src/safety_controller.h` for the data structure.

## Using with WinAMS (summary)
1. Open WinAMS → create a new project.
2. Add binary → select `build/safety_controller.o`.
3. Choose function under test: `SafetyController`.
4. Map arguments to CSV columns.
5. Import `tests/test_cases.csv`.
6. Run → Collect coverage (C0/C1/MC/DC) → Export the report.

Full detail in `winams/winams_instructions.md`.

## License
MIT — see `LICENSE`.
