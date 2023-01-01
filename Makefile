# default target (first one listed). Actual dependencies added at bottom of file.
all:


# Tools.

DISTCLEAN += clean_tools clean_tempfiles

clean_tools:
	rm -rf tools/*.pyc tools/__pycache__

clean_tempfiles:
	find . -name '*.bak' -delete
	find . -name '*.orig' -delete
	find . -name '*.\~*' -delete


# Folders.

output_dir = output
extras_dir = extras

FOLDERS += \
	$(output_dir) \
	$(extras_dir)


# Generated game files.

# TODO: figure out how to annotate the extra symbols
# I hand-edited and commited to git, so they can be
# generated from the strings.txt file

STRING_TABLES = verb noun display intro
STRING_STEMS = $(patsubst %,src/string_%,$(STRING_TABLES))
STRING_DECL = $(patsubst %,%_decl.i,$(STRING_STEMS))
STRING_DEF = $(patsubst %,%_defs.inc,$(STRING_STEMS))
STRINGS = $(STRING_DECL) $(STRING_DEF)

$(STRINGS): tools/build_strings.py src/strings.txt
	$^ $(STRING_STEMS)


src/maze_walls.s: tools/build_maze.py src/maze.txt
	$^ $@

GENERATED += src/maze_walls.s


# Extra files, not part of the game.

GENERATED += $(extras_dir)

strings: tools/extract_strings.py | $(extras_dir)
	$^ files/original/DEATHMAZE_B\#060805 src/strings.txt $(extras_dir)


FONT = $(output_dir)/FONT.prg

$(FONT): tools/font.py src/font.bin | $(output_dir)
	$^ $@ 0

font: $(FONT)

GENERATED += $(FONT)


# Game versions

rev1:
	$(MAKE) -C versions/rev1

rev2:
	$(MAKE) -C versions/rev2

fixed:
	$(MAKE) -C versions/fixed

VERSIONS = rev1 rev2 fixed


CLEAN += clean_versions
clean_versions:
	$(MAKE) clean -C versions/rev1
	$(MAKE) clean -C versions/rev2
	$(MAKE) clean -C versions/fixed


# Generated directories

$(FOLDERS):
	mkdir -p $@


# Targets that are not explicit files

.PHONY: \
	all \
	font \
	strings \
	$(VERSIONS) \
	clean $(CLEAN) \
	distclean $(DISTCLEAN)

clean: $(CLEAN)
	rm -rf $(GENERATED)

distclean: $(DISTCLEAN)

all: $(GENERATED) $(VERSIONS)
