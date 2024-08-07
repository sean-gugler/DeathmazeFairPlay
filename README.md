# Deathmaze 5000 Fair Play Edition

*A fan mod by Sean Gugler*

You can play online right now:
1. Download `deathmaze.do` from <https://github.com/sean-gugler/DeathmazeFairPlay/releases>
2. Visit <https://www.scullinsteel.com/apple2/> and click the "open folder" icon (tip: F2 toggles full-screen)

When the disk boots, choose option 4 to play the Fair Play edition.

## Hints

Stuck? Try the self-guided, minimal-spoiler [hint](https://sean-gugler.github.io/DeathmazeFairPlay/hints.html) page.

# About the game

[Deathmaze 5000](https://wikipedia.org/wiki/Deathmaze_5000) was released in 1980 by Med Systems Software for the TRS-80 and Apple II platforms. We would describe it today as an "escape room" experience; players are tasked with navigating a maze, manipulating objects, and solving puzzles with the purpose of escape. This was a novel mash-up of play elements at the time. Maze games and text adventures already existed but I am not aware of any earlier example than Deathmaze 5000 that combined the two formats.

The writing was quite clever, but suffered from moon logic, items with no purpose, unfinished puzzles, and some inconsistent behaviors. When I finally solved it after 40 YEARS of trying, I was both satisfied and disappointed. I decided I could make it better. Armed with my recent technical experience disassembling Ultima IV, I wove the loose ends together and improved the structure of the weaker puzzles while retaining as much of Deathmaze's original material as I could. I also patched up a small handful of bugs discovered along the way.

The "Fair Play" edition reflects my sensibilities on what consitutes fair puzzle design. My alterations attempt to be consistent with the original writing tone and style. To the degree I've failed, I ask your humble forgiveness.

# Release Notes
This project builds four editions of the game:

1. Original game, early retail release
2. Original game, later retail release
3. Original game, with more bugs fixed by the Fair Play author
4. Fair Play fan release

All four are included in the provided DOS 3.3 disk image for easy comparison.

The latter two are also included in a ProDOS disk image. These versions remove support for saving to cassette, but can now manage up to 10 simultaneous save files.

## Saved Game file

WARNING: The original game (editions 1 through 3) saves the game directly to track 3, sector 0. This is safe on the provided disk because I've allocated a "RESERVED" file to protect that sector. The same may not be true if you copy the files to another disk, so be careful! The safest (though wasteful) thing to do is use a completely blank disk for saved games.

The DOS 3.3 **Fair Play** edition and all ProDOS editions save the game to a proper file through ordinary catalog allocation. These editions and their save files are safe to transport by ordinary means to any other disk.

The original game required saving to slot 6, drive 1. The Fair Play edition will save to the same disk the game was launched from. On ProDOS, if you move the game files to a subfolder, be sure to edit the STARTUP program to adjust the PREFIX accordingly, or else save files may be stored in the root of the device volume.

## Bugs fixed in later retail
* Breaking an item now clears it from the inventory display.
* Using the "Say" verb by itself no longer prints garbage.

## Other changes in later retail
* Space now printed between "You break the" and item name.
* Save and Load prompts are now all-caps.

## Bugs fixed in fan releases
* Lit torch count is decremented when it goes out.
* The "Look Dog" command now displays an appropriate response.
* Pressing ESC first thing on game start no longer displays garbage.
* After entering a command with an unknown verb or noun, subsequently pressing ESC no longer omits the unknown word when re-displaying the response.
* Double-space is properly prevented. Previously it mistakenly prevented a second space only after first letter of second word was started, as in:  WORD_L_
* Torch count now increments if you "get box" then "get torch" and it's the only box you're carrying. Previously it would be off by one. (For fun, try this in a retail edition and then "drop torch"! Repeat all three commands for endless entertainment walking backwards through the font.)
* Boxed torches in your inventory count towards the carry limit.
* Display would flicker while rotating during monster's approach by torchlight.
* Move forward into wall during monster encounter, "splat" now remains and doesn't flicker.
* Entering a verb/noun action instead of moving during monster's approach would accelerate its arrival.
* Always time to read fate about "the body". Message would briefly flicker if you did an action with a text result, such as "open box".
* Open a door, then immediately open it again. Moving forward would print "splat". It now correctly moves forward.
* If you drop the lit torch, you could temporarily escape the monster by killing a dog.
* If you drop the lit torch while it is dying, the "torch dying" message stops appearing.
* Rare possibility of getting illogical text when defeating the dog.
* Dropping the jar would silently empty it.
* Arriving after a teleport should always face open space. If you arrive facing a wall, your first move can be forward through it.
* Protect the "screen holes" in memory for better compatibility with later models of Apple II.
* Save game routine properly points to the DCT (Device Characteristics Table). Retail builds only work by pure luck, and maybe not on all models of Apple II.
* Where "save" is not allowed, "quit" will not prompt to save either.

## Other changes in fan releases
* Smaller file size, trimmed hundreds of unused bytes and optimized some bloated routines.
* Quitting the game cleanly returns you to the BASIC prompt (`]`) instead of the MONITOR (`*`).
* Up and Down arrow keys work for movement, on keyboards that have them.

## Changes in the Fair Play release
* see SPOILERS.md


# Production notes

## Retail editions

The **later edition** comes from the most authentically preserved release I've encountered, in the [woz-a-day](https://archive.org/details/wozaday_Deathmaze_5000) collection. That collection rarely mentions provenance, but it seems to deal exclusively with original pressings, not copies. While the disks it works from are not always factory-pristine and may be "contaminated" by game saves or high score tables, this one looks clean.

Corrroborating its authenticity, an identical copy of that game file can be found at [Asimov](https://www.apple.asimov.net/images/games/file_based/ankh_crimewave_deathmaze5000_starmaze.dsk) bundled with some other games on a disk captured many years earlier. Incidentally, that disk uses "Beautiful Boot" instead of standard DOS, which prevents the "save game to disk" feature from working. Transplanting the program file to a standard DOS disk allows saving to work normally.

The **earlier edition** of the game has been in my own collection since 1980. It is not an official retail disk, yet for several reasons I feel confident my file came unmodified from one. There is no evidence of any vanity vandalism typically inserted by crackers. The woz disk isn't copy protected, so this one probably wasn't either. There are some minor bugs not present in the woz edition. Forensic analysis of the two files show rippled jump-offset changes which typically result from recompiling source rather than hacking.

See also "Fadden listing" below.

## Observations

The game was originally written for the Z80 instruction set of the TRS-80 and ported to 6502 for the Apple II. This could explain certain anomalies, such as always using indirect addressing with indexing (`lda (ptr),y`) rather than absolute indexing (`lda addr,x`) where possible, or why the `A` register is used as an intermediary for loading values into `X` and `Y` rather than using `ldx` and `ldy`.

The original authors used 1-based indexing ubiquitously, rather than machine-friendly 0-based indexing. In many cases this means setting up data table pointers to the address one entry earlier than where the table actually starts.

The original authors used the assembly code instructions `bpl` and `bmi` after `cmp`, rather than the customary `bcs` and `bcc`. In the general case this is bad practice, but it works in Deathmaze because the numbers being compared are always unsigned 7-bit values (in the range 0 <= A <= 127). (Read more about 6502 comparison logic at <http://www.6502.org/tutorials/compare_beyond.html>)

## Development process

Time spent: 11 weeks
* 2 weeks: disassembly and annotation
* 1 week: organized into buildable project
* 5 weeks: modifications for Fair Play
* 1 week: bug fixes
* 1 week: hint page
* 1 week: adapt for ProDOS

I used [Regenerator 1.7](https://csdb.dk/release/?id=149429) to disassemble and hand-label the binary program.

## Fadden listing

Literally one hour after I first published my work to github I coincidentally discovered Andy McFadden's excellent [disassembly listing](https://6502disassembly.com/a2-deathmaze/Deathmaze5000.html). From there I also discovered his tool SourceGen. I probably could have finished this project a few weeks sooner had I known about those. Oh well.

Andy's copy of the game appears to exactly match the retail "Rev1" I have, except for one curiosity: his edition saves the game to Track 2 Sector F. This moves the saved game out of the file storage area of the disk, which protects it from being overwritten by other files. Since this change is not present in Rev2, which still saves to Track 3 Sector 0 same as Rev1, I'm inclined to think it is a fan hack and not indicative of a unique official release.

# Building from source

<https://github.com/sean-gugler/DeathmazeFairPlay>

This source code has been reconstructed by disassembling and symbolicating the 1980 binary code released for Apple II series computers. It likely bears little resemblance to the original source, but it can be used by modern tools to build the same playable binaries.

To build from the source you need this software:

* [cc65](https://github.com/cc65/cc65) V2.19
* Python 3.8
* GNU Make 4.2

To build the ProDOS disk you also need:

* [cadius](https://github.com/mach-kernel/cadius)
* a disk image with (any version of) [ProDOS](https://prodos8.com/) itself on it, along with BASIC.SYSTEM, placed at `files/prodos.po`

My development environment is Windows Subsystem for Linux, Ubuntu flavor ... although any Linux should do.

Type `make all` to produce both ProDOS and DOS 3.3 disk images in the `output` folder.

Type `make dos` to produce only a DOS 3.3 disk image in the `output` folder.
