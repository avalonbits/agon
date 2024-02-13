#include <mos_api.h>
#include <stdio.h>

#include "snes_controller.h"

int main(void) {
    mos_i2c_open(I2C_SPEED_115200);
    mos_i2c_close();

    return 0;
}
