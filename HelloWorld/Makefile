#rgbasm -L -o hello-world.o hello-world.asm
#rgblink -o hello-world.gb hello-world.o
#rgbfix -v -p 0xFF hello-world.gb

RGBASMFLAGS = -L
RGBLINKFLAGS = 
RGBFIXFLAGS = -v -p 0xFF

default: hello-world.gb

kill:
	pkill java

run: hello-world.gb
	java -jar /Users/mattsun/GameBoy/Emulicious/Emulicious.jar hello-world.gb &

hello-world.gb: hello-world.o
	rgblink $(RGBLINKFLAGS) -o hello-world.gb hello-world.o
	rgbfix $(RGBFIXFLAGS) hello-world.gb

hello-world.o: hello-world.asm hardware.inc
	rgbasm $(RGBASMFLAGS) -o hello-world.o hello-world.asm

clean:
	rm -f *.o *.gb
