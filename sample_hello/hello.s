gcc2_compiled.:
___gnu_compiled_c:
.text
	.align 4
LC0:
	.ascii "hello, world\12\0"
	.align 4
	.globl _start
	#  Function 'start'
	#  Registers used: g0 fp sp 
	#		   r3* 
_start:
	ldconst	LC0,g0
	callx	_printf
	mov	0,g0
	ret
	ret
