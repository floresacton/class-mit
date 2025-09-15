# This looks for riscv32-unknown-elf-gcc or riscv64-unknown-elf-gcc and sets
# RISCV_TARGET accordingly. The check_for_riscv_target variable is used to
# abort compilation if no RISC-V compiler was found.
RVNE_EXISTS:=$(shell command -v /mit/6.004/riscv/compiler/build/bin/riscv32-unknown-elf-gcc 2> /dev/null)
check_for_riscv_target=$(error No RISC-V compiler found. \
		       Expecting riscv-none-embed-gcc. \
		       Please restart terminal to update tools.)

ifdef RVNE_EXISTS
RISCV_TARGET=/mit/6.004/riscv/compiler/build/bin/riscv32-unknown-elf-
check_for_riscv_target=
endif

ifndef CL_BYTES
CL_BYTES=4
endif

CFLAGS+=-mcmodel=medany -nostdlib -nostartfiles -march=rv32i -mabi=ilp32 -mstrict-align -O2
LDFLAGS=-march=rv32i -nostdlib -nostartfiles -Wl,--no-warn-rwx-segments -Wl,-Tsrc/riscv-link.ld

# Specify source files
files = $(wildcard src/*.c) $(wildcard src/*.S)
headers = $(wildcard src/*.h)
cFiles = $(wildcard src/*.c)
sFiles = $(wildcard src/*.S)
files = $(cFiles) $(sFiles)
cObjects = $(patsubst %.c, %.o, $(cFiles))
sObjects = $(patsubst %.S, %.o, $(sFiles)) 
objects = $(cObjects) $(sObjects)

# assemblyFiles = crt0
# cFiles = main
# # Targets
# assemblyObjects = $(addsuffix .o, $(assemblyFiles))
# fileObjects = $(addsuffix .o, $(files))

targets = mnist_fast mnist_test1 mnist_test5 mnist_test10 mnist_test20 mul32_test mul64_test packmul_test
vmhs =  $(addsuffix .vmh, $(targets))
dumps = $(addsuffix .dump, $(targets))
mainFiles = $(addsuffix .c, $(targets))


all: $(vmhs) $(dumps)

$(sObjects): %.o: %.S $(headers)
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(CFLAGS) -c $< -o $@

$(cObjects): %.o: %.c $(headers)
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(CFLAGS) -c $< -o $@

mnist_test%.o: mnist_test.c $(headers)
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(CFLAGS) -DNUM_TEST_TO_RUN=$* -c $< -o $@

mnist_fast.o: mnist_test.c $(headers)
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(CFLAGS) -DINFER_FAST -DNUM_TEST_TO_RUN=1 -c $< -o $@

mul32_test.o: mul32_test.c $(headers)
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(CFLAGS) -c $< -o $@

mul64_test.o: mul64_test.c $(headers)
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(CFLAGS) -c $< -o $@

packmul_test.o: packmul_test.c $(headers)
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(CFLAGS) -c $< -o $@




# main_sort_test.o: src/main.c
# 	$(call check_for_riscv_target)
# 	$(RISCV_TARGET)gcc $(CFLAGS) -c $< -o $@

# main_sort_base.o: src/main.c
# 	$(call check_for_riscv_target)
# 	$(RISCV_TARGET)gcc $(CFLAGS) -D BASELINE -D BENCH -O2 -c $< -o $@

# main_sort_bench.o:  src/main.c
# 	$(call check_for_riscv_target)
# 	$(RISCV_TARGET)gcc $(CFLAGS) -D BENCH -c $< -o $@

mul32_test.riscv: mul32_test.o src/crt0.o src/utils.o
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(LDFLAGS) $^ -o $@
mul64_test.riscv: mul64_test.o src/crt0.o src/utils.o
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(LDFLAGS) $^ -o $@
packmul_test.riscv: packmul_test.o src/crt0.o src/utils.o
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(LDFLAGS) $^ -o $@

%.riscv: %.o $(objects)
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(LDFLAGS) $^ -o $@

%.vmh: %.riscv ../tools/elf2hex/elf2hex
	mkdir -p $(dir $@)
	../tools/elf2hex/elf2hex $< 0 512K $(CL_BYTES) $@

%.dump: %.riscv
	$(call check_for_riscv_target)
	mkdir -p $(dir $@)
	$(RISCV_TARGET)objdump -s -d $^ > $@



# Technically this should be a phony target, but we're assuming this tool
# will not change often.
../tools/elf2hex/elf2hex:
	make -C ../tools/elf2hex

clean:
	rm -rf build __pycache__ tools/__pycache__
	rm -f *.dump *.vmh *.x86 *.o
	rm -f src/*.vmh src/*.o  src/*.dump

.PHONY: all clean

.INTERMEDIATE: $(objects) mnist_test.o mul32_test.o mul64_test.o packmul_test.o
