    .ASSUME ADL = 1
    .ORG $B0000

    JP _start

    .DB "RTC2.BIN"
    .ALIGN 64
    .db "MOS", 0, 1

    MACRO m_write_rtc V
        LD      C,      rtc_addr
        LD      B,      1
        LD      A,      21h
        LD      HL,     write_buf
        LD      (HL),   V
        RST.LIL 08h
    ENDMACRO

    MACRO   m_read_rtc
        LD      C,  rtc_addr
        LD      B,  1
        LD      A,  22h
        LD      HL, read_buf
        RST.LIL 08h
    ENDMACRO

_start: 
        ; Open the i2c connection
        LD      A, 1Fh
        RST.LIL 08h

read_time:
        ; Request hour
        m_write_rtc 2
        m_read_rtc
        LD      HL, read_buf
        LD      A,  (HL)
        CALL    hex2ch

        LD      A,  ':'
        RST.LIL 10h

        ; Request minute
        m_write_rtc 1
        m_read_rtc
        LD      HL, read_buf
        LD      A,  (HL)
        CALL    hex2ch

        LD      A,  ':'
        RST.LIL 10h

        ; Request second
        m_write_rtc 0
        m_read_rtc
        LD      HL, read_buf
        LD      A,  (HL)
        CALL    hex2ch

        ; Go to next line
        LD      A,  '\r'
        RST.LIL 10h
        LD      A,  '\n'
        RST.LIL 10h

        ; Get key.
        LD      A,  00h
        RST.LIL 08h

        ; If esc, exit. Otherwise, loop.
        CP      27
        JP      NZ, read_time

done:
        ; Close the i2c connection
        LD      A, 20h
        RST.LIL 08h

        LD      HL, 0           ; Set application return code to 0.
        RET                     ; Done.


; hex2ch: Prints a byte as a hex char.
; Params:
;   A:  The byte to be printed.
    MACRO   m_PrintHexCh
        AND     A,  0Fh
        LD      HL, hex_map
        LD      DE, 0
        LD      E,  A
        ADD     HL, DE
        LD      A,  (hl)
        RST.LIL 10h
    ENDMACRO
hex2ch:
        PUSH    AF
        RRCA
        RRCA
        RRCA
        RRCA
        m_PrintHexCh

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