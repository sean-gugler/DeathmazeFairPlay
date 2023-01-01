#default target
deathmaze:

include ../common/Makefile

# Folders

base_dir = ../..

src_dir = $(base_dir)/src
tools_dir = $(base_dir)/tools/
build_dir = $(base_dir)/build/fixed
output_dir = $(base_dir)/output

FOLDERS += \
	$(build_dir) \
	$(output_dir)

# Custom settings

PROGRAM = $(output_dir)/deathmaze_fixed.prg
DEFINES = -DREVISION=100


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
	memcpy \
	special_positions \
	text_buffers \
	input \
	raster \
	swap \
	draw_maze \
	item_commands \
	draw_special \
	player_commands \
	special_modes \
	relocator \

DATA = \
	maze_walls \
	maze_features \
	new_game \
	game_state \
	font \
	vocab \
	strings \
	intro \
	save_game

OBJS = $(patsubst %,$(build_dir)/%.o,$(CODE) $(DATA))

$(build_dir)/%.o: $(src_dir)/%.s | $(build_dir)
	$(AS65) $(AS65FLAGS) $(DEFINES) $< -o $@

$(PROGRAM): $(build_dir)/loadaddr.o $(OBJS) deathmaze_fixed.cfg
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
