# SPOILERS

All the details of what is different in the Fair Play edition are revealed here. Naturally, reading this will give away many of the secrets and puzzle solutions and potentially spoil the play experience for you.

**ONLY PROCEED IF YOU HAVE ALREADY SOLVED THE GAME OR HAVE NO INTEREST IN DOING SO**

You have been warned.


# Changes in the Fair Play edition

## Design revisions

* Hint system revised

The HELP command was nearly useless. It only provided one hint for one puzzle. In all other circumstances, it gave a bland response that wasn't very helpful at all. This command and its synonym "hint" have been re-assigned as synonyms for "instructions" and "directions" to re-display the introductory help screen. The one valid hint has been relocated to appear organically during a partial solve of that puzzle.

* LOOK command revised

More hints were added for a few objects when you LOOK at them. The bland "look at your monitor" response when LOOK is typed by itself is changed to offer the more helpful guidance "Look at what?" I replaced mention of HELP in the instructions with LOOK since it's a much more important command now.

* BALL more consistent

LOOK BALL now provides a colorful description of its violent nature. It also now activates on BURN, BREAK, and EAT, not just THROW and ROLL.

* SAY command removed

This command served no gameplay purpose whatsoever. It provided a modicum of player agency and atmosphere, allowing the player to express any arbitrary word and have it be acknowledged within the game's world.

However, the presence of this feature could also imply the existence of some "magic word" needed to solve a puzzle. There is none. Rather than create one and give the player false hope that disappointingly never materializes, I elected to simply remove the feature.

* FART hint

The original printed game manual had nearly the same text as the instructions you see upon starting a new game. One key difference was that it mentioned the verb "FART" instead of "CHARGE". This is a valuable clue for one of the puzzles. I could restore it here, since Charge already appears later in the game and doesn't need to be mentioned here. That doesn't feel as rewarding as figuring it out from a less direct hint inside the game, though. Instead, I've chosen to rephrase the "eat food" response to suggest gas.

* RING revision

The ring was originally the light source for level 5 after your torch goes out. Its magic light is activated by raising it ... but it confusingly only works on level 5. To improve the experience, I've changed it to glow hot when rubbed. It can then be used to re-light an extinguished torch. The glow only lasts for one turn but can be invoked over and over. This allows its purpose to be consistent and also discoverable much earlier. It shouldn't break the game duration because the torches are still limited in number. Admittedly it also softens the game's harsh lethality by providing a recovery path after the torch goes out through use or by carelessly dropping it. Some might feel this dampens the spirit of the original game. I justify it by noting that those situations are still lethal if the ring is not engaged, and it adds satisfaction of solving one more puzzle.

* FRISBEE purpose

There is now a reason for the frisbee to exist, apart from being a death trap.

* YOYO purpose

There is now a reason for the yoyo to exist.

* CALCULATOR expanded

The criteria for when the calculator works and when it doesn't felt arbitrary and unjustified. So now it always works consistently. To preserve the puzzle gate of not being actually useful or effective until the monster is dead, it brings the monster with you.

It is now reusable as well, not only to encourage exploration without resorting to save games, but to give a purpose to having so many buttons. In the original design only one mattered. Since some of the "useless" items are now required and there is not enough inventory capacity to bring them all along, the ability to go fetch them later becomes important. The extra buttons now serve a vigtal purpose to be able to revisit earlier areas.

## Quality of Life improvements

* Numbers allowed

In one situation, the game responds to numbers the player types in. Formerly, it required spelling out the name of the number, as in "Three". I allow the numeric "3" to work also.

* UNLOCK is a unique verb

There are times when "open" also implies "unlock", and this behavior is preserved. The converse is not true, though; it makes no sense that unlocking something that is not locked, when you have no key, should "open" it. The original game had them as strict synonyms. I have split them into separate verbs.

* DRINK added

There is a situation where this verb is a perfectly reasonable thing to try. So I've enabled that.

* SWORD weight reduced

90 pounds is absurd. The heaviest swords weigh about 7, so I reduced it to that. The weight is purely cosmetic, it doesn't affect game play at all. May as well retain player immersion better by demanding less suspension of disbelief. https://swordscorner.com/how-much-do-swords-weigh-full-analysis-table-lbs-kgs/

* DOG vs MONSTER

It is possible to avoid the dog entirely on Level 2, then return with the calculator after killing the monster. Throwing the sneaker had a scripted response that always mentioned getting eaten by the monster ... which should be impossible since it's already dead. I've fixed it so the dog will still chase the sneaker, even though it vanishes. This is not a win because the dog reappears immediately next turn.

This scenario is also possible in the retail version so I incorporated my change into the fan-fixed version. The README is vague about the details to avoid spoilers.

* PLAY with dog

In the dog encounter, PLAY BALL is recognized. So is THROW BALL. You still die, but at least the stock answer "With who?" now has an answer.
