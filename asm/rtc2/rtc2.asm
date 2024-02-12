    ; Using ADL mode and starting at the moslet address.
	.ASSUME ADL = 1
    .ORG $B0000

	; Jump to main function
    JP _start

	; Optionaly name your binary
    .DB "RTC2.BIN"

	; Write the program header starting at byte 64.
    .ALIGN 64
    .db "MOS", 0, 1

	; For the RTC2, we write 1 byte to get the hour/minute/second and then
	; read one byte to get the value. A pair of macros helps us with this.

	; Uses the  MOS i2c write api to write a byte to the MOD-RTC2.
    MACRO m_write_rtc V
        LD      C,      68h			; MOD-RTC2 I2C addres
        LD      B,      1			; We want to write 1 byte.
        LD      A,      21h			; The i2c_write function id

		; mos_i2c_write expects a buffer with the value to be sent.
		; So we use  write_buf to write V to it.
        LD      HL,     write_buf
        LD      (HL),   V
        RST.LIL 08h
    ENDMACRO

	; Uses the MOS i2c read api to read a byte from MOD-RTC2
    MACRO   m_read_rtc
        LD      C,  68h				; MOD-RTC2 I2C address
        LD      B,  1				; We want to read 1 byte
        LD      A,  22h				; The i2c_write function id.
        LD      HL, read_buf		; Pointer to the buffer for the read byte.
        RST.LIL 08h
    ENDMACRO

	MACRO m_print_hex
        LD      HL, read_buf
        LD      A,  (HL)
        CALL    hex2ch
	ENDMACRO

_start:
        ; Open the i2c connection
        LD      A, 1Fh
        RST.LIL 08h

read_time:
        ; Request hour
        m_write_rtc 2
        m_read_rtc
		m_print_hex

        LD      A,  ':'
        RST.LIL 10h

        ; Request minute
        m_write_rtc 1
        m_read_rtc
		m_print_hex

        LD      A,  ':'
        RST.LIL 10h

        ; Request second
        m_write_rtc 0
        m_read_rtc
		m_print_hex

        ; Go to next line
        LD      A,  '\r'
        RST.LIL 10h
        LD      A,  '\n'
        RST.LIL 10h

done:
        ; Close the i2c connection
        LD      A, 20h
        RST.LIL 08h

        LD      HL, 0           ; Set application return code to 0.
        RET                     ; Done.

; hex2ch: Prints the first nibble of a byte as a hex char.
; Params:
;   A:  The byte to be printed.
    MACRO   m_PrintHexCh
        AND     A,  0Fh			; Mask out the upper nibble.
        LD      HL, hex_map		; Load the character map

		; Index the character map using the nibble
        LD      DE, 0
        LD      E,  A
        ADD     HL, DE

		; Load the indexed char and write it to the screen
        LD      A,  (HL)
        RST.LIL 10h
    ENDMACRO

hex2ch:
		; We are going to destroy the A register with the masking, so
		; store it in the stack
        PUSH    AF

		; Get the upper nibble and print it.
        RRCA
        RRCA
        RRCA
        RRCA
        m_PrintHexCh

		; Restore the A register so we can print the lower nibble.
        POP     AF
        m_PrintHexCh

        RET

;--------------------------------------
; DATA                                |
;--------------------------------------
freq:           .EQU    02h
rtc_addr:       .EQU    68h
write_buf:      .DB     1,0
read_buf:       .DS     1,0

hex_map:     .DB     "0123456789ABCDEF"
