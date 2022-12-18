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
AS65FLAGS=-t $(TARGET) -I . -I src/include --debug-info
LD65FLAGS=

%.o: %.c
	$(CC65) -c $(CC65FLAGS) $<

%.o: %.s
	$(AS65) $(AS65FLAGS) $<


output_dir = output

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
	$(output_dir)

$(FOLDERS):
	mkdir -p $@




# Dependencies

DEPS = $(patsubst %.s,%.d,$(wildcard src/*/*.s src/*/*/*.s))

include $(DEPS)

%.d: tools/make_dep.py %.s
	$^ $@

DISTCLEAN += clean_dependencies
clean_dependencies:
	find . -name '*.d' -delete


# Final game files.

FONT = $(output_dir)/FONT.prg

# In-memory address = $4294
# in-file offset = $4294 - $0805 = $3A8F
$(FONT): tools/font.py files/original/DEATHMAZE_B\#060805 | $(output_dir)
	$^ $@ 3A8F

font: $(FONT)

GENERATED += $(FONT)


# Targets that are not explicit files

.PHONY: \
	all \
	font \
	clean $(CLEAN) \
	distclean $(DISTCLEAN)

clean: $(CLEAN)
	rm -rf $(GENERATED)

distclean: $(DISTCLEAN)

all: $(DISKS) $(MB_FILES) $(output_dir)/slideshow_start.do $(output_dir)/slideshow_end.do | $(output_dir)
