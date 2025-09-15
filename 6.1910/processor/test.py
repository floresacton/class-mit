#!/usr/bin/env python3
import subprocess, glob, sys, itertools, argparse, collections, re, datetime
from typing import List, Dict, Optional, Callable
import os.path
import sys
import time

def green(text: str) -> str:
    if sys.stdout.isatty():
        return "\x1b[32m{}\x1b[0m".format(text)
    else:
        return text
def red(text: str) -> str:
    if sys.stdout.isatty():
        return "\x1b[31m{}\x1b[0m".format(text)
    else:
        return text
def bold(text: str) -> str:
    if sys.stdout.isatty():
        return "\x1b[1m{}\x1b[0m".format(text)
    else:
        return text

def extensionless_basename(filename: str) -> str:
    filename = os.path.basename(filename)
    if "." in filename:
        filename = filename[:filename.index(".")]
    return filename

def get_dump_lines(text: str) -> List[str]:
    ret = []
    go = False
    for line in text.split("\n"):
        if "Dumping the state" in line:
            go = True
        if go:
            ret.append(line.strip())
    return ret

def run_test(processor: str, folder: str, test: str, timeout: Optional[int], do_print: bool) -> str:
    if do_print:
        print(bold("Running {}:".format(test)), end=" ")

    try: os.remove("mem.vmh")
    except IOError: pass
    os.symlink(os.path.join("sw", "build", folder, test + ".vmh"), "mem.vmh")

    result = subprocess.run([os.path.join(".", processor)], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout)
    if (len(result.stdout) > 1024*1024*512):
        print("Test output is too large to process. Please make sure you are not displaying every-cycle")
        sys.exit(1)

    stdout = result.stdout.decode("utf-8", errors="replace")

    os.makedirs(os.path.join("test_out", folder), exist_ok=True)
    with open(os.path.join("test_out", folder, "{}.out".format(test)), "wb") as outfile:
        outfile.write(result.stdout)

    return stdout

def compare_print_dump(folder: str, test: str, stdout: str, show_all: bool, hide_all: bool) -> bool:
    # folder = "microtests" | "pipetests"
    real_lines = get_dump_lines(stdout)

    try:
        with open("sw/{}/{}.expected".format(folder, test)) as infile:
            expected_lines = [line.strip() for line in infile.read().split("\n")]
    except IOError:
        print(red("No expected output found! Something is wrong, contact course staff."))
        expected_lines = []

    passed = True
    display_lines: List[str] = []
    for real, expected in itertools.zip_longest(real_lines, expected_lines):
        if real == expected:
            # Some lines that are just text are rather silly to mark as OK.  So
            # only print the lines with a "=" in them, which are the lines with
            # the register values we really care about.
            if "=" in real:
                display_lines.append("{} {}".format(real, green("\u2713 OK")))
            else:
                display_lines.append(real)
        else:
            display_lines.append("{} {}".format(real, red("\u2717 EXPECTED " + str(expected))))
            passed = False

    if (show_all or not passed) and not hide_all:
        print()
        for line in display_lines:
            print("  " + line)

        try:
            assembly_filename = os.path.join("sw", folder, test + ".S")
            print("  Description of test {} (from {}):".format(test, assembly_filename))
            with open(assembly_filename) as infile:
                for line in infile:
                    if line.startswith("//"):
                        print("  " + line.strip())
                    else:
                        break
        except IOError:
            print(red("Assembly source not found! Something is wrong, contact course staff."))

    return passed


def compare_print_dump_mnist(folder: str, test: str, stdout: str) -> bool:
    try:
        with open("sw/{}/{}.expected".format(folder, test)) as infile:
            expected_lines = [line.strip() for line in infile.read().split("\n")]
    except IOError:
        print(red("No expected output found! Something is wrong, contact course staff."))
        expected_lines = []

    passed = False
    # display_lines: List[str] = []
    expected_line_idx = 0
    for stdout_line in stdout.split("\n"):
        if stdout_line == expected_lines[expected_line_idx]:
            expected_line_idx += 1
        
        if expected_line_idx == len(expected_lines):
            passed = True
            break

    return passed

def main():
    parser = argparse.ArgumentParser(description='Run tests for Lab 6.')
    # parser.add_argument('processor', type=str, nargs='?', help='which processor(s) to test')
    parser.add_argument('tests', type=str, nargs='?', help='which test(s) to run')
    parser.add_argument('--show-all', action='store_true', help='Show output even for passing tests')
    parser.add_argument('--didit', action='store_true', help='Didit output')
    parser.add_argument('--timeout', metavar='N', type=int, nargs='?', help='Make tests time out after N seconds')
    parser.add_argument('--quick', action='store_true', help='Skip synth')

    args = parser.parse_args()

    t_start = time.time()
    stdout_for_make = subprocess.DEVNULL if args.didit else 1
    make_result = subprocess.run(["make", "-C", "sw"], stdout=stdout_for_make, stderr=2)
    t_end = time.time()
    print(f'{sys.argv[0]}: Compiling all software took {t_end-t_start:.3f} seconds.', file=sys.stderr)
    print(f'--------------------------------------', file=sys.stderr)
    if make_result is None or make_result.returncode != 0:
        print(f'{sys.argv[0]}: Cannot run tests because of compile errors. Check above for error messages.', file=sys.stderr)
        sys.exit(1)

    # if args.processor:
    #     response = args.processor
    # else:
    #     print("What processor do you want to test?")
    #     print("1) SingleCycle")
    #     print("2) MultiCycle")
    #     print("3) SingleCycle and MultiCycle")
    #     response = input()

    # if response == "1":
    #     processors = ["ProcSingleCycle"]
    # elif response == "2":
    #     processors = ["ProcMultiCycle"]
    # elif response == "3":
    #     processors = ["ProcSingleCycle", "ProcMultiCycle"]
    # else:
    #     print("ERROR Unexpected response:", response)
    #     sys.exit(1)
    processors = ["Processor"]

    for processor in processors:
        if not os.path.isfile(processor):
            print("ERROR File", processor, "does not exist. Did you run make?")
            sys.exit(1)
        if not os.access(processor, os.X_OK):
            print("ERROR File", processor, "exists but is not executable. This shouldn't happen but you might be able to fix it by running `chmod u+x " + processor + "`.")
            sys.exit(1)

    printed_choices: List[str] = []

    def collect_test_dict(folder, readable_name, key_all) -> Dict[str, List[str]]:
        ret = collections.defaultdict(list)
        ret[key_all] = []
        for test in sorted(glob.glob(os.path.join(".", "sw", "build", folder, "*.vmh"))):
            test = extensionless_basename(test)
            ret[test].append(test)
            if readable_name:
                printed_choices.append("{}) {} {}".format(test, readable_name, test))
            ret[key_all].append(test)
        return ret

    microtest_dict: Dict[str, List[str]] = collections.defaultdict(list)

    for microtest in sorted(glob.glob("./sw/build/microtests/*.vmh")):
        # parse "./sw/build/microtests/01_lui.vmh" into "01_lui"
        microtest = os.path.basename(microtest)
        assert "_" in microtest, "Unexpected microtest file name " + microtest

        # get the "01" part
        prefix = microtest[:microtest.index("_")]
        microtest_dict[prefix].append(microtest)
        # let people type "1" instead of "01"
        if prefix.startswith("0"):
            microtest_dict[prefix[1:]].append(microtest)
            printed_choices.append("{}) microtest {}".format(prefix[1:], microtest))
        else:
            printed_choices.append("{}) microtest {}".format(prefix, microtest))

        # let people type "05" for all of "05a", "05b", "05c", etc.
        if prefix[-1].isalpha():
            microtest_dict[prefix[:-1]].append(microtest)
        # combine the above
        if prefix.startswith("0") and prefix[-1].isalpha():
            microtest_dict[prefix[1:-1]].append(microtest)

        microtest_dict["a"].append(microtest)
        microtest_dict["all"].append(microtest)

    printed_choices.append("a) all microtests")

    fullasmtest_dict = collect_test_dict("fullasmtests", "full asm test", "f")
    printed_choices.append("f) full asm tests")

    pipetest_dict: Dict[str, List[str]] = collections.defaultdict(list)
    pipetest_dict["p1"].append("01_no_hazards")
    pipetest_dict["p" ].append("01_no_hazards")
    pipetest_dict["p2"].append("02_all_data_hazards")
    pipetest_dict["p" ].append("02_all_data_hazards")
    pipetest_dict["p3"].append("03_all_control_hazards")
    pipetest_dict["p" ].append("03_all_control_hazards")
    pipetest_dict["p4"].append("04_all_hazards")
    pipetest_dict["p" ].append("04_all_hazards")
    printed_choices.append("p1) pipeline test 01_no_hazards")
    printed_choices.append("p2) pipeline test 02_all_data_hazards")
    printed_choices.append("p3) pipeline test 03_all_control_hazards")
    printed_choices.append("p4) pipeline test 04_all_hazards")
    printed_choices.append("p) all pipeline tests")

    # We're in part 2 if we're in the part2 directory
    # NOTE: This reliably gets the script's directory
    isPart2 = os.path.dirname(os.path.realpath(__file__)).endswith("part2")
    mnist_dict: Dict[str, List[str]] = collections.defaultdict(list)
    mnist_dict["m0"].append("mnist_fast")
    printed_choices.append("m0) mnist_fast (will always fail)")
    mnist_dict["m1"].append("mnist_test1")
    printed_choices.append("m1) mnist_test 1")
    mnist_dict["m2"].append("mnist_test5")
    printed_choices.append("m2) mnist_test 5")
    mnist_dict["m3"].append("mnist_test10")
    printed_choices.append("m3) mnist_test 10")
    mnist_dict["m4"].append("mnist_test20")
    printed_choices.append("m4) mnist_test 20")

    mnist_dict["mul32"].append("mul32_test")
    printed_choices.append("mul32) 32 bit multiplication")
    mnist_dict["mul64"].append("mul64_test")
    printed_choices.append("mul64) 64 bit multiplication")
    mnist_dict["packmul"].append("packmul_test")
    printed_choices.append("mul64) 4x8 packed multiplication")
    

    if args.tests:
        response = args.tests
    elif args.didit:
        print("FAILED test.py missing test argument!")
        sys.exit(1)
    else:
        print("Which tests would you like to run?")
        print("1) microtest 01_lui")
        print("2) microtest 02_addi")
        print("3) microtest 03_add")
        print("4) microtest 04_bne")
        print("a) all microtests")
        print("f) full asm tests")
        print("p1) pipeline test 01_no_hazards")
        print("p2) pipeline test 02_all_data_hazards")
        print("p3) pipeline test 03_all_control_hazards")
        print("p4) pipeline test 04_all_hazards")
        print("p) all pipeline tests")
        print("m0) mnist_fast")
        print("m1) mnist_test 1 image")
        print("m2) mnist_test 5 image")
        print("m3) mnist_test 10 image")
        print("m4) mnist_test 20 image")
        print("mul32) 32 bit multiplication")
        print("mul64) 64 bit multiplication")
        print("packmul) 4x8 packed multiplication")

        # print("m2) mnist_bench (your mnist code, for benchmarking)")
        print("Hit ENTER for more choices.")
        response = input()

        while response == "":
            for line in printed_choices:
                print(line)
            print("You can also specify multiple comma-separated tests.")

            response = input()

    microtests = []
    fullasmtests = []
    pipetests = []
    mnisttests = []

    for token in response.split(","):
        token = token.strip()
        if token in microtest_dict:
            microtests.extend(microtest_dict[token])
        elif token in fullasmtest_dict:
            fullasmtests.extend(fullasmtest_dict[token])
        elif token in pipetest_dict:
            pipetests.extend(pipetest_dict[token])
        elif token in mnist_dict:
            mnisttests.extend(mnist_dict[token])
        else:
            print("ERROR Unexpected response", response)
            sys.exit(1)

    passed_tests = []
    failed_tests = []

    def record_passed_or_failed(processor: str, test: str, passed: bool) -> None:
        if passed:
            if not args.didit:
                print(green("{}: PASSED".format(test)))
            passed_tests.append(test)
        else:
            if not args.didit:
                print(red("{}: FAILED".format(test)))
            failed_tests.append(test)

    def run_tests(processor: str, folder: str, readable_name: str, tests: List[str], checker: Callable[[str, str], bool]) -> None:
        if tests:
            if not args.didit:
                print(bold("Running {} {}".format(len(tests),
                    readable_name + "s" if len(tests) != 1 else readable_name)))

            for test in tests:
                test = extensionless_basename(test)
                try:
                    stdout = run_test(processor, folder, test, timeout=args.timeout, do_print=not args.didit)
                    passed = checker(test, stdout)
                except subprocess.TimeoutExpired:
                    print(red("{} timed out after {} seconds!".format(test, args.timeout)))
                    passed = False

                record_passed_or_failed(processor, test, passed)

    def check_microtest(test: str, stdout: str) -> bool:
        return compare_print_dump("microtests", test, stdout, show_all=args.show_all, hide_all=args.didit)
    def check_pipetest(test: str, stdout: str) -> bool:
        return compare_print_dump("pipetests", test, stdout, show_all=args.show_all, hide_all=args.didit)

    def check_regular_test(_: str, stdout: str) -> bool:
        return ("PASSED" in stdout and
                "FAILED" not in stdout and
                "Dumping the" not in stdout)

    def check_sort_test(test: str, stdout: str) -> bool:
        c = re.search(r"Total Clock Cycles =\s+([0-9]+)", stdout)
        if not c:
            print(red("Clock cycles not found! You may have a compile error (i.e., check mnist_src/model.c and mnist_src/mul.h)."))
            return False
        
        cycles = int(c.group(1))
        print("Total Cycles = {}".format(cycles))
        if not compare_print_dump_mnist("mnist", test, stdout):
            print(red("Did not produce expected output"))
            return False

        if not args.quick:
            print("Running synth...")
            t_start = time.time()
            result = subprocess.run(["synth", "Processor.ms", "Processor", "-i", "-l", "multisize"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            synth_stdout = result.stdout.decode("utf-8", errors="replace")
            with open(os.path.join("test_out", "synth.out".format(test)), "wb") as outfile:
                outfile.write(result.stdout)
            t_end = time.time()
            print(f'{sys.argv[0]}: Synthesis took {t_end-t_start:.3f} seconds.', file=sys.stderr)

            if "Error" in synth_stdout or "Synthesis complete" not in synth_stdout:
                print(red("Synthesis did not complete successfully!"))
                print(f"Reason: {synth_stdout}")
                return False

            period = re.search("Critical-path delay: ([0-9]+\.[0-9]+)", synth_stdout)
            if not period:
                print(red("Critical-path delay not found!"))
                return False
            period = float(period.group(1))

            area = re.search(r"Total\s+[0-9]+\s+([0-9]+\.[0-9]+)", synth_stdout)
            if not area:
                print(red("Area not found!"))
                return False
            area = float(area.group(1))

            icache = re.search(r"iMem_data\s+Maybe#\(Line\)", synth_stdout)
            dcache = re.search(r"dMem_data\s+Maybe#\(Line\)", synth_stdout)
            if icache and dcache:
                print("Instruction and data caches present: YES")
            else:
                print("Instruction and data caches present: NO ")

            print("Processor has clock period = {:.02f} ps, area (excluding memory) = {:.02f} um^2".format(period, area))
            print("Runtime = {:.02f} ns ({:.02f} ps * {} cycles)".format(period * cycles / 1000, period, cycles))

            with open("{}.log".format(test), "a") as outfile:
                outfile.write("{}: area {:.02f} um^2, runtime {:.02f} ns (clock period {:.02f} ps * {} cycles)\n".format(datetime.datetime.now(), area, period * cycles / 1000, period, cycles))
        else:
            with open("{}.log".format(test), "a") as outfile:
                outfile.write("{}: {} cycles\n".format(datetime.datetime.now(), cycles))

        return True

    for processor in processors:
        run_tests(processor, "microtests",   "microtest",      microtests,     check_microtest)
        run_tests(processor, "fullasmtests", "full asm test",  fullasmtests,   check_regular_test)
        run_tests(processor, "pipetests",    "pipe test",      pipetests,      check_pipetest)
        run_tests(processor, "mnist",         "mnist test",      mnisttests,      check_sort_test)

    if not args.didit:
        print()
    final_messages = []
    if passed_tests:
        if args.didit:
            print(green("PASSED {} test{}".format(
                len(passed_tests),
                "s" if len(passed_tests) != 1 else "")))
        else:
            print(green("PASSED {} test{}: {}".format(
                len(passed_tests),
                "s" if len(passed_tests) != 1 else "",
                ", ".join(passed_tests))))
    if failed_tests:
        if args.didit:
            print(red("FAILED {} test{} starting with {}".format(
                len(failed_tests),
                "s" if len(failed_tests) != 1 else "",
                failed_tests[0])))
        else:
            print(red("FAILED {} test{}: {}".format(
                len(failed_tests),
                "s" if len(failed_tests) != 1 else "",
                ", ".join(failed_tests))))
        sys.exit(1)
    if not passed_tests and not failed_tests:
        print(red("ERROR No tests found! Is everything compiled?"))
        sys.exit(1)

if __name__ == "__main__":
    main()
