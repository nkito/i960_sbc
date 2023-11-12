gcc2_compiled.:
___gnu_compiled_c:
.text
	.align 4
	.globl _serial_putc
	#  Function 'serial_putc'
	#  Registers used: g0 g4 g5 fp cc 
	#		   
_serial_putc:
	addo	16,sp,sp
	#Prologue stats:
	#  Total Frame Size: 16 bytes
	#  Local Variable Size: 16 bytes
	#End Prologue#
	stob	g0,64(fp)
L2:
	ldob	-2147483604,g4
	setbit	7,0,g5	# ldconst 128,g5
	and	g4,g5,g4
	shlo	24,g4,g5
	shro	24,g5,g4
	cmpi	g4,0
	be L4
	b	L3
L4:
	b	L2
L3:
	ldob	64(fp),g4
	stob	g4,-2147483602
	ret
	.align 4
	.globl _serial_getc
	#  Function 'serial_getc'
	#  Registers used: g0 g4 g5 fp cc 
	#		   
_serial_getc:
	addo	16,sp,sp
	#Prologue stats:
	#  Total Frame Size: 16 bytes
	#  Local Variable Size: 16 bytes
	#End Prologue#
L5:
	ldob	-2147483606,g4
	setbit	7,0,g5	# ldconst 128,g5
	and	g4,g5,g4
	shlo	24,g4,g5
	shro	24,g5,g4
	cmpi	g4,0
	be L7
	b	L6
L7:
	b	L5
L6:
	ldob	-2147483602,g4
	stob	g4,64(fp)
	ldob	64(fp),g4
	mov	g4,g0
	ret
	ret
	.align 4
	.globl _isUSARTDataAvailable
	#  Function 'isUSARTDataAvailable'
	#  Registers used: g0 g4 g5 fp 
_isUSARTDataAvailable:
	ldob	-2147483606,g4
	setbit	7,0,g5	# ldconst 128,g5
	and	g4,g5,g4
	shlo	24,g4,g5
	shro	24,g5,g4
	mov	g4,g0
	ret
	ret
.bss	_sbrk_buf.12,10000,0
.bss	_heap_end.13,4,2
	.align 4
LC0:
	.ascii "Heap and stack collision\12\0"
	.align 4
	.globl _sbrk
	#  Function 'sbrk'
	#  Registers used: g0 g1 g2 g4 g5 fp sp 
	#		   r3* cc 
_sbrk:
	addo	16,sp,sp
	#Prologue stats:
	#  Total Frame Size: 16 bytes
	#  Local Variable Size: 16 bytes
	#End Prologue#
	st	g0,64(fp)
	ld	_heap_end.13,g4
	cmpi	g4,0
	bne L8
	mov	0,g4
	st	g4,_heap_end.13
L8:
	ld	_heap_end.13,g4
	st	g4,68(fp)
	ld	_heap_end.13,g4
	ld	64(fp),g5
	addo	g4,g5,g4
	ldconst	0x2710,g5
	cmpo	g4,g5
	ble L9
	mov	1,g0
	ldconst	LC0,g1
	mov	25,g2
	callx	__write
	callx	_abort
L9:
	ld	_heap_end.13,g4
	ld	64(fp),g5
	addo	g4,g5,g4
	st	g4,_heap_end.13
	ldconst	_sbrk_buf.12,g4
	ld	68(fp),g5
	addo	g4,g5,g4
	mov	g4,g0
	ret
	ret
	.align 4
	.globl _close
	#  Function 'close'
	#  Registers used: g0 g1 fp 
_close:
	addo	16,sp,sp
	#Prologue stats:
	#  Total Frame Size: 16 bytes
	#  Local Variable Size: 16 bytes
	#End Prologue#
	st	g0,64(fp)
	st	g1,68(fp)
	mov	0,g0
	ret
	ret
	.align 4
	.globl _fstat
	#  Function 'fstat'
	#  Registers used: g0 g1 g4 g5 fp 
_fstat:
	addo	16,sp,sp
	#Prologue stats:
	#  Total Frame Size: 16 bytes
	#  Local Variable Size: 16 bytes
	#End Prologue#
	st	g0,64(fp)
	st	g1,68(fp)
	ld	68(fp),g4
	setbit	13,0,g5	# ldconst 8192,g5
	st	g5,4(g4)
	mov	0,g0
	ret
	ret
	.align 4
	.globl _lseek
	#  Function 'lseek'
	#  Registers used: g0 g1 g2 g3 g4 fp 
_lseek:
	addo	16,sp,sp
	#Prologue stats:
	#  Total Frame Size: 16 bytes
	#  Local Variable Size: 16 bytes
	#End Prologue#
	st	g0,64(fp)
	st	g1,68(fp)
	st	g2,72(fp)
	st	g3,76(fp)
	ld	_a,g4
	mov	g4,g0
	ret
	ret
	.align 4
	.globl _read
	#  Function 'read'
	#  Registers used: g0 g1 g2 g4 g5 fp sp 
	#		   r3* cc 
_read:
	lda	32(sp),sp
	#Prologue stats:
	#  Total Frame Size: 32 bytes
	#  Local Variable Size: 32 bytes
	#End Prologue#
	st	g0,64(fp)
	st	g1,68(fp)
	st	g2,72(fp)
	mov	0,g4
	st	g4,76(fp)
L10:
	ld	76(fp),g4
	ld	72(fp),g5
	cmpi	g4,g5
	bl L13
	b	L11
L13:
	callx	_serial_getc
	mov	g0,g4
	stob	g4,80(fp)
	ld	64(fp),g4
	cmpi	g4,0
	bne L14
	ldob	80(fp),g4
	cmpi	g4,13
	bne L15
	mov	13,g0
	callx	_serial_putc
	mov	10,g0
	callx	_serial_putc
	b	L14
L15:
	ldob	80(fp),g4
	cmpi	g4,8
	bne L17
	mov	8,g0
	callx	_serial_putc
	addo	31,1,g0	# ldconst 32,g0
	callx	_serial_putc
	mov	8,g0
	callx	_serial_putc
	b	L14
L17:
	ldob	80(fp),g0
	callx	_serial_putc
L18:
L16:
L14:
	ldob	80(fp),g4
	cmpi	g4,13
	bne L19
	ld	68(fp),g4
	ld	76(fp),g5
	addo	g4,g5,g4
	mov	10,g5
	stob	g5,(g4)
	b	L20
L19:
	ldob	80(fp),g4
	cmpi	g4,8
	bne L21
	ld	76(fp),g4
	subo	1,g4,g5
	st	g5,76(fp)
	b	L20
L21:
	ld	68(fp),g4
	ld	76(fp),g5
	addo	g4,g5,g4
	ldob	80(fp),g5
	stob	g5,(g4)
L22:
L20:
	ldob	80(fp),g4
	cmpi	g4,13
	be L24
	ldob	80(fp),g4
	cmpi	g4,10
	be L24
	b	L12
L24:
	ld	76(fp),g5
	addo	1,g5,g4
	mov	g4,g0
	ret
L23:
L12:
	ld	76(fp),g4
	addo	1,g4,g5
	st	g5,76(fp)
	b	L10
L11:
	ld	72(fp),g4
	mov	g4,g0
	ret
	ret
	.align 4
	.globl _write
	#  Function 'write'
	#  Registers used: g0 g1 g2 g4 g5 fp sp 
	#		   r3* cc 
_write:
	addo	16,sp,sp
	#Prologue stats:
	#  Total Frame Size: 16 bytes
	#  Local Variable Size: 16 bytes
	#End Prologue#
	st	g0,64(fp)
	st	g1,68(fp)
	st	g2,72(fp)
	mov	0,g4
	st	g4,76(fp)
L25:
	ld	76(fp),g4
	ld	72(fp),g5
	cmpi	g4,g5
	bl L28
	b	L26
L28:
	ld	64(fp),g4
	cmpi	g4,2
	bg L29
	ld	68(fp),g4
	ld	76(fp),g5
	addo	g4,g5,g4
	ldob	(g4),g5
	cmpi	g5,10
	bne L29
	mov	13,g0
	callx	_serial_putc
L29:
	ld	68(fp),g4
	ld	76(fp),g5
	addo	g4,g5,g4
	ldob	(g4),g0
	callx	_serial_putc
L27:
	ld	76(fp),g4
	addo	1,g4,g5
	st	g5,76(fp)
	b	L25
L26:
	ld	72(fp),g4
	mov	g4,g0
	ret
	ret
	.align 4
	.globl __write
	#  Function '_write'
	#  Registers used: g0 g1 g2 g4 g5 fp sp 
	#		   r3* cc 
__write:
	addo	16,sp,sp
	#Prologue stats:
	#  Total Frame Size: 16 bytes
	#  Local Variable Size: 16 bytes
	#End Prologue#
	st	g0,64(fp)
	st	g1,68(fp)
	st	g2,72(fp)
	mov	0,g4
	st	g4,76(fp)
L30:
	ld	76(fp),g4
	ld	72(fp),g5
	cmpi	g4,g5
	bl L33
	b	L31
L33:
	ld	64(fp),g4
	cmpi	g4,2
	bg L34
	ld	68(fp),g4
	ld	76(fp),g5
	addo	g4,g5,g4
	ldob	(g4),g5
	cmpi	g5,10
	bne L34
	mov	13,g0
	callx	_serial_putc
L34:
	ld	68(fp),g4
	ld	76(fp),g5
	addo	g4,g5,g4
	ldob	(g4),g0
	callx	_serial_putc
L32:
	ld	76(fp),g4
	addo	1,g4,g5
	st	g5,76(fp)
	b	L30
L31:
	ld	72(fp),g4
	mov	g4,g0
	ret
	ret
	.align 4
	.globl __exit
	#  Function '_exit'
	#  Registers used: g0 fp 
__exit:
	addo	16,sp,sp
	#Prologue stats:
	#  Total Frame Size: 16 bytes
	#  Local Variable Size: 16 bytes
	#End Prologue#
	st	g0,64(fp)
L35:
	b	L37
	b	L36
L37:
	b	L35
L36:
	ret
	ret
	.align 4
	.globl _getpid
	#  Function 'getpid'
	#  Registers used: g0 fp 
_getpid:
	subo	1,0,g0	# ldconst -1,g0
	ret
	ret
	.align 4
	.globl _isatty
	#  Function 'isatty'
	#  Registers used: g0 fp 
_isatty:
	addo	16,sp,sp
	#Prologue stats:
	#  Total Frame Size: 16 bytes
	#  Local Variable Size: 16 bytes
	#End Prologue#
	st	g0,64(fp)
	subo	1,0,g0	# ldconst -1,g0
	ret
	ret
	.align 4
	.globl _kill
	#  Function 'kill'
	#  Registers used: g0 g1 fp 
_kill:
	addo	16,sp,sp
	#Prologue stats:
	#  Total Frame Size: 16 bytes
	#  Local Variable Size: 16 bytes
	#End Prologue#
	st	g0,64(fp)
	st	g1,68(fp)
	ret
	ret
.globl _a
.comm _a,4
