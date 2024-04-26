.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, police1_x, police1_y, police2_x, police2_y

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX $2000
  STX $2001
  STX $4010
  BIT $2002
vblankwait:
  BIT $2002
  BPL vblankwait

	LDX #$00
	LDA #$FF
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam
  
  LDA #17
  STA player_x
  LDA #15
  STA player_y

  LDA #$E2
  STA police1_x
  LDA #$0F
  STA police1_y

  LDA #$E2
  STA police2_x
  LDA #$6F
  STA police2_y

vblankwait2:
BIT $2002
BPL vblankwait2
JMP main
.endproc
