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
build_prodos = build/prodos

FOLDERS += \
	$(output_dir) \
	$(extras_dir) \
	$(build_prodos)


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

fairplay:
	$(MAKE) -C versions/fairplay

fixed_prodos:
	$(MAKE) -C versions/fixed_prodos

fairplay_prodos:
	$(MAKE) -C versions/fairplay_prodos

VERSIONS = rev1 rev2 fixed fairplay fixed_prodos fairplay_prodos


CLEAN += clean_versions
clean_versions:
	$(MAKE) clean -C versions/rev1
	$(MAKE) clean -C versions/rev2
	$(MAKE) clean -C versions/fixed
	$(MAKE) clean -C versions/fairplay
	$(MAKE) clean -C versions/fixed_prodos
	$(MAKE) clean -C versions/fairplay_prodos

# Generated directories

$(FOLDERS):
	mkdir -p $@


# DOS 3.3 Disk image

FILES = \
	files/HELLO.bas \
	files/RESERVED.prg \
	$(output_dir)/deathmaze_rev1.prg \
	$(output_dir)/deathmaze_rev2.prg \
	$(output_dir)/deathmaze_fixed.prg \
	$(output_dir)/deathmaze_fairplay.prg

ATTR = files/DOS_attributes.txt

DOS = files/DOS.bin

DISK = $(output_dir)/deathmaze.do

$(DISK): $(FILES) $(DOS) | $(output_dir)
	@echo "Creating $@"
	tools/dos33.py --format $@  || (rm -f $@ && exit 1)
	tools/dos33.py --sector-write --track 0 --sector 0 $@ $(DOS)  || (rm -f $@ && exit 1)
	tools/dos33.py --write --caps --attr $(ATTR) $@ $(FILES) || (rm -f $@ && exit 1)

dos: $(DISK)

CLEAN += clean_dos
clean_dos:
	rm -f $(DISK)


# ProDOS Disk image

PRODOS = files/prodos.po

PRODOS_FILES = \
	$(PRODOS) \
	files/STARTUP.bas \
	$(output_dir)/deathmaze_fixed_prodos.prg \
	$(output_dir)/deathmaze_fairplay_prodos.prg


PRODISK = $(output_dir)/deathmaze.po

CADIUS = cadius
PYTHON = python3

# cadius requires absolute paths when extracting, so we have to detect volume of the PRODOS disk
GET_VOLUME = $(shell cadius CATALOG $(PRODOS) | $(PYTHON) -c 'import sys;print(list(sys.stdin)[3])')
# cadius appends attribute string to filename on extract, which we'll match with a wildcard
GEN_PRODOS = $(wildcard $(build_prodos)/PRODOS*)
GEN_BASIC  = $(wildcard $(build_prodos)/BASIC.SYSTEM*)

$(PRODISK): $(PRODOS_FILES)
	@echo "Creating $@"
	cadius CREATEVOLUME $@ DEATHMAZE 140kb
	$(eval VOLUME = $(GET_VOLUME))
	cadius EXTRACTFILE $(PRODOS) $(VOLUME)PRODOS $(build_prodos)
	cadius EXTRACTFILE $(PRODOS) $(VOLUME)BASIC.SYSTEM $(build_prodos)
	cp files/STARTUP.bas $(build_prodos)/STARTUP#fc0801
	cp $(output_dir)/deathmaze_fixed_prodos.prg $(build_prodos)/ORIGINAL#060803
	cp $(output_dir)/deathmaze_fairplay_prodos.prg $(build_prodos)/FAIRPLAY#060803
	cadius ADDFOLDER $@ /DEATHMAZE/ $(build_prodos)

prodos: $(PRODISK)

CLEAN += clean_prodos
clean_prodos:
	rm -f $(PRODISK)
	rm -rf $(build_prodos)


# Targets that are not explicit files

.PHONY: \
	all \
	disk \
	font \
	strings \
	$(VERSIONS) \
	clean $(CLEAN) \
	distclean $(DISTCLEAN)

clean: $(CLEAN)
	rm -rf $(GENERATED)

distclean: $(DISTCLEAN)

all: $(VERSIONS) dos prodos
