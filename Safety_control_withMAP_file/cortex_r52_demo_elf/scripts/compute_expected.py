
#!/usr/bin/env python3
"""
Helper script to recompute expected outputs for the SafetyController and
(optionally) regenerate the CSV. This is not required by WinAMS, but helps
validate the truth table offline.
"""

from dataclasses import dataclass
from typing import Tuple
import csv
import sys

@dataclass
class SafetyOutput:
    safeSpeed: int
    safeTorque: int
    faultActive: int


def clamp(v: int, lo: int, hi: int) -> int:
    return max(lo, min(hi, v))


def safety_controller(speed: int, maxSpeed: int, sensorOK: int, torqueCmd: int) -> SafetyOutput:
    spd = clamp(speed, -1000000, 1000000)
    limit = clamp(maxSpeed, -1000000, 1000000)
    tq = clamp(torqueCmd, -1000000, 1000000)

    if not sensorOK:
        return SafetyOutput(0, 0, 1)

    fault = 1 if (spd > limit) else 0

    if fault:
        return SafetyOutput(spd, 0, 1)
    else:
        return SafetyOutput(spd, tq, 0)


def main(csv_in: str):
    with open(csv_in, newline='') as f:
        r = csv.DictReader(f)
        for row in r:
            out = safety_controller(int(row['speed']), int(row['maxSpeed']), int(row['sensorOK']), int(row['torqueCmd']))
            print(row['case_id'], out)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: compute_expected.py tests/test_cases.csv')
        sys.exit(1)
    main(sys.argv[1])
