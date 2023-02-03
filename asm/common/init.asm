;
; Initialization for an eZ80 assembler program that works on the Agon MOS.
;

            .ORG    040000h     ; All eZ80 programs start at 0x040000
            .ASSUME ADL = 1     ; Start in ADL mode


            JP  _START          ; Jump over the obligatory header.

            ; The required MOS header.
            ;
            .BLOCK  60
            .db     "MOS"   ; Flag for MOS - to confirm this is a valid MOS command
            .db     00h     ; MOS header version 0
            .db     01h     ; Flag for run mode (0: Z80, 1: ADL)

;
; And the code follows on immediately after the header
; The return code for the application must be set on register HL.
;
_START:     PUSH    AF      ; Preserve registers, except HL.
            PUSH    BC
            PUSH    DE
            PUSH    IX
            PUSH    IY

            CALL    main    ; Start user code

            POP     IY      ; Restore registers
            POP     IX
            POP     DE
            POP     BC
            POP     AF

            RET             ; We're done.
