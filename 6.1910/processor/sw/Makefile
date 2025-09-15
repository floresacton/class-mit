# This looks for riscv32-unknown-elf-gcc or riscv64-unknown-elf-gcc and sets
# RISCV_TARGET accordingly. The check_for_riscv_target variable is used to
# abort compilation if no RISC-V compiler was found.
#RVNE_EXISTS:=$(shell command -v /opt/riscv/bin/riscv32-unknown-elf-gcc 2> /dev/null)
#check_for_riscv_target=$(error No RISC-V compiler found. \
#		       Expecting riscv-none-embed-gcc. \
#		       Please restart terminal to update tools.)

#ifdef RVNE_EXISTS
RISCV_TARGET=riscv32-unknown-elf-
check_for_riscv_target=
#endif

ifndef CL_BYTES
CL_BYTES=4
endif

CFLAGS=-mcmodel=medany -nostdlib -nostartfiles -march=rv32i -mabi=ilp32 -mstrict-align -static -fvisibility=hidden
LDFLAGS=-march=rv32i -nostdlib -nostartfiles -Wl,-Ttools/bare-link.ld
OBJDUMPFLAGS=-s -d -Mno-aliases -Mnumeric

MICROTESTS_VMH=$(patsubst microtests/%.S, build/microtests/%.vmh, $(wildcard microtests/*.S))
MICROTESTS_DUMP=$(patsubst microtests/%.S, build/microtests/%.dump, $(wildcard microtests/*.S))
GCDTESTS_VMH=$(patsubst gcdtests/%.S, build/gcdtests/%.vmh, $(wildcard gcdtests/*.S))
GCDTESTS_DUMP=$(patsubst gcdtests/%.S, build/gcdtests/%.dump, $(wildcard gcdtests/*.S))
FULLASMTESTS_VMH=$(patsubst fullasmtests/%.S, build/fullasmtests/%.vmh, $(wildcard fullasmtests/*.S))
FULLASMTESTS_DUMP=$(patsubst fullasmtests/%.S, build/fullasmtests/%.dump, $(wildcard fullasmtests/*.S))

PIPETESTS_VMH=$(patsubst pipetests/%.S, build/pipetests/%.vmh, $(wildcard pipetests/*.S))
PIPETESTS_DUMP=$(patsubst pipetests/%.S, build/pipetests/%.dump, $(wildcard pipetests/*.S))


all: microtests fullasmtests pipetests mnist # benchmarks 

microtests: $(MICROTESTS_VMH) $(MICROTESTS_DUMP)

gcdtests: $(GCDTESTS_VMH) $(GCDTESTS_DUMP)

fullasmtests: $(FULLASMTESTS_VMH) $(FULLASMTESTS_DUMP)

pipetests: $(PIPETESTS_VMH) $(PIPETESTS_DUMP)

# benchmarks: build/benchmarks
mnist: make_mnist

make_mnist:
	mkdir -p build/mnist
	rm -f ./mnist/src/mul.h ./mnist/src/model.c
	cp -p ../mnist_src/mul.h ./mnist/src/mul.h
	cp -p ../mnist_src/model.c ./mnist/src/model.c
	make -C mnist -j
	cp mnist/*.vmh build/mnist/.
	cp mnist/*.dump build/mnist/.	


# mircotests targets

build/microtests/%.riscv: microtests/%.S
	$(call check_for_riscv_target)
	@mkdir -p build/microtests
	$(RISCV_TARGET)gcc $(CFLAGS) $(LDFLAGS) $^ -o $@

build/microtests/%.vmh: build/microtests/%.riscv tools/elf2hex/elf2hex
	./tools/elf2hex/elf2hex $< 0 16K $(CL_BYTES) $@

build/microtests/%.dump: build/microtests/%.riscv
	$(call check_for_riscv_target)
	$(RISCV_TARGET)objdump $(OBJDUMPFLAGS) $^ > $@

# gcdtests targets

build/gcdtests/%.riscv: gcdtests/%.S
	$(call check_for_riscv_target)
	@mkdir -p build/gcdtests
	$(RISCV_TARGET)gcc $(CFLAGS) $(LDFLAGS) $^ -o $@

build/gcdtests/%.vmh: build/gcdtests/%.riscv tools/elf2hex/elf2hex
	./tools/elf2hex/elf2hex $< 0 16K $(CL_BYTES) $@

build/gcdtests/%.dump: build/gcdtests/%.riscv
	$(call check_for_riscv_target)
	$(RISCV_TARGET)objdump $(OBJDUMPFLAGS) $^ > $@

# fullasmtests targets

build/fullasmtests/%.riscv: fullasmtests/%.S
	$(call check_for_riscv_target)
	@mkdir -p build/fullasmtests
	$(RISCV_TARGET)gcc $(CFLAGS) -I fullasmtests $(LDFLAGS) $^ -o $@

build/fullasmtests/%.vmh: build/fullasmtests/%.riscv tools/elf2hex/elf2hex
	./tools/elf2hex/elf2hex $< 0 16K $(CL_BYTES) $@

build/fullasmtests/%.dump: build/fullasmtests/%.riscv
	$(call check_for_riscv_target)
	$(RISCV_TARGET)objdump $(OBJDUMPFLAGS) $^ > $@

# pipetests targets

build/pipetests/%.riscv: pipetests/%.S
	$(call check_for_riscv_target)
	@mkdir -p build/pipetests
	$(RISCV_TARGET)gcc $(CFLAGS) $(LDFLAGS) $^ -o $@

build/pipetests/%.vmh: build/pipetests/%.riscv tools/elf2hex/elf2hex
	./tools/elf2hex/elf2hex $< 0 16K $(CL_BYTES) $@

build/pipetests/%.dump: build/pipetests/%.riscv
	$(call check_for_riscv_target)
	$(RISCV_TARGET)objdump $(OBJDUMPFLAGS) $^ > $@

# benchmark targets

# build/benchmarks:
# 	make -C benchmarks

# mnist targets
# build/mnist: $(shell find mnist -type f)
# 	mkdir -p build/mnist
# 	make -C mnist -j
# 	cp mnist/*.vmh build/mnist/.
# 	cp mnist/*.dump build/mnist/.	

# Technically this should be a phony target, but we're assuming this tool
# will not change often.
tools/elf2hex/elf2hex:
	make -C tools/elf2hex

clean:
	rm -rf build __pycache__ tools/__pycache__
	rm -f *.dump *.vmh *.x86
	make -C mnist clean

.PHONY: all microtests gcdtests fullasmtests clean
