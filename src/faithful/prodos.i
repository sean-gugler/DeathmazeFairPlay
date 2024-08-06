; --- Legacy ADDRESSES

DOS_warm_start = $03d0
DOS_cold_start = $03d3
DOS_hook_monitor = $03f8


; --- ProDOS 8

; MLI functions

P8_CREATE        = $c0
P8_SET_FILE_INFO = $c3
P8_GET_FILE_INFO = $c4
P8_SET_PREFIX    = $c6
P8_GET_PREFIX    = $c7
P8_OPEN          = $c8
P8_READ          = $ca
P8_WRITE         = $cb
P8_CLOSE         = $cc

;
; Return codes (in accumulator)
;
P8E_NO_ERR          = $00       ;No error (call succeeded)
P8E_BAD_SC_NUM      = $01       ;Bad system call number
P8E_BAD_SC_PCOUNT   = $04       ;Bad system call parameter count
P8E_INT_TBL_FULL    = $25       ;Interrupt table full
P8E_IO_ERR          = $27       ;I/O error
P8E_NO_DEV_CONN     = $28       ;No device connected
P8E_WRITE_PROT      = $2B       ;Disk write protected
P8E_VOL_SWITCHED    = $2E       ;Volume switched
P8E_INVALID_PATH    = $40       ;Invalid pathname syntax
P8E_MAX_FILES_OPEN  = $42       ;Too many files open
P8E_INVALID_REFNUM  = $43       ;Invalid reference number
P8E_DIR_NOT_FOUND   = $44       ;Directory not found
P8E_VOL_NOT_FOUND   = $45       ;Volume not found
P8E_FILE_NOT_FOUND  = $46       ;File not found
P8E_DUP_FILENAME    = $47       ;Duplicate filename
P8E_VOL_FULL        = $48       ;Volume full
P8E_VOL_DIR_FULL    = $49       ;Volume directory full
P8E_INCOMPAT_FORMAT = $4A       ;Incompatible file format / ProDOS version
P8E_UNSUP_STORAGE   = $4B       ;Unsupported storage_type
P8E_EOF             = $4C       ;End of file encountered
P8E_INVALID_POSN    = $4D       ;Position out of range
P8E_INVALID_ACCESS  = $4E       ;File access error
P8E_FILE_OPEN       = $50       ;File is open
P8E_DIR_DAMAGED     = $51       ;Directory structure damaged
P8E_NOT_PRODOS      = $52       ;Not a ProDOS volume
P8E_INVALID_PARAM   = $53       ;Invalid system call parameter
P8E_VCB_FULL        = $55       ;Volume Control Block table full
P8E_BAD_BUFFER      = $56       ;Bad buffer address
P8E_DUP_VOLUME      = $57       ;Duplicate volume
P8E_FILE_DAMAGED    = $5A       ;File structure damaged (bad volume bitmap?)

;
; System global page.  Labels and comments are from the ProDOS 8
; Technical Reference Manual (section 5.2.4).
;
P8_MLI = $BF00         ;ProDOS MLI call entry point


; --- VALUES
  
P8_access_destroy = %10000000
P8_access_rename  = %01000000
P8_access_backup  = %00100000
P8_access_write   = %00000010
P8_access_read    = %00000001

P8_access_locked   = P8_access_read
P8_access_unlocked = P8_access_read | P8_access_write | P8_access_rename | P8_access_destroy

P8_ftype_BIN = $06

P8_stype_FILE = $01
