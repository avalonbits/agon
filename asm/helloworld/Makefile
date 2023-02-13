all: helloworld.hex helloworld.bin

helloworld.hex: helloworld.asm ../include/*
	spasm -E helloworld.asm helloworld.hex

helloworld.bin: helloworld.asm ../include/*
	spasm -E -T helloworld.asm

clean:
	rm -frv *.bin *.hex *.lst
