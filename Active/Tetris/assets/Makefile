EMULICIOUS = /Users/mattsun/GameBoy/Emulicious/Emulicious.jar
RGBASMFLAGS = -l -Weverything
RGBLINKFLAGS =
RGBFIXFLAGS = -v -C -p 0xFF

CURRENT_DIR = $(shell pwd)

MAIN = tetris

default: ../build/$(MAIN).gb

kill:
	pkill java

start: ../build/$(MAIN).gb
	code ..
	java -jar $(EMULICIOUS) ../build/$(MAIN).gb &

cleanCode:
	find .. -name "*.o" -type f -delete
	find .. -name "*.gb" -type f -delete

cleanGraphics:
	find .. -name "*.2bpp" -type f -delete
	find .. -name "*.pal" -type f -delete

clean:
	make cleanCode
	make cleanGraphics

forceCode:
	make cleanCode
	make -j

forceGraphics:
	make cleanGraphics
	make -j


force:
	make regen
	make cleanGraphics
	make cleanCode
	make -j

fast:
	make -j

regen:
	java -cp ../tools/make RegenMakeFile $(CURRENT_DIR)



#AUTO-GENERATED

../build/$(MAIN).gb: ../tmp/mem.o ../tmp/utils.o ../tmp/input.o ../tmp/dma.o ../tmp/rng.o ../tmp/math.o ../tmp/graphics.o ../tmp/tetrominos.o ../tmp/tetris.o ../tmp/vars.o 
	rgblink -n ../build/$(MAIN).sym -m ../log/$(MAIN).map -o ../build/$(MAIN).gb \
		../tmp/mem.o \
		../tmp/utils.o \
		../tmp/input.o \
		../tmp/dma.o \
		../tmp/rng.o \
		../tmp/math.o \
		../tmp/graphics.o \
		../tmp/tetrominos.o \
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

../tmp/rng.o: lib/rng.asm inc/hardware.inc
	rgbasm $(RGBASMFLAGS) -o ../tmp/rng.o lib/rng.asm

../tmp/math.o: lib/math.asm
	rgbasm $(RGBASMFLAGS) -o ../tmp/math.o lib/math.asm

../tmp/graphics.o: src/graphics.asm graphics/bin/BG-2.2bpp graphics/bin/BG-3.2bpp graphics/bin/BG-1.2bpp graphics/bin/Tetris.2bpp graphics/bin/BG-2.pal graphics/bin/BG-3.pal graphics/bin/BG-1.pal graphics/bin/Tetris-p2.pal graphics/bin/Tetris-p3.pal graphics/bin/Tetris-p1.pal graphics/bin/Tetris-p4.pal graphics/bin/Tetris-p5.pal graphics/bin/Tetris-p6.pal
	rgbasm $(RGBASMFLAGS) -o ../tmp/graphics.o src/graphics.asm

../tmp/tetrominos.o: src/tetrominos.asm
	rgbasm $(RGBASMFLAGS) -o ../tmp/tetrominos.o src/tetrominos.asm

../tmp/tetris.o: src/tetris.asm inc/tetris.inc inc/dma.inc inc/hardware.inc
	rgbasm $(RGBASMFLAGS) -o ../tmp/tetris.o src/tetris.asm

../tmp/vars.o: src/vars.asm inc/tetris.inc
	rgbasm $(RGBASMFLAGS) -o ../tmp/vars.o src/vars.asm


graphics/bin/BG-2.2bpp graphics/bin/BG-2.pal: graphics/raw/BG-2.png
	java -cp ../tools/graphics PngToBin graphics/raw/BG-2.png graphics/bin/BG-2.2bpp graphics/bin/BG-2.pal

graphics/bin/BG-3.2bpp graphics/bin/BG-3.pal: graphics/raw/BG-3.png
	java -cp ../tools/graphics PngToBin graphics/raw/BG-3.png graphics/bin/BG-3.2bpp graphics/bin/BG-3.pal

graphics/bin/BG-1.2bpp graphics/bin/BG-1.pal: graphics/raw/BG-1.png
	java -cp ../tools/graphics PngToBin graphics/raw/BG-1.png graphics/bin/BG-1.2bpp graphics/bin/BG-1.pal

graphics/bin/Tetris.2bpp graphics/bin/Tetris.pal: graphics/raw/Tetris.png
	java -cp ../tools/graphics PngToBin graphics/raw/Tetris.png graphics/bin/Tetris.2bpp graphics/bin/Tetris.pal

graphics/bin/Tetris-p2.2bpp graphics/bin/Tetris-p2.pal: graphics/raw/Tetris-p2.png
	java -cp ../tools/graphics PngToBin graphics/raw/Tetris-p2.png graphics/bin/Tetris-p2.2bpp graphics/bin/Tetris-p2.pal

graphics/bin/Tetris-p3.2bpp graphics/bin/Tetris-p3.pal: graphics/raw/Tetris-p3.png
	java -cp ../tools/graphics PngToBin graphics/raw/Tetris-p3.png graphics/bin/Tetris-p3.2bpp graphics/bin/Tetris-p3.pal

graphics/bin/Tetris-p1.2bpp graphics/bin/Tetris-p1.pal: graphics/raw/Tetris-p1.png
	java -cp ../tools/graphics PngToBin graphics/raw/Tetris-p1.png graphics/bin/Tetris-p1.2bpp graphics/bin/Tetris-p1.pal

graphics/bin/Tetris-p4.2bpp graphics/bin/Tetris-p4.pal: graphics/raw/Tetris-p4.png
	java -cp ../tools/graphics PngToBin graphics/raw/Tetris-p4.png graphics/bin/Tetris-p4.2bpp graphics/bin/Tetris-p4.pal

graphics/bin/Tetris-p5.2bpp graphics/bin/Tetris-p5.pal: graphics/raw/Tetris-p5.png
	java -cp ../tools/graphics PngToBin graphics/raw/Tetris-p5.png graphics/bin/Tetris-p5.2bpp graphics/bin/Tetris-p5.pal

graphics/bin/Tetris-p6.2bpp graphics/bin/Tetris-p6.pal: graphics/raw/Tetris-p6.png
	java -cp ../tools/graphics PngToBin graphics/raw/Tetris-p6.png graphics/bin/Tetris-p6.2bpp graphics/bin/Tetris-p6.pal

