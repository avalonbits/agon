helloworld.hex: helloworld.asm ../common/init.asm
	spasm -E helloworld.asm helloworld.hex

helloworld.bin: helloworld.asm ../common/init.asm
	spasm -E -T helloworld.asm

clean:
	rm -frv *.bin
