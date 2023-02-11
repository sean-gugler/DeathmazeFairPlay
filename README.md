# Deathmaze 5000 Fair Play Edition

# About the game

Deathmaze 5000 was released in 1980 by Med Systems Software for the TRS-80 and Apple II platforms. We would describe it today as an "escape room" experience; players are tasked with navigating a maze, manipulating objects, and solving puzzles with the purpose of escape. This was a novel mash-up of play elements at the time. Maze games and text adventures already existed but I am not aware of any earlier example than Deathmaze 5000 that combined the two formats.

The writing was quite clever, but suffered from moon logic, items with no purpose, unfinished puzzles, and some inconsistent behaviors. When I finally solved it after 40 YEARS of trying, I was both satisfied and disappointed. I decided I could do better. Armed with my recent technical experience disassembling Ultima IV, I wove the loose ends together and improved the structure of the weaker puzzles while retaining as much of Deathmaze's original material as I could. I also patched up a small handful of bugs discovered along the way.

The "Fair Play" edition reflects my sensibilities on what consitutes fair puzzle design. My alterations attempt to be consistent with the original writing tone and style. To the degree I've failed, I ask your humble forgiveness.

# Release Notes
This project builds four versions of the game:

1. Early retail release
2. Later retail release
3. Bug fixed fan release
4. Fair Play fan release

## Saved Game file

WARNING: Editions 1 through 3 save the game directly to track 3, sector 0. This is safe on the provided disk because I've allocated a "RESERVED" file to protect that sector. The same may not be true if you copy the files to another disk, so be careful! Safest (though wasteful) to use a completely blank disk for saved games.

Edition 4 saves the game to a proper DOS file through ordinary catalog allocation. This edition and its save file are safe to transport by ordinary means to any other disk. Probably won't work in ProDOS, though.

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
* Torch count now increments if you "get box" then "get torch" and it's the only box you're carrying. Previously it would be off by one. (For fun, try "drop torch"! Repeat all three commands for endless entertainment walking backwards through the font.)
* Move forward into wall during monster encounter, "splat" remains and doesn't flicker.
* Always time to read fate about "the body". Message would briefly flicker if you did an action with a text result, such as "open box".
* Open a door, then immediately open it again. Moving forward would print "splat". It now correctly moves forward.
* If you drop the lit torch, you could temporarily escape the monster by killing a dog.
* If you drop the lit torch while it is dying, the "torch dying" message stops appearing.
* Rare possibility of getting illogical text when defeating the dog.
* Dropping the jar would silently empty it.
* Arriving after a teleport should always face open space. If you arrive facing a wall, your first move can be forward through it.

## Other changes in fan releases
* Smaller file size, trimmed hundreds of unused bytes and optimized some bloated routines.
* Quitting the game cleanly returns you to the BASIC prompt (]) instead of the MONITOR (*).

## Changes in the Fair Play release
* see SPOILERS.md


# Production notes

## Retail editions

The earlier release I have had in my own collection since 1980. It is not an official retail disk, so I have no way of knowing for sure if it was cracked or if the original was not protected. There is no evidence of any vanity vandalism typically inserted by crackers, though.

The later release was found on Asimov, bundled on a disk with some other games. The "save game to disk" feature does not work; it relies on standard DOS, and this disk has "Beautiful Boot" installed. It works fine when the entire program file is transplanted to a standard DOS disk, though. I have no other information on its provenance, such as whether it was cracked or the original was just not protected.

## Observations

The original authors used 1-based indexing ubiquitously, rather than machine-friendly 0-based indexing. In many cases this means setting up data table pointers to the address one entry earlier than where the table actually starts.

The original authors used BPL and BMI after CMP, rather than the customary BCS and BCC. In the general case this is bad practice, but it works in Deathmaze because the numbers being compared are always unsigned 7-bit values (in the range 0 <= A <= 127). (Read more about 6502 comparison logic at http://www.6502.org/tutorials/compare_beyond.html)
