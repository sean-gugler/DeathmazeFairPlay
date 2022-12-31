# default target (first one listed). Actual dependencies added at bottom of file.
all:

#----------
# Configuration options

#----------

SHELL = /bin/sh

# Remove unfinished targets if interrupted or command failed
.DELETE_ON_ERROR:

# Allow $ expansion in prerequisites (dependencies)
.SECONDEXPANSION:

# Clear all implicit rules built-in to the "make" program
.SUFFIXES:

# Compiler settings for target platform.
TARGET=apple2
CC65=cl65
AS65=ca65
LD65=ld65
CC65FLAGS=-Oirs -t $(TARGET)
AS65FLAGS=-t $(TARGET) -I . --debug-info
LD65FLAGS=

%.o: %.c
	$(CC65) -c $(CC65FLAGS) $<

%.o: %.s
	$(AS65) $(AS65FLAGS) $<


output_dir = output
extras_dir = extras

# Tools.

DISTCLEAN += clean_tools clean_tempfiles

clean_tools:
	rm -rf tools/*.pyc tools/__pycache__

clean_tempfiles:
	find . -name '*.bak' -delete
	find . -name '*.orig' -delete
	find . -name '*.\~*' -delete


# Generated directories

FOLDERS = \
	$(output_dir) \
	$(extras_dir)

$(FOLDERS):
	mkdir -p $@


# Game files.

STRING_TABLES = verb noun display intro
STRING_STEMS = $(patsubst %,src/string_%,$(STRING_TABLES))
STRING_DECL = $(patsubst %,%_decl.i,$(STRING_STEMS))
STRING_DEF = $(patsubst %,%_defs.inc,$(STRING_STEMS))
STRINGS = $(STRING_DECL) $(STRING_DEF)

$(STRINGS): tools/build_strings.py src/strings.txt
	$^ $(STRING_STEMS)

GENERATED += $(STRINGS)


src/maze_walls.s: tools/build_maze.py src/maze.txt
	$^ $@

GENERATED += src/maze_walls.s


# Extras.

GENERATED += $(extras_dir)

strings: tools/extract_strings.py | $(extras_dir)
	$^ files/original/DEATHMAZE_B\#060805 src/strings.txt $(extras_dir)


FONT = $(output_dir)/FONT.prg

# In-memory address = $4294
# in-file offset = $4294 - $0805 = $3A8F
$(FONT): tools/font.py files/original/DEATHMAZE_B\#060805 | $(output_dir)
	$^ $@ 3A8F

font: $(FONT)

GENERATED += $(FONT)



# Dependencies

DEPS = $(patsubst %.s,%.d,$(wildcard src/*.s))

include $(DEPS)

%.d: tools/make_dep.py %.s
	$^ $@

DISTCLEAN += clean_dependencies
clean_dependencies:
	find . -name '*.d' -delete


# Final game files.

CODE = \
	start \
	print \
	main \
	main_junk \
	memcpy \
	special_positions \
	text_buffers \
	input \
	raster \
	swap \
	draw_maze \
	draw_maze_junk \
	item_commands \
	draw_special \
	draw_special_junk \
	player_commands \
	player_commands_junk \
	special_modes \
	special_modes_junk \
	relocator \
	relocator_junk

DATA = \
	maze_walls \
	maze_features \
	new_game \
	game_state \
	font \
	vocab \
	vocab_junk \
	strings \
	strings_junk \
	intro \
	intro_junk \
	save_game \
	save_game_junk

OBJS = $(patsubst %,src/%.o,$(CODE) $(DATA))

#%.prg: %.o src/loadaddr.o $$(or $$(wildcard $$(@D)/$$(*F).cfg),src/main.cfg)

$(output_dir)/deathmaze.prg: src/loadaddr.o $(OBJS) src/deathmaze.cfg
	$(LD65) -m $*.map -C $(filter %.cfg,$^) -Ln $*.lab \
		-o $@ $(LD65FLAGS) $(filter %.o,$^) || (rm -f $@ && exit 1)



# Targets that are not explicit files

.PHONY: \
	all \
	font \
	strings \
	clean $(CLEAN) \
	distclean $(DISTCLEAN)

clean: $(CLEAN)
	rm -rf $(GENERATED)

distclean: $(DISTCLEAN)

all: $(STRINGS) | $(output_dir)
