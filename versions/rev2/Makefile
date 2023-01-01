#default target
deathmaze:

include ../common/Makefile

# Folders

base_dir = ../..

src_dir = $(base_dir)/src
tools_dir = $(base_dir)/tools/
build_dir = $(base_dir)/build/rev2
output_dir = $(base_dir)/output

FOLDERS += \
	$(build_dir) \
	$(output_dir)

# Custom settings

PROGRAM = $(output_dir)/deathmaze_rev2.prg
DEFINES = -DREVISION=2


# For .include "file.i" directives,
# dependencies are automatically generated
# and incorporated into this Makefile

DEPS = $(patsubst $(src_dir)/%.s,$(build_dir)/%.d,$(wildcard $(src_dir)/*.s))

$(build_dir)/%.d: $(tools_dir)/make_dep.py $(src_dir)/%.s | $(build_dir)
	$^ $@

include $(DEPS)


# Game files.

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

OBJS = $(patsubst %,$(build_dir)/%.o,$(CODE) $(DATA))

$(build_dir)/%.o: $(src_dir)/%.s | $(build_dir)
	$(AS65) $(AS65FLAGS) $(DEFINES) $< -o $@

$(PROGRAM): $(build_dir)/loadaddr.o $(OBJS) ../common/deathmaze_retail.cfg
	$(LD65) -m $(build_dir)/$(@F).map -C $(filter %.cfg,$^) -Ln $(build_dir)/$(@F).lab \
		-o $@ $(LD65FLAGS) $(filter %.o,$^) || (rm -f $@ && exit 1)

deathmaze: $(PROGRAM)


# Generated directories and files

$(FOLDERS):
	mkdir -p $@

GENERATED = \
	$(build_dir)\
	$(PROGRAM)

clean: $(CLEAN)
	rm -rf $(GENERATED)
