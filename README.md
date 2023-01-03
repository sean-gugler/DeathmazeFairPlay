# DeathmazeFairPlay
Deathmaze 5000 Fair Play Edition

This project builds four (4) versions of the game:

1. Early retail release
2. Later retail release
3. Bug fixed fan release
4. Fair Play fan release

Changes in later retail
* Breaking an item now clears it from the inventory display.
* Space now printed between "You break the" and item name.
* Using the "Say" verb by itself no longer prints garbage.
* Save and Load prompts are now all-caps.

Changes in fan release
* Torch count now increments if you "get box" then "get torch" and it's the only box you're carrying. Previously it would be lost.
* Smaller file size, trimmed hundreds of unused bytes.
* The "Look Dog" command now displays an appropriate response.
* Quitting the game cleanly returns you to the BASIC prompt (]) instead of the MONITOR (*).
* Double-space is properly prevented. Previously it mistakenly prevented a second space only after first letter of second word was started, as in:  WORD_L_

Changes in the Fair Play release
* see SPOILERS.md


# Production notes

The original authors used 1-based indexing ubiquitously, rather than machine-friendly 0-based indexing. In many cases this means setting up data table pointers to the address one entry earlier than where the table actually starts.

The original authors used BPL and BMI after CMP, rather than the customary BCS and BCC. In the general case this is bad practice, but it works in Deathmaze because the numbers being compared are always unsigned 7-bit values (in the range 0 <= A <= 127). (Read more about 6502 comparison logic at http://www.6502.org/tutorials/compare_beyond.html)
