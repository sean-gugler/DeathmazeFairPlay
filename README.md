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
