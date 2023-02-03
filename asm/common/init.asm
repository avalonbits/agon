	.ASSUME ADL = 1 ; Start in ADL mode


	JP	_START

	;
	; The header stuff is from byte 64 onwards
	;
	.BLOCK	60
	.db		"MOS"	; Flag for MOS - to confirm this is a valid MOS command
	.db		00h		; MOS header version 0
	.db		01h		; Flag for run mode (0: Z80, 1: ADL)

;
; And the code follows on immediately after the header
;
_START:
	EI			; Enable the MOS interrupts
	JP	main	; Start user code
