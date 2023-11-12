/*(cb*/
/*******************************************************************************
 *
 * Copyright (c) 1993, 1994 Intel Corporation
 *
 * Intel hereby grants you permission to copy, modify, and distribute this
 * software and its documentation.  Intel grants this permission provided
 * that the above copyright notice appears in all copies and that both the
 * copyright notice and this permission notice appear in supporting
 * documentation.  In addition, Intel grants this permission provided that
 * you prominently mark as "not part of the original" any modifications
 * made to this software or documentation, and that the name of Intel
 * Corporation not be used in advertising or publicity pertaining to
 * distribution of the software or the documentation without specific,
 * written prior permission.
 *
 * Intel Corporation provides this AS IS, WITHOUT ANY WARRANTY, EXPRESS OR
 * IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY
 * OR FITNESS FOR A PARTICULAR PURPOSE.  Intel makes no guarantee or
 * representations regarding the use of, or the results of the use of,
 * the software and documentation in terms of correctness, accuracy,
 * reliability, currentness, or otherwise; and you rely on the software,
 * documentation and results solely at your own risk.
 *
 * IN NO EVENT SHALL INTEL BE LIABLE FOR ANY LOSS OF USE, LOSS OF BUSINESS,
 * LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL DAMAGES
 * OF ANY KIND.  IN NO EVENT SHALL INTEL'S TOTAL LIABILITY EXCEED THE SUM
 * PAID TO INTEL FOR THE PRODUCT LICENSED HEREUNDER.
 *
 ******************************************************************************/
/*)ce*/
/*********************************************************************
 * This module contains the Initial Memory Image, including a PRCB,
 * Control Table (for the CA only), System Address Table (for the
 * Kx only), System Procedure Table, Fault Table, Interrupt Table.
 * These data structures are in ROM during the initial boot.
 * This module also contains the cold start address (start_ip) and
 * the system initialization code.  The initialization code does
 * the following:
 *     * calls pre_init to perform a self-test and enable RAM, if
 *      required
 *    * copies the processor data structures to RAM
 *    * initializes the monitor's data in RAM
 *    * reinitializes the processor, using a sysctl (CA) or IAC (Kx)
 *      to cause the processor to begin using the new PRCB and other
 *      data structures in RAM
 *    * turns off the interrupted state and changes to the monitor's
 *      stack
 *    * branches to main.
 *********************************************************************/

/* core initialization block (8 words located at address 0) */
/* overlaid by system address table (first 8 words of       */
/* system address table are not otherwise used)             */
    .text
    .globl _system_address_table
_system_address_table:
    .word  _system_address_table  /*  0 - SAT pointer    */
    .word  _rom_prcb              /*  4 - PRCB pointer   */
    .word  0
    .word  _start_ip              /* 12 - Initial IP */
    .word  -1
    .word  0
    .word  0
    .word  _checksum              /* calculated by linker */
                                  /* _checksum= -(SAT + PRCB + startIP) */
    .space 88

    .word sys_proc_table          /* 120 */
    .word 0x304000fb              /* 124 */

    .space 8

    .word _system_address_table   /* 136 */
    .word 0x00fc00fb              /* 140 */

    .space 8

    .word sys_proc_table          /* 152 */
    .word 0x304000fb              /* 156 */

    .space 8

    .word trace_proc_table        /* 168 */
    .word 0x304000fb              /* 172 */


/* initial PRCB  */

/* This is our startup PRCB.  After initialization, */
/* this will be copied to RAM                 */
/* Note: This is global so it can be accessed by    */
/* board-dependent code if necessary.               */
    .align 6
    .globl   _rom_prcb
_rom_prcb:
    .word    0x0               #   0 - reserved
    .word    0xc               #   4 - initialize to 0x0c 
    .word    0x0               #   8 - reserved
    .word    0x0               #  12 - reserved 
    .word    0x0               #  16 - reserved 
    .word    boot_intr_table   #  20 - interrupt table address
    .word    _intr_stack       #  24 - interrupt stack pointer
    .word    0x0               #  28 - reserved
    .word    0x000001ff        #  32 - pointer to offset zero
    .word    0x0000027f        #  36 - system procedure table pointer
    .word    boot_flt_table    #  40 - fault table
    .space   176-44            #  44 - 172 - reserved

/* Rom system procedure table */
/* This table defines the fault entry point.
 * It is used for the trace fault table on the Kx. 
 * Sys_proc_table is initialized by set_prcb the first time it is called,
 * and that procedure table is used for all other entry points to the monitor.
 * The CA requires a valid system procedure table during initialization, so
 * this table is referenced by _rom_prcb.  Ram_prcb refers to sys_proc_table.
 * The Kx SAT refers to sys_proc_table.  The Kx does not require a valid
 * system procedure table during initialization.
 * The supervisor trace bit is off by default.
 */
    .text
    .align 6
rom_sys_proc_table:
trace_proc_table:
    .space   12                 # Reserved
    .word    _trap_stack        # Supervisor stack pointer      
    .space   32                 # Preserved
    .word    _fault_entry+2     # trace handler

/* Entries marked with a * must not be moved to retain backward compatibility */


/*************************************************
 * Boot Fault Table
 * This is only used for a fault during
 * initialization, which is always a fatal error.
 *************************************************/

    .text
    .align    4
boot_flt_table:
    .word    _fatal_fault, 0        # parallel/Override Fault
    .word    _fatal_fault, 0        # Trace Fault
    .word    _fatal_fault, 0        # Operation Fault
    .word    _fatal_fault, 0        # Arithmetic Fault
    .word    _fatal_fault, 0        # Floating Point Fault
    .word    _fatal_fault, 0        # Constraint Fault
    .word    _fatal_fault, 0        # Virtual Memory Fault (MC)
    .word    _fatal_fault, 0        # Protection Fault
    .word    _fatal_fault, 0        # Machine Fault
    .word    _fatal_fault, 0        # Structural Fault (MC) 
    .word    _fatal_fault, 0        # Type Fault
    .word    _fatal_fault, 0        # Type 11 Reserved Fault Handler
    .word    _fatal_fault, 0        # Process Fault (MC)
    .word    _fatal_fault, 0        # Descriptor Fault (MC)
    .word    _fatal_fault, 0        # Event Fault (MC)
    .word    _fatal_fault, 0        # Type 15 Reserved Fault Handler
    .space    16*8            # reserved



/*************************************************
 * Boot Interrupt Table
 * This is only used for a spurious interrupt during
 * initialization, which is always a fatal error.
 **************************************************/

    .text
boot_intr_table:
    .word    0
    .word    0, 0, 0, 0, 0, 0, 0, 0
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr, _fatal_intr
    .word    _fatal_intr, _fatal_intr, _fatal_intr

/* START */
/* Processor starts execution here after reset. */
    .text
    .globl    _start_ip
    .globl    _reinit
_start_ip:

/* ------------------------------------------------- */
/* Initialization for UART functionality of MFP68901 */
/* ------------------------------------------------- */
    ldconst   0x88, g3		/* x16, 8bit, N, 1  */
    lda       0x80000028, g2	/* UCR              */
    stob      g3,(g2)

    ldconst   0x01, g3		/*                  */
    lda       0x8000002a, g2	/* RSR              */
    stob      g3,(g2)

    ldconst   0x05, g3		/*                  */
    lda       0x8000002c, g2	/* TSR              */
    stob      g3,(g2)

    ldconst   0x41, g3		/*                  */
    lda       0x8000002e, g2    /* UDR              */
    stob      g3,(g2)
/* ------------------------------------------------- */


/* Copy the .data area into RAM.  It has been packed in the EPROM
 * after the code area.  If the copy is not needed (RAM-based monitor), 
 * the symbol rom_data can be defined as 0 in the linker directives file.
 */
    lda       rom_data, g1       # load source of copy
    cmpobe    0, g1, 1f
    lda       __Bdata, g2        # load destination
    lda       __Edata, g0
    subo      g2, g0, g0         # calculate length of data area
    bal       move_data          # call copy routine
1:
/* Initialize the BSS area of RAM. */
    lda      __Bbss, g2       # start of bss
    lda      __Ebss, g0       # end of bss
    subo     g2, g0, g0       # calculate length of bss
    ldconst  0, g1            # data to fill
    bal      fill_data        # call fill routine

/*
 In this sample, many lines were deleted from the Intel's original code.
 Please find and see the original one.
*/

    mov 0, g14
loop:
    callx  _start
    b loop


/* This routine is used to copy data during initialization  */
move_data:    
    ldconst 0, r3
1:
    ld      (g1)[r3*1], r4      # load word into r4
    st      r4, (g2)[r3*1]       # store to destination
    addo    4, r3, r3      # increment index    
    cmpobg  g0, r3, 1b      # loop until done

    bx    (g14)


/* This routine is used to fill data during initialization  */
fill_data:
    ldconst  0, r3
1:
    st       g1, (g2)[r3*1]       # store data to destination
    addo     4, r3, r3      # increment index    
    cmpobg   g0, r3, 1b      # loop until done

    bx    (g14)



.globl _fatal_intr
.globl _fatal_fault
.globl _fault_entry
_fatal_intr:
_fatal_fault:
_fault_entry:
    b _fatal_intr

    .bss    sys_proc_table, 1088, 6
    .bss    intr_table, 1028, 6
    .bss    fault_table, 32*8, 4

    .globl    _intr_stack
    .globl    _user_stack
    .globl    _trap_stack
    .bss      _user_stack, 0x0200, 6        # default application stack 
    .bss      _intr_stack, 0x0600, 6        # interrupt stack
    .bss      _trap_stack, 0x0800, 6        # fault (supervisor) stack


