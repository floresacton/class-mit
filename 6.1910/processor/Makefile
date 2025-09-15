SHELL:=/bin/bash
CURDIR=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# When msc compiles bluesim code with -O3, there is a known issue where certain valid implementations don't compile
export CXXFLAGS := -O2

.PHONY: all clean synth DirectMappedBeveren TwoWayBeveren decode_test fetch_test prog_test superclean verify_file_hashes_target

MINISPEC_FILES=$(wildcard *.ms)
CACHE_FILES=$(wildcard *Cache*.ms)


all: verify_file_hashes_target Processor

verify_file_hashes_target:
	./verify_file_hashes.py

Processor: Processor.ms $(MINISPEC_FILES)
	time msc $< $@

test_decode: DecodeTB.ms Decode.ms
	msc DecodeTB.ms DecodeTB
	mv DecodeTB $@
	mv DecodeTB.so $@.so

test_execute: ExecuteTB.ms Execute.ms ALU.ms
	msc ExecuteTB.ms ExecuteTB
	mv ExecuteTB $@
	mv ExecuteTB.so $@.so

test_fetch: Processor.ms FetchTB.ms $(CACHE_FILES)
	msc FetchTB.ms FetchTB 
	mv FetchTB $@
	mv FetchTB.so $@.so
	ln -sf fetch_test.vmh mem.vmh

DirectMappedBeveren:
	ms sim DirectMappedCacheTB.ms DirectMappedBeverenTest

TwoWayBeveren:
	ms sim TwoWayCacheTB.ms TwoWayBeverenTest

prog_test: verify_file_hashes_target Processor
	./test.py $(word 2, $(MAKECMDGOALS)) $(if $(filter $(word 3, $(MAKECMDGOALS)),quick),--quick,)

synth: verify_file_hashes_target
	time synth Processor.ms Processor -l multisize -p 100 | tee synth.out

test: all
	./grade.py

# ignore missing targets
%:
	@:

clean:
	rm -rf test_decode test_decode.so 
	rm -rf test_execute test_execute.so
	rm -rf test_fetch test_fetch.so mem.vmh
	rm -rf *.v *.bo *.ba *.cxx *.o *.h *.so
	rm -rf test_out
	rm -rf synthDir
	rm -rf Processor
	rm -rf tmp_msc_*

superclean: clean
	make -C sw clean
