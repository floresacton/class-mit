#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#  grade
#  Grade design project.

from test_all import report_to_didit

import os
import subprocess
import sys
from typing import *

ID_BASE = "unit"
ID_PROJTEST = f"{ID_BASE}/class:Tests"

def grade_bool(tag: str, passed: bool) -> bool:
    id_str = f"{ID_PROJTEST}/method:{tag}()"
    report_to_didit(f"id={id_str}", "/started")
    if passed:
        print(f"{tag}: PASSED")
        report_to_didit(f"id={id_str}", "/finished/successful")
    else:
        print(f"{tag}: FAILED", file=sys.stderr)
        report_to_didit(f"id={id_str}", "/finished/failed")

    return passed

def report_fail(tag: str, cause: str):
    print(f"{tag}: FAILED {cause}")
    report_to_didit(f"id={ID_PROJTEST}/method:{tag}()&cause={cause}", "/finished/failed")

def test_bin(tag: str, args: List[str], cwd: str, timeout: str = "5s", required_files: Set[str] = set()) -> Tuple[bool, str]:
    id_str = f"{ID_PROJTEST}/method:{tag}()"

    report_to_didit(f"id={id_str}", "/started")
    cause = ""

    # Check that all files exist
    all_exists = True
    for f in required_files:
        if not os.path.exists(f):
            all_exists = False
            break

    if all_exists:

        process = subprocess.run(["timeout", timeout] + args, stdout=subprocess.PIPE, check=False, shell=False, cwd=cwd)
        stdout = process.stdout.decode("utf-8").lower()

        if process.returncode == 124:
            print(f"{tag}: FAILED, timeout")
            cause = "FAILED, timeout"
            stdout = "test timed out\n" + stdout
        elif "fail" in stdout or process.returncode != 0:
            print(f"{tag}: FAILED")
            cause = f"FAILED, {tag} failed"
        elif "pass" in stdout:
            print(f"{tag}: PASSED")

        else:
            print(f"{tag}: FAILED, neither passed nor failed printed")
            cause = "FAILED, neither passed nor failed printed"

    else:
        print(f"{tag}: FAILED, compilation error")
        cause = "FAILED, compilation error"

    if cause == "":
        report_to_didit(f"id={id_str}", "/finished/successful")
    else:
        report_to_didit(f"id={id_str}&cause={cause}", "/finished/failed")

    return (cause == "", stdout)

def grade_processor() -> None:
    cwd = os.getcwd()

    ok, _ = test_bin(tag="fullasmtests", args=["./test.py", "--didit", "f"], cwd=cwd, timeout="300s")

    if not ok:
        report_fail("mnist_test1", "fullasm tests did not pass")
        return

    ok, result = test_bin(tag="mnist_test1", args=["./test.py", "--didit", "m1"], cwd=cwd, timeout="10m")

    with open(f"{cwd}/result.txt", 'w') as f:
        f.write(result)

    if not ok:
        print("FAILED: did not pass mnist_test1")
        print(f"Reason: {result}")
        return

    process = subprocess.run(["bash", "-c", "cat result.txt | ./get_runtime.sh"], stdout=subprocess.PIPE, check=False, shell=False, cwd=cwd)
    stdout = process.stdout.decode("utf-8").lower()

    if stdout == '':
      print(f"FAILED: {result}")
      return

    runtime = int(stdout)
    print(f"Runtime for this program: {runtime}")

    grade_bounds = [
        20000000, 4000000, 2000000, 1500000, 1000000, 850000, 700000, 600000,
        550000, 500000, 460000, 430000, 400000, 370000, 350000, 325000, 300000,
        280000, 260000, 250000
    ]

    score = 0
    for bound in grade_bounds:
        if grade_bool(f"mnist_test_runtime_LE_{bound}", runtime <= bound):
            score += 1 
    
    print(f"Score: {score}")

def main(args: List[str]) -> int:
    # Signal start of all testing
    report_to_didit(f"id={ID_BASE}", "/started")
    grade_processor()

    # End of all testing
    report_to_didit(f"id={ID_BASE}", "/finished/successful")

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
