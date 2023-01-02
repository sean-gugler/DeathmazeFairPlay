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


# Extra files, not part of the game.

GENERATED += $(extras_dir)

strings: tools/extract_strings.py | $(extras_dir)
	$^ files/original/DEATHMAZE_B\#060805 src/strings.txt $(extras_dir)


FONT = $(output_dir)/FONT.prg

$(FONT): tools/font.py src/faithful/font.bin | $(output_dir)
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

all: $(VERSIONS)
