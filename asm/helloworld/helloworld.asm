	.ASSUME ADL = 1

	#include "../common/init.asm"

; The main routine
;
main:
	LD		HL, hello_world
	CALL	prstr
	LD		HL, 0
	RET.L

; Print a zero-terminated string
;
prstr:
	LD		A,(HL)
	OR		A
	RET		Z
	RST.LIL 10h
	INC		HL
	JR		prstr

; Sample text
;
hello_world: .db "Hello World\n\r",0
