EMULICIOUS = /Users/mattsun/GameBoy/Emulicious/Emulicious.jar

RGBASMFLAGS = -L
RGBLINKFLAGS =
RGBFIXFLAGS = -v -p 0xFF

MAIN = tetris

LIBS = utils.asm
LIBPATHS = $(addprefix lib/, $(LIBS))

SRC = $(MAIN).asm graphics.asm



DEPENDENCIES = $(MAIN).asm hardware.inc $(LIBPATHS) $(SRC)

default: build/$(MAIN).gb

kill:
	pkill java

start: build/$(MAIN).gb
	java -jar $(EMULICIOUS) $(MAIN).gb &

build/$(MAIN).gb: tmp/$(MAIN).o 
	rgblink -n build/$(MAIN).sym tmp/$(MAIN).o
	rgblink -m log/$(MAIN).map tmp/$(MAIN).o
	rgblink $(RGBLINKFLAGS) -o build/$(MAIN).gb tmp/$(MAIN).o
	rgbfix $(RGBFIXFLAGS) build/$(MAIN).gb

$(MAIN).o: $(DEPENDENCIES)
	rgbasm $(RGBASMFLAGS) -o tmp/$(MAIN).o src/$(MAIN).asm

clean:
	rm -rf *.o *.gb *sym

force:
	rm -rf *.o *.gb *sym
	make