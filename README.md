# Homebrew Gameboy Color ASM

Documenting my exploration of making games for the Gameboy Color in assembly.

This repository contains all of my projects that I have experimented with and have made. Within each project are graphics that I made as well as the tooling that I wrote to mainly do image processing as well as other post processing. Each project also contains a set of common programs that should be used like customizable modules.

## Why?

After doing "High Level" game development for 1 year with `Java` and 4 with `Unity C#`, I decided that I wanted to take a break from it. I wanted to dip my toes in something more low level as I learned that it was something that it was something I enjoyed whenever I needed to do it previously. 

The plan was to build a 3D game-engine in `C++`, but I realized that I did not know enough about the language as well as the math needed to do so. This pushed me to find some other outlet and I eventually was reminded the NES. But I had tried to do this in the past and found myself being servery limited creativity due to the RAM and ROM limitations. 

I ended up being again reminded of playing Pokemon Gold on the Gameboy Color. Something about it being a hand held console as well as the nostalgia brought me to it. After researching it and reading every page of the [Pandocs](https://gbdev.io/pandocs/) I was fully sure I wanted to create a game for it. It had just the right amount of hardware limitations that I would enjoy working around it creatively.

I've also decided that I want to utilize this as a extra challenge to learn about the fundamentals of game design (*through reading a textbook & practice*). Making a game fun is what I struggle with the most. The limitations of the Gameboy make it so you can't just brute force a "fun" game into existence. Instead, you have to go back to the basics and just make a game that is just simply fun, like the pioneers back in the day. More on this in my [notes](ArtOfGameDesign/notes.md) for the textbook [Art of game design](ArtOfGameDesign/art-of-game-design.pdf).

## Goals

/*

It's probably a bad trait to have as a game developer but I always focus much more on the visual appeal and creativity of my games first. *This often comes with the issue that the games are not fun.* Still, I try to maintain this way of development and I will continue that when developing for the Gameboy.

My first priority is making a **visually stunning** game, this was something that I never saw in any of the other old Gameboy cartridges. Whether it be using an MBC just to store extra graphics to store every permutation to get around the OAM limits or making the game run at 8 fps on double speed mode to make my own graphics engine.

This may make the games much less of a game and instead an *experience* though, hopefully, it does not come to this and the game would be both **visually stunning** and **fun**

*/

EDIT: I will try to do the opposite of this actually, I will prioritize making the games fun as it is something that I still don't know how to do. There is no point in solely focusing on the one thing that I'm already good at. After all, you're only as strong as your weakest link.
# Building

To build the projects you need to have:
- [RGBDS](https://rgbds.gbdev.io/install/) to build the project
- [GNU Make](https://www.gnu.org/software/make/) for build automation
- [Emulicious](https://emulicious.net/downloads/) to emulate the gameboy color
- [Java JDK](https://www.oracle.com/java/technologies/downloads/) for tooling scripts

To build an project, the project is preferable isolated in the `/Active/` directory. This is to make sure Emulicious's scope is the one project. To do this shuffle projects between `/Active/` and `/Archive/`.

To build a project with the standard structure, navigate to `Active/ProjectName/assets/`, then run these commands

`make regen` 

*to build generate the make file (run this command whenever a new file is added)*

`make` 

*to build the project*

**Other Commands**

`make start` 

*to open VSCode as well as Emulicious with the app, configure the path of Emulicous at the start of the Makefile*

`make clean` 

*remove all temporary files*

`make force` 

*recompile everything*

`make fast` 

*run make in parallel*

The other commands can be interpreted from the Makefile

# Projects
| Name                           | Description                                                           | Screenshot                                                                                                                                |
|----------------------|-----------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
|Tetris       | Tetris clone to learn the development from start to end & building the basics of the *engine*                                        |![Unbricked](https://github.com/sun3matthew/GameBoyDevelopment/blob/main/Images/Tetris.png?raw=true)
|Unbricked       | Leaning about graphics                                        |![Unbricked](https://github.com/sun3matthew/GameBoyDevelopment/blob/main/Images/Unbricked.png?raw=true)              |
|HelloWorld       | Leaning the basics                                         |![HelloWorld](https://github.com/sun3matthew/GameBoyDevelopment/blob/main/Images/HelloWorld.png?raw=true)              |

# Helpful Resources

- [Pandocs](https://gbdev.io/pandocs/) - Everything you need to know about the gameboy.
- [hardware.inc](https://github.com/gbdev/hardware.inc) - The repository for the hardware.inc file.
- [GBC ASM Tutorial](https://gbdev.io/gb-asm-tutorial/index) - WIP at the time of writing, but good to learn the basics.
- [tbsp’s “Simple GB ASM examples](https://github.com/tbsp/simple-gb-asm-examples) - Very useful to learn from it's example projects.
- [CPU opcodes](https://rgbds.gbdev.io/docs/v0.6.1/gbz80.7/) - When you can't memorize the cycle counts.
- [gbdev tutorials](https://gbdev.gg8.se/wiki/articles/Tutorials) - Other misc tutorials.


# License
The code & assets in this repository is licensed under the [CC0](https://creativecommons.org/publicdomain/zero/1.0/) license.
