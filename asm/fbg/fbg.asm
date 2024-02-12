    .ASSUME ADL = 1
    .ORG $B0000

    JP _start

    .DB "FBG.BIN"
    .ALIGN 64
    .DB "MOS", 0, 1

;--------------------------------------
; MACROS                              |
;--------------------------------------

; Clear screen
    MACRO m_CLS
        LD A,12
        RST.LIL 10h
    ENDMACRO

; Print line
    MACRO m_PRINT_LINE line, ydiff 
        LD A, (ypos)
        ADD A, ydiff
        LD B, A
        LD A, (xpos)
        CALL vdp_tab

        LD HL, line
        XOR A
        RST.LIL 18h
    ENDMACRO

;--------------------------------------
; MAIN PROGRAM                        ;
;--------------------------------------

_start:
        ; Turn the cursor off
        LD HL, cursor_off
        LD BC, 3
        RST.LIL 18h

        ; Get sysvars.
        LD A, 08
        RST.LIL 08h

        ; Store X position for text.
        LD A, (IX+13h)  ; #cols on screen
        SUB A, 40       ; Subtract the size of the message
        SRL A           ; Halve it to center horizontlly.
        LD (xpos), A

        ; Store the Y position for text.
        LD A, (IX+14h)  ; #rows on screen
        SRL A
        DEC A
        DEC A
        LD (ypos), A

        ; Store the color mask
        LD A, (IX+15h)
        DEC A
        LD (color_mask), A

        CALL detect_fg_bg
                
loop:
        ; Clear screen.
        m_CLS

        call center_instructions
        call choose_colors

        OR A
        JP Z, loop

exit:
        m_CLS
        ; Turn the cursor back on
        LD HL, cursor_on
        LD BC, 3
        RST.LIL 18h

        ; Exit with success.
        LD HL, 0
        RET

;--------------------------------------
; Functions                           |
;--------------------------------------
_vdp_tab:   .DB 31,0,0
vdp_tab:
        ; Setup vdp_tab call.
        LD IX, _vdp_tab
        LD (IX+1), A

        LD A, B
        LD (IX+2), A

        LD HL, _vdp_tab
        LD BC, 3
        RST.LIL 18h

        RET

center_instructions:
        m_PRINT_LINE banner, 0
        m_PRINT_LINE msg, 1
        m_PRINT_LINE empty, 2
        m_PRINT_LINE control, 3
        m_PRINT_LINE banner, 4
        RET

choose_colors:
        ; Get sysvars
        LD A, 08h
        RST.LIL 08h

        ; Wait for a key press.
        XOR A
        RST.LIL 08h
        LD A, (IX+17h)  ; Get pressed key code.

        ; Check for esc.
        CP key_esc
        JP Z, @cancel

        ; Check for enter.
        CP key_enter
        JP Z, @quit
        JP @change_color

@cancel:
        ; Restore foreground color.
        LD A, (ofg)
        CALL set_color

        ; Restore background color.
        LD A, (obg)
        OR A, 80h

        CALL set_color

@quit:
        ; User wants to quit the program.
        LD A, 0xFF
        RET

@change_color:
        ; Next FG color?
        CP key_up
        CALL Z, next_fg

        ; Prev FG color?
        CP key_down
        CALL Z, prev_fg

        ; Next BG color?
        CP key_right
        CALL Z, next_bg
        
        ; Prev BG color?
        CP key_left
        CALL Z, prev_bg

        ; Nothing to do, get the next input.
        XOR A
        RET

next_fg:
        LD HL, fg
        CALL next_color
        CALL set_color
        RET
prev_fg:
        LD HL, fg
        CALL prev_color
        CALL set_color
        RET

next_bg:
        LD HL, bg
        CALL next_color

        OR A, 80h
        CALL set_color        
        RET

prev_bg:
        LD HL, bg
        CALL prev_color

        OR A, 80h
        CALL set_color
        RET

next_color:
        LD A, (HL)
        INC A
        CALL apply_color_mask
        LD (HL), A
        RET
        
prev_color:
        LD A, (HL)
        OR A
        JR NZ, @dec_color

        ; Use the color mask to get the last valid color.
        LD A, (color_mask)
        INC A

@dec_color:
        DEC A
        call apply_color_mask
        LD (HL), A
        RET
    
apply_color_mask:
        LD B, A
        LD A, (color_mask)
        AND A, B
        RET

_set_color: .DB 17,0
set_color:
        LD IX, _set_color
        LD (IX+1), A
        LD HL, _set_color
        LD BC, 2
        RST.LIL 18h
        RET

detect_fg_bg:
        ; FG color
        LD A, '*'
        CALL get_ch_center_color
        LD (fg), A
        LD (ofg), A

        ; BG color
        LD A, ' '
        CALL get_ch_center_color
        LD (bg), A
        LD (obg), A

        ; We are done.
        RET

_get_ch_center_color: .DB 23,0,C0h,0,23,0,84h,4,0,4,0
get_ch_center_color:
        ; Send cursor to top left corner
        PUSH AF
        LD A, 30
        RST.LIL 10h

        ; Get sysvars
        LD A, 08h
        RST.LIL 08h

        ; Clear the vdp_pflags byte
        LD (IX+04h), 0

        ; Print the char and get the color
        POP AF
        RST.LIL 10h
        LD HL, _get_ch_center_color
        LD BC, 11
        RST.LIL 18h

@loop:
        ; Get sysvars
        LD A, 08h
        RST.LIL 08h

        ; Get vdp_pflags byte and check if bit 4 is set
        LD A, (IX+04h)
        AND A, 04h
        ; In case it's not set, loop
        JP Z, @loop

        ; Now get the color set and return it on A
        LD A, (IX+16h)
        RET
        
htoa:

; -------------------------------------
; DATA                                |
; -------------------------------------

banner:     .ASCIZ "****************************************\r\n"
msg:        .ASCIZ "*       UP/DOWN=FG LEFT/RIGHT=BG       *\r\n"
empty:      .ASCIZ "*                                      *\r\n"
control:    .ASCIZ "* ENTER=Confirm ESC=Cancel and restore *\r\n" 
ypos:       .DS 1
xpos:       .DS 1
fg:         .DS 1,0
bg:         .DS 1,0
ofg:        .DS 1,0
obg:        .DS 1,0
color_mask: .DS 1
cursor_off: .DB 23,1,0
cursor_on:  .DB 23,1,1

key_enter:  .EQU 8Fh
key_esc:    .EQU 7Dh
key_up:     .EQU 96h
key_down:   .EQU 98h
key_left:   .EQU 9Ah
key_right:  .EQU 9Ch

hex2ch:     .DB "012345678ABCDE"