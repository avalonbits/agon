AGON assemmbly programs.
========================

A few programs written in eZ80 assembly for the Agon line of computersi and its [emulator](https://github.com/tomm/fab-agon-emulator). They require MOS 1.04 or
above and VDP 1.04 or above.

All programs here are moslets, meaning they should be copied to the `/mos` directory and can be ran by typing their name
on the command line and pressing ENTER/RETURN.

The purpose of these programs is to be educational, so they are heavily commented and not necessarily the most efficient
versions possible.

To assemble them on your agon computer, you will the need the [ez80asm assembler](https://github.com/envenomator/agon-ez80asm).
Follow the instructions there to install it to your `/mos` directory.

Once installed, you can assemble any of the  prograsm as follows:

```
ez80asm PROG.asm /mos/PROG.bin
```

This will assemble the program and write the binary directly to your `/mos` directory. After that, typing `PROG` on the
commandline will start the program.

To edit these programs, you can use my text editor [AED](https://github.com/avalonbits/aed).
[Nano](https://github.com/lennart-benschop/agon-utilities/tree/main/Nano/Release) and
[vi](https://github.com/tomm/toms-agon-experiments/tree/main/vi/bin) are also available.

