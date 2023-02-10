; --- ADDRESSES

zp_CSWL = $0036 ;$37
zp_A1 = $003c ;$3d
zp_A2 = $003e ;$3e

tape_addr_start = $003c ;$3d
tape_addr_end = $003e ;$3f

APPLESOFT_Prompt = $33
APPLESOFT_OnErrMode = $d8
INTBASIC_RunState = $d9
APPLESOFT_ErrorCode = $de
APPLESOFT_RunState = $76

irq_IIgs = $03fe

screen_TEXT = $0400
screen_GR1  = $0400
screen_GR2  = $0800
screen_HGR1 = $2000
screen_HGR2 = $4000

screen_TEXT_size = $0400
screen_GR_size   = $0400
screen_HGR_size  = $2000

hw_KEYBOARD   = $c000
hw_STROBE     = $c010
hw_TBCOLOR    = $c022  ;IIgs only. HI/LO 4 bits Foreground/Background.
hw_SLTROMSEL  = $c02d  ;IIgs only. Slot per bit: 0 internal, 1 external.
hw_SPEAKER    = $c030
hw_CLOCKCTL   = $c034  ;IIgs only. Low 4 bits = border color

CLOCKCTL_border_color_mask = $f0

hw_GRAPHICS   = $c050
hw_TEXT       = $c051
hw_FULLSCREEN = $c052
hw_PAGE1      = $c054
hw_PAGE2      = $c055
hw_LORES      = $c056
hw_HIRES      = $c057

hw_ROMIN    = $c081
hw_LCBANK2  = $c083
hw_LCBANK1  = $c08b

drive_motor_off = $c088
drive_motor_on  = $c089

rom_SHADOW      = $f000
rom_signature   = $fbb3
rom_ZIDBYTE     = $fbc0
rom_HOME        = $fc58
rom_COUT        = $fded
rom_IIgs_ID     = $fe1f
rom_WRITE_TAPE  = $fecd
rom_READ_TAPE   = $fefd
rom_MONITOR     = $ff69

vector_NMI   = $fffa
vector_RESET = $fffc
vector_IRQ   = $fffe


; --- VALUES

opcode_JSR = $20  ; JSR $hhll
opcode_BIT = $2c  ; BIT $hhll
opcode_JMP = $4c  ; JMP $hhll
opcode_RTS = $60  ; RTS
opcode_BCC = $90  ; BCC $rr

; APPLESOFT_OnErrMode
OnErr_Inactive = $00
OnErr_Active = $80

; INTBASIC_RunState = $d9
INTBASIC_Running = $80  ;anything MI
INTBASIC_NotRunning = $00  ;anything PL

; APPLESOFT_RunState = $76
APPLESOFT_Running = $00  ;or anything not $ff
APPLESOFT_NotRunning = $ff

; APPLESOFT_Prompt = $33
Prompt_Ready = ']'
Prompt_None = $80
