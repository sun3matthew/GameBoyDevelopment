EMULICIOUS = /Users/mattsun/GameBoy/Emulicious/Emulicious.jar

RGBASMFLAGS = -L
RGBLINKFLAGS =
RGBFIXFLAGS = -v -p 0xFF

MAIN = tetris

default: ../build/$(MAIN).gb

kill:
	pkill java

start: ../build/$(MAIN).gb
	java -jar $(EMULICIOUS) ../build/$(MAIN).gb &

clean:
	find .. -name "*.o" -type f -delete
	find .. -name "*.gb" -type f -delete

force:
	make regen
	make clean
	make

regen:
	java ../tools/make/RegenMakeFile.java

#AUTO-GENERATED

../build/$(MAIN).gb: ../tmp/utils.o ../tmp/graphics.o ../tmp/tetris.o 
	rgblink -n ../build/$(MAIN).sym -m ../log/$(MAIN).map -o ../build/$(MAIN).gb \
		../tmp/utils.o \
		../tmp/graphics.o \
		../tmp/tetris.o
	rgbfix $(RGBFIXFLAGS) ../build/$(MAIN).gb

../tmp/utils.o: lib/utils.asm
	rgbasm $(RGBASMFLAGS) -o ../tmp/utils.o lib/utils.asm

../tmp/graphics.o: src/graphics.asm
	rgbasm $(RGBASMFLAGS) -o ../tmp/graphics.o src/graphics.asm

../tmp/tetris.o: src/tetris.asm
	rgbasm $(RGBASMFLAGS) -o ../tmp/tetris.o src/tetris.asm

