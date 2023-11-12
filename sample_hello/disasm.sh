#!/bin/sh

i960-elf-objdump -m i960 -b binary --adjust-vma=0 -D hello.bin

