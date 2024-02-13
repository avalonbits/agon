#ifndef _SNES_CONTROLLER_
#define _SNES_CONTROLLER_

#include <stdint.h>

#define BTN_RIGHT  0x0001,
#define BTN_LEFT   0x0002,
#define BTN_DOWN   0x0004,
#define BTN_UP     0x0008,
#define BTN_START  0x0010,
#define BTN_SELECT 0x0020,
#define BTN_Y      0x0040,
#define BTN_B      0x0080,
#define BTN_R_TRIG 0x0100,
#define BTN_L_TRIG 0x0200,
#define BTN_X      0x0400,
#define BTN_A      0x0800,
#define SNES_BTN_PRESSED(map, btns) (map & btns)

typedef uint16_t SNES_BTN_MAP;

SNES_BTN_MAP snes_button_map();

#endif // _SNES_CONTROLLER_
