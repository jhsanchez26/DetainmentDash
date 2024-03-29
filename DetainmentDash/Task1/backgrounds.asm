.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00
	STA $2005
	STA $2005
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

  ; write sprite data
  LDX #$00
load_sprites:
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$90
  BNE load_sprites

	; write nametables
  ;c1f1
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$48
	STA PPUADDR
	LDX #$40
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$49
	STA PPUADDR
	LDX #$41
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$68
	STA PPUADDR
	LDX #$50
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$69
	STA PPUADDR
	LDX #$51
	STX PPUDATA

  ;c1f2
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$4A
	STA PPUADDR
	LDX #$42
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$4B
	STA PPUADDR
	LDX #$43
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6A
	STA PPUADDR
	LDX #$52
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6B
	STA PPUADDR
	LDX #$53
	STX PPUDATA

  ;c1s1
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$4C
	STA PPUADDR
	LDX #$44
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$4D
	STA PPUADDR
	LDX #$45
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6C
	STA PPUADDR
	LDX #$54
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6D
	STA PPUADDR
	LDX #$55
	STX PPUDATA

  ;c1s2
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$4E
	STA PPUADDR
	LDX #$46
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$4F
	STA PPUADDR
	LDX #$47
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6E
	STA PPUADDR
	LDX #$56
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6F
	STA PPUADDR
	LDX #$57
	STX PPUDATA

  ;c1s3
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$50
	STA PPUADDR
	LDX #$48
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$51
	STA PPUADDR
	LDX #$49
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$70
	STA PPUADDR
	LDX #$58
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$71
	STA PPUADDR
	LDX #$59
	STX PPUDATA

  ;c1b1
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$52
	STA PPUADDR
	LDX #$4A
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$53
	STA PPUADDR
	LDX #$4B
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$72
	STA PPUADDR
	LDX #$5A
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$73
	STA PPUADDR
	LDX #$5B
	STX PPUDATA

  ;c1b2
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$54
	STA PPUADDR
	LDX #$4C
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$55
	STA PPUADDR
	LDX #$4D
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$74
	STA PPUADDR
	LDX #$5C
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$75
	STA PPUADDR
	LDX #$5D
	STX PPUDATA

  ;c2f1
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$88
	STA PPUADDR
	LDX #$60
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$89
	STA PPUADDR
	LDX #$61
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$A8
	STA PPUADDR
	LDX #$70
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$A9
	STA PPUADDR
	LDX #$71
	STX PPUDATA

  ;c2f2
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8A
	STA PPUADDR
	LDX #$62
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8B
	STA PPUADDR
	LDX #$63
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$AA
	STA PPUADDR
	LDX #$72
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$AB
	STA PPUADDR
	LDX #$73
	STX PPUDATA

  ;c2s1
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8C
	STA PPUADDR
	LDX #$64
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8D
	STA PPUADDR
	LDX #$65
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$AC
	STA PPUADDR
	LDX #$74
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$AD
	STA PPUADDR
	LDX #$75
	STX PPUDATA

  ;c2s2
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8E
	STA PPUADDR
	LDX #$66
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8F
	STA PPUADDR
	LDX #$67
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$AE
	STA PPUADDR
	LDX #$76
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$AF
	STA PPUADDR
	LDX #$77
	STX PPUDATA

  ;c2s3
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$90
	STA PPUADDR
	LDX #$68
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$91
	STA PPUADDR
	LDX #$69
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$B0
	STA PPUADDR
	LDX #$78
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$B1
	STA PPUADDR
	LDX #$79
	STX PPUDATA

  ;c2b1
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$92
	STA PPUADDR
	LDX #$6A
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$93
	STA PPUADDR
	LDX #$6B
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$B2
	STA PPUADDR
	LDX #$7A
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$B3
	STA PPUADDR
	LDX #$7B
	STX PPUDATA

  ;c2b2
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$94
	STA PPUADDR
	LDX #$6C
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$95
	STA PPUADDR
	LDX #$6D
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$B4
	STA PPUADDR
	LDX #$7C
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$B5
	STA PPUADDR
	LDX #$7D
	STX PPUDATA

  ;brick
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$C8
	STA PPUADDR
	LDX #$02
	STX PPUDATA

  	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$C9
	STA PPUADDR
	LDX #$03
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$E8
	STA PPUADDR
	LDX #$12
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$E9
	STA PPUADDR
	LDX #$13
	STX PPUDATA

  ;window
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$08
	STA PPUADDR
	LDX #$26
	STX PPUDATA
	
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$09
	STA PPUADDR
	LDX #$27
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$28
	STA PPUADDR
	LDX #$36
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$29
	STA PPUADDR
	LDX #$37
	STX PPUDATA

  ;bed header
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$CA
	STA PPUADDR
	LDX #$04
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$CB
	STA PPUADDR
	LDX #$05
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$EA
	STA PPUADDR
	LDX #$14
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$EB
	STA PPUADDR
	LDX #$15
	STX PPUDATA

  ;bed footer
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0A
	STA PPUADDR
	LDX #$24
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0B
	STA PPUADDR
	LDX #$25
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2A
	STA PPUADDR
	LDX #$34
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2B
	STA PPUADDR
	LDX #$35
	STX PPUDATA

  ;wall right
	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$CC
	STA PPUADDR
	LDX #$0E
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$CD
	STA PPUADDR
	LDX #$0F
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$EC
	STA PPUADDR
	LDX #$0E
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$ED
	STA PPUADDR
	LDX #$0F
	STX PPUDATA

  ;wall left
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0C
	STA PPUADDR
	LDX #$20
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0D
	STA PPUADDR
	LDX #$21
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2C
	STA PPUADDR
	LDX #$20
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2D
	STA PPUADDR
	LDX #$21
	STX PPUDATA

  ;floor1
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$CE
	STA PPUADDR
	LDX #$2C
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$CF
	STA PPUADDR
	LDX #$2D
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$EE
	STA PPUADDR
	LDX #$3C
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$EF
	STA PPUADDR
	LDX #$3D
	STX PPUDATA

  ;floor2
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0E
	STA PPUADDR
	LDX #$22
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0F
	STA PPUADDR
	LDX #$23
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2E
	STA PPUADDR
	LDX #$32
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2F
	STA PPUADDR
	LDX #$33
	STX PPUDATA

	;celltop
	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D0
	STA PPUADDR
	LDX #$08
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D1
	STA PPUADDR
	LDX #$09
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F0
	STA PPUADDR
	LDX #$18
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F1
	STA PPUADDR
	LDX #$19
	STX PPUDATA

	;cellbottom
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$10
	STA PPUADDR
	LDX #$28
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$11
	STA PPUADDR
	LDX #$29
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$30
	STA PPUADDR
	LDX #$38
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$31
	STA PPUADDR
	LDX #$39
	STX PPUDATA

	;cellDoorTop
	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D2
	STA PPUADDR
	LDX #$0A
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D3
	STA PPUADDR
	LDX #$0B
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F2
	STA PPUADDR
	LDX #$1A
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F3
	STA PPUADDR
	LDX #$1B
	STX PPUDATA

	;cellDoorBottom
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$12
	STA PPUADDR
	LDX #$2A
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$13
	STA PPUADDR
	LDX #$2B
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$32
	STA PPUADDR
	LDX #$3A
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$33
	STA PPUADDR
	LDX #$3B
	STX PPUDATA

	;cellDoorOpenTop
	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D4
	STA PPUADDR
	LDX #$A0
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D5
	STA PPUADDR
	LDX #$A1
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F4
	STA PPUADDR
	LDX #$B0
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F5
	STA PPUADDR
	LDX #$B1
	STX PPUDATA

	;cellDoorOpenBottom
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$14
	STA PPUADDR
	LDX #$C0
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$15
	STA PPUADDR
	LDX #$C1
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$34
	STA PPUADDR
	LDX #$D0
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$35
	STA PPUADDR
	LDX #$D1
	STX PPUDATA

	;key
	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D6
	STA PPUADDR
	LDX #$0C
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D7
	STA PPUADDR
	LDX #$0D
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F6
	STA PPUADDR
	LDX #$1C
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F7
	STA PPUADDR
	LDX #$1D
	STX PPUDATA

	;wall
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$16
	STA PPUADDR
	LDX #$06
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$17
	STA PPUADDR
	LDX #$06
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$36
	STA PPUADDR
	LDX #$06
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$37
	STA PPUADDR
	LDX #$06
	STX PPUDATA

	; finally, attribute table
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D2
	STA PPUADDR
	LDA #%01011100
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D3
	STA PPUADDR
	LDA #%01011111
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D4
	STA PPUADDR
	LDA #%01010011
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D5
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DA
	STA PPUADDR
	LDA #%11001010
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DB
	STA PPUADDR
	LDA #%00001010
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DC
	STA PPUADDR
	LDA #%00001010
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DD
	STA PPUADDR
	LDA #%00001010
	STA PPUDATA
  
  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E2
	STA PPUADDR
	LDA #%00001100
	STA PPUDATA

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $3D, $0F, $10, $30
.byte $3D, $27, $0F, $37
.byte $3D, $0F, $11, $37
.byte $3D, $0F, $06, $30

.byte $3D, $00, $0F, $30
.byte $3D, $27, $0F, $37
.byte $3D, $0F, $11, $37
.byte $3D, $05, $05, $16

sprites:
;prisoner front1
; .byte $40, $02, $01, $40
; .byte $40, $03, $01, $48
; .byte $48, $12, $01, $40
; .byte $48, $13, $01, $48

.segment "CHR"
.incbin "starfield.chr"
