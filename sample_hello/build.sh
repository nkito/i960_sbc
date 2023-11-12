


i960-elf-gcc -msa hello.c      -S -o hello.s
i960-elf-gcc -msa systemcall.c -S -o systemcall.s
i960-elf-gcc -msa -nostdlib -nostartfiles \
    small_init.s hello.s systemcall.s \
    -lc -lgcc -lm -T link.ld  -o hello

i960-elf-objcopy -I elf32-i960 -O binary hello hello.bin
i960-elf-objcopy -I elf32-i960 -O ihex   hello hello.hex


