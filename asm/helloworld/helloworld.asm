	; Using ADL mode and starting at the moslet address.
	.ASSUME ADL = 1
	.ORG	$B0000

	; Jump to main function
	JP	_start

	; Optionaly name your binary
	.DB		"HELLOWORLD.BIN"

	; Write the program header starting at byte 64.
	.ALIGN	64
	.DB		"MOS", 0, 1

; The main routine
;
_start:		LD      HL, hello_world     ; Load string adddres to HL register
			LD		A, 0				; Indicate it  is null terminated.
			RST.LIL 18h					; Call MOS print string function.

			LD      HL, 0               ; Set application return code to 0
            RET                         ; Done.

hello_world:    .asciz "Hello, World!\r\n"
