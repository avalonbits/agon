    ; Using ADL mode and starting at the moslet address.
    .ASSUME ADL = 1
    .ORG $B0000

    ; Jump to main function
    JP _start

    ; Optionaly name your binary
    .DB "SNES.BIN"

    ; Write the program header starting at byte 64.
    .ALIGN 64
    .db "MOS", 0, 1

    ; We are using the SNES over the wii i2c controller port. In this
    ; case it gets recognized as a wii pro controller on i2c address 0x52.
    ;
    ; In order to read the button data, we write 0x02 to 0x52 address and it
    ; will return 9 bytes with the button status.
    MACRO   m_write_wiipro
        LD      C,      52h         ; Wii controller address.
        LD      B,      1           ; We want to write 1 byte.
        LD      A,      21h         ; The i2c_write function id.
        LD      HL,     get_buttons ; Sends 2 to the controller.
        RST.LIL 08h
    ENDMACRO

    ; Reads the 9 buttons for the controller status.
    MACRO   m_read_wiipro
        LD      C,  52h             ; Wii controller address
        LD      B,  9               ; We want to read 9 bytes
        LD      A,  22h             ; The i2c_write function id.
        LD      HL, read_buf        ; Ptr to  buffer for the button status.
        RST.LIL 08h
    ENDMACRO

    MACRO   m_CLS
        LD      A,  12
        RST.LIL 10h
    ENDMACRO

_start:
        ; Turn cursor off
        LD      Hl, cursor_off
        LD      BC, 3
        RST.LIL 18h

        ; Detect fg and bg colors.
        CALL    detect_fg_bg

        ; Open the i2c connection
        LD      A,  1Fh
        RST.LIL 08h

        ; Clear the screen
        m_CLS

        CALL show_controller

@loop:
        ; Read the buttons status from the wii pro controller.
        m_write_wiipro
        m_read_wiipro

        CALL    check_buttons

        ; If we presse SELECT+START together, exit the program.
        LD      IX, read_buf
        LD      A,  (IX+7)
        AND     A,  30h
        CP      30h
        JP      NZ,  @loop

        ; Close the i2c connection.
        LD      A, 20h
        RST.LIL 08h

        ; Restore colors
        LD      A,  (fg)
        CALL    set_color
        LD      A,  (bg)
        CALL    set_color

        ; Turn the cursor on
        m_CLS
        LD      HL, cursor_on
        LD      BC, 3
        RST.LIL 18h

        ; Exit program.
        LD      HL, 0
        RET

detect_fg_bg:
        ; FG color
        LD      A,      '*'
        CALL    get_ch_center_color
        LD      (fg),       A
        OR      A,          80h
        LD      (flip_bg),  A

        ; BG color
        LD      A,   ' '
        CALL    get_ch_center_color
        LD      (flip_fg),  A
        OR      A,          80h
        LD      (bg),       A

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
        LD      A,  08h
        RST.LIL 08h

        ; Get vdp_pflags byte and check if bit 2 was set
        LD      A,  (IX+04h)
        AND     A,  04h
        ; In case it' s not set, loop
        JP      Z,  @loop

        ; Now get the color set and return it on A
        LD      A,  (IX+16h)
        RET


show_controller:
        ; Load controller ptr and initialize counter.
        LD      HL, controller
        LD      A,  0
@loop:
        PUSH    AF
        PUSH    HL

        ; All lines have exactly 42 bytes
        LD      A,  0
        LD      BC, 42
        RST.LIL 18h

        POP     HL
        POP     AF

        ; Go to the next line
        LD      DE, 42
        ADD     HL, DE
        INC     A

        ; If we printed 8 lines, we are done.
        CP      8
        JP      NZ, @loop

        RET

_vdp_tab:   .db 31,0,0
vdp_tab:
        LD      IX,     _vdp_tab
        LD      (IX+2), A
        LD      A,      B
        LD      (IX+1), A
        LD      A,      0
        LD      BC,     3
        LD      HL,     _vdp_tab
        RST.LIL 18h
        RET

check_buttons:
        ; First checkout byte 7 from controller.
        LD      IX, read_buf
        LD      A,  (IX+7)
        LD      B,  8

        LD      HL, buttons
        CALL    read_btn_map

        ; For the second byte, we only need the top nibble.
        LD      IX, read_buf
        LD      A,  (IX+8)
        SRL     A
        SRL     A
        SRL     A
        SRL     A
        LD      B,  4

        CALL    read_btn_map
        RET

read_btn_map:
        PUSH    AF
        PUSH    BC

@loop:
        ; If the button is pressed, we print the controller button with
        ; with reversed colors.
        BIT     0, A
        PUSH    HL
        JP      NZ, @rev_col

        ; Otherwise, same color scheme.
        LD      A,  (fg)
        CALL    set_color
        LD      A,  (bg)
        CALL    set_color
        JP      @print_button

@rev_col:
        LD      A,  (flip_fg)
        CALL    set_color
        LD      A,  (flip_bg)
        CALL    set_color

@print_button:
        ; Move to the button position.
        POP     HL
        LD      A,  (HL)
        INC     HL
        LD      B,  (HL)

        PUSH    HL
        CALL    vdp_tab
        POP     HL

        ; Now print the button
        INC     HL
        LD      A,  0
        LD      BC, 0

        PUSH    HL
        RST.LIL 18h
        POP     HL

        ; Go to next record
        LD      BC, 7
        ADD     HL, BC

        ; Check if there are more buttons to check status
        POP     BC
        DEC     B
        JP      Z,  @done

        ;If we are not done, shift A and continue
        POP     AF
        SRL     A
        PUSH    AF
        PUSH    BC
        JP      @loop

@done:
        POP     AF
        RET

_set_color:     .db 17,0
set_color:
        LD      IX,     _set_color
        LD      (IX+1), A
        LD      BC,     2
        LD      HL,     _set_color
        RST.LIL 18h
        RET

; -------------------------------------
; DATA                                |
; -------------------------------------

controller:
        .db  "       L                         R      \r\n"
        .db  ",--------------------------------------,\r\n"
        .db  "|      U                         X     |\r\n"
        .db  "|      |                               |\r\n"
        .db  "| L --- --- R  SELECT START  Y       A |\r\n"
        .db  "|      |                               |\r\n"
        .db  "|      D                         B     |\r\n"
        .db  "'--------------------------------------'\r\n"

; button struct: chY, chX, 7 bytes for null terminated string
; The records are in the order we get the data from the controller.
buttons:
        .db 04,12,'R',00,00,00,00,00,00
        .db 04,02,'L',00,00,00,00,00,00
        .db 06,07,'D',00,00,00,00,00,00
        .db 02,07,'U',00,00,00,00,00,00
        .db 04,22,"START",00,00
        .db 04,15,"SELECT",00
        .db 04,29,'Y',00,00,00,00,00,00
        .db 06,33,'B',00,00,00,00,00,00
        .db 00,33,'R',00,00,00,00,00,00
        .db 00,07,'L',00,00,00,00,00,00
        .db 02,33,'X',00,00,00,00,00,00
        .db 04,37,'A',00,00,00,00,00,00

fg:             .DB 0
bg:             .DB 0
flip_fg:        .DB 0
flip_bg:        .DB 0
get_buttons:    .DB 2
read_buf:       .DS 10, 0

cursor_off:     .DB 23,1,0
cursor_on:      .DB 23,1,1
