; --- ADDRESSES

RWTS_IOBPL = $48   ; I/O Block Pointer, LO byte
RWTS_IOBPH = $49   ; I/O Block Pointer, HI byte

DOS_warm_start = $03d0
DOS_call_rwts = $03d9
DOS_hook_cout = $03ea
DOS_hook_monitor = $03f8

; WARNING - not part of DOS API!
; Known for DOS 3.3C but may differ in other DOS editions.
DOS_BREAK  = $9d5a
DOS_ASIBSW = $aab6

RWTS_readblock = $b7b5

RWTS_params = $b7e8   ; also known as DOS IOB (I/O Block)
RWTS_slot   = $b7e9   ; also known as IBSLOT: CONTROLLER SLOT NO. = N * $10
RWTS_volume = $b7eb
RWTS_track = $b7ec
RWTS_sector = $b7ed
RWTS_buf_LO = $b7f0
RWTS_buf_HI = $b7f1
RWTS_command = $b7f4

RWTS_write_data_epilogue3 = $bd5d

DOS_NIBL = $bf29


; --- VALUES

RWTS_command_read = $01

;standard sector header markers for DATA
RWTS_data_epilogue_byte1 = $d5
RWTS_data_epilogue_byte2 = $aa
RWTS_data_epilogue_byte3 = $ad

; DOS_ASIBSW
BASIC_Integer = $00
BASIC_AppleSoft = $40

DOS_error_write_protected = $04
DOS_error_end_of_data = $05
DOS_error_file_not_found = $06
DOS_error_volume_mismatch = $07
DOS_error_io_error = $08
DOS_error_disk_full = $09
DOS_error_file_locked = $0a
