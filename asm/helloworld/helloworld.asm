            .ASSUME ADL = 1

            #include "../common/init.asm"

; The main routine
;
main:       LD      HL, hello_world     ; Load string adddres to HL register
            CALL    prstr               ; Call print string funcition
            LD      HL, 0               ; Set application return code to 0
            RET                         ; Done.

; Print a zero-terminated strin
; Arguments:
;   - HL: pointer to start of zero-terminated string.
;
prstr:      LD      A,(HL)              ; Load curreent character from string
            OR      A                   ; Check if it is zero
            RET     Z                   ; If zero, we are done.

            RST.LIL 10h                 ; Send the charcter to VDP
            INC     HL                  ; Get the next charcter
            JR      prstr               ; Loop back.

; Sample text
;
hello_world:    .db "Hello World\n\r",0
