EMULICIOUS = /Users/mattsun/GameBoy/Emulicious/Emulicious.jar

RGBASMFLAGS = -L
RGBLINKFLAGS =
RGBFIXFLAGS = -v -C -p 0xFF

MAIN = tetris

default: ../build/$(MAIN).gb

kill:
	pkill java

start: ../build/$(MAIN).gb
	java -jar $(EMULICIOUS) ../build/$(MAIN).gb &

clean:
	find .. -name "*.o" -type f -delete
	find .. -name "*.gb" -type f -delete

cleang:
	find .. -name "*.2bpp" -type f -delete
	find .. -name "*.pal" -type f -delete

force:
	make regen
	make clean
	make cleang
	make

soft:
	make clean
	make

regen:
	java ../tools/make/RegenMakeFile.java



#AUTO-GENERATED

../build/$(MAIN).gb: inc/tetris.inc inc/dma.inc inc/hardware.inc graphics/bin/BG-2.2bpp graphics/bin/BG-3.2bpp graphics/bin/BG-1.2bpp graphics/bin/Tetris.2bpp graphics/bin/BG-2.pal graphics/bin/BG-3.pal graphics/bin/BG-1.pal graphics/bin/Tetris.pal ../tmp/mem.o ../tmp/utils.o ../tmp/input.o ../tmp/dma.o ../tmp/math.o ../tmp/graphics.o ../tmp/tetris.o ../tmp/vars.o 
	rgblink -n ../build/$(MAIN).sym -m ../log/$(MAIN).map -o ../build/$(MAIN).gb \
		../tmp/mem.o \
		../tmp/utils.o \
		../tmp/input.o \
		../tmp/dma.o \
		../tmp/math.o \
		../tmp/graphics.o \
		../tmp/tetris.o \
		../tmp/vars.o
	rgbfix $(RGBFIXFLAGS) ../build/$(MAIN).gb

../tmp/mem.o: lib/mem.asm inc/hardware.inc
	rgbasm $(RGBASMFLAGS) -o ../tmp/mem.o lib/mem.asm

../tmp/utils.o: lib/utils.asm inc/hardware.inc
	rgbasm $(RGBASMFLAGS) -o ../tmp/utils.o lib/utils.asm

../tmp/input.o: lib/input.asm inc/hardware.inc
	rgbasm $(RGBASMFLAGS) -o ../tmp/input.o lib/input.asm

../tmp/dma.o: lib/dma.asm inc/dma.inc inc/hardware.inc
	rgbasm $(RGBASMFLAGS) -o ../tmp/dma.o lib/dma.asm

../tmp/math.o: lib/math.asm
	rgbasm $(RGBASMFLAGS) -o ../tmp/math.o lib/math.asm

../tmp/graphics.o: src/graphics.asm
	rgbasm $(RGBASMFLAGS) -o ../tmp/graphics.o src/graphics.asm

../tmp/tetris.o: src/tetris.asm inc/tetris.inc inc/dma.inc inc/hardware.inc
	rgbasm $(RGBASMFLAGS) -o ../tmp/tetris.o src/tetris.asm

../tmp/vars.o: src/vars.asm inc/tetris.inc
	rgbasm $(RGBASMFLAGS) -o ../tmp/vars.o src/vars.asm


graphics/bin/BG-2.2bpp graphics/bin/BG-2.pal: graphics/raw/BG-2.png
	java ../tools/graphics/PngToBin.java graphics/raw/BG-2.png graphics/bin/BG-2.2bpp graphics/bin/BG-2.pal

graphics/bin/BG-3.2bpp graphics/bin/BG-3.pal: graphics/raw/BG-3.png
	java ../tools/graphics/PngToBin.java graphics/raw/BG-3.png graphics/bin/BG-3.2bpp graphics/bin/BG-3.pal

graphics/bin/BG-1.2bpp graphics/bin/BG-1.pal: graphics/raw/BG-1.png
	java ../tools/graphics/PngToBin.java graphics/raw/BG-1.png graphics/bin/BG-1.2bpp graphics/bin/BG-1.pal

graphics/bin/Tetris.2bpp graphics/bin/Tetris.pal: graphics/raw/Tetris.png
	java ../tools/graphics/PngToBin.java graphics/raw/Tetris.png graphics/bin/Tetris.2bpp graphics/bin/Tetris.pal

