
MEMORY
{
    rom (rx):	     ORIGIN = 0x00000000, LENGTH = 0x0f800   /* 512Kbit flash */
    rom_data (rx):   ORIGIN = 0x0000f800, LENGTH = 0x00800   /*Enough space must be reserved in rom*/
                                        /*after the text section to hold the  */
                                        /*initial values of the data section. */
    data (rw):	ORIGIN = 0x40000000, LENGTH = 0x0800
    bss (rw):	ORIGIN = 0x40000800, LENGTH = 0x8000
}

SECTIONS
{
	.text :
	{
        } > rom

        rom_data = LOADADDR(.data);

	.data :
	{
                __Bdata = .;
                *(.data)
                *(.data*)
                __Edata = .;
        } > data AT > rom 

	.bss :
	{
                __Bbss = .;
                *(.bss)
                *(.bss*)
        } > bss

	.comm :
	{
                *(.comm)
                __Ebss = .;
        } > bss
}

_checksum = -(_rom_prcb + _start_ip);

