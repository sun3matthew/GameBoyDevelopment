RGBASMFLAGS = -L
RGBLINKFLAGS = 
RGBFIXFLAGS = -v -p 0xFF

default: unbricked.gb

kill:
	pkill java

start: unbricked.gb
	java -jar /Users/mattsun/GameBoy/Emulicious/Emulicious.jar unbricked.gb &

unbricked.gb: main.o
	rgblink -n main.sym main.o
	rgblink $(RGBLINKFLAGS) -o unbricked.gb main.o
	rgbfix $(RGBFIXFLAGS) unbricked.gb

main.o: main.asm hardware.inc
	rgbasm $(RGBASMFLAGS) -o main.o main.asm

clean:
	rm -f *.o *.gb *sym
