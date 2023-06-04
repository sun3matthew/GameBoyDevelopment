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
	find .. -name "*.2bpp" -type f -delete
	find .. -name "*.pal" -type f -delete

force:
	make regen
	make clean
	make

regen:
	java ../tools/make/RegenMakeFile.java



graphics/bin/tile.2bpp graphics/bin/tile.pal: graphics/raw/tile.png
	java ../tools/graphics/PngToBin.java graphics/raw/tile.png graphics/bin/tile.2bpp graphics/bin/tile.pal

#AUTO-GENERATED

../build/$(MAIN).gb: inc/hardware.inc ../tmp/utils.o ../tmp/graphics.o ../tmp/tetris.o graphics/bin/tile.2bpp graphics/bin/tile.pal
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

