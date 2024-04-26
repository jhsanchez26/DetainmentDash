.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
iy: .res 1
ix: .res 1
current_mega_tile_set: .res 1
map: .res 1
scroll: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
.exportzp pad1


.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import read_controller1

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00
	STA $2005
	STA $2005
  
  JSR read_controller1

  LDA map
  CMP #%01
  BEQ load_new_screen
  update_screen:
  

  LDA scroll
  CMP #255 ; did we scroll to the end of a nametable?
  BNE set_scroll_positions
  ; if yes,
  ; update base nametable
  LDA ppuctrl_settings
  EOR #%00000001 ; flip bit #1 to its opposite
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #255
  STA scroll

  set_scroll_positions:
  INC scroll
	LDA scroll
	STA PPUSCROLL
  LDA #$00
	STA PPUSCROLL

  RTI

  load_new_screen:
  LDA #$00
  STA $2001
  STA $2000
  
  JSR draw_background2L
  JSR draw_background2R
  JSR attributes_background2L
  JSR attributes_background2R
  LDA #%10
  STA map
  LDA $2002 ;avoid getting a partial vblank
	LDA #%10010001  ; turn on NMIs, sprites use first pattern table
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

  RTI
.endproc

.import reset_handler

.export main
.proc main
  LDA #0
  STA scroll
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

  LDA #%00
  STA map

  JSR draw_background1R
  JSR draw_background1L
  JSR attributes_background1L
  JSR attributes_background1R

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010001  ; turn on NMIs, sprites use first pattern table
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JSR update_map
  JMP forever
.endproc

.proc update_map
  LDA pad1
  AND #BTN_A
  BEQ exit_update_map
  LDA map
  CMP #%00
  BNE exit_update_map
  LDA #%01
  STA map
  exit_update_map:
  RTS
.endproc

.proc draw_background1L     
  LDA #$20
  STA iy
  LDA #$00
  STA ix
  LDA #%11111111 ; first four mega tiles
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11010000 ; second row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110010
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11111111 ; third row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11000011 ; fourth row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$00
  STA ix
  LDA #$21
  STA iy
  LDA #%11001111 ; fifth row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11000000 ; sixth row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11101111 ; 7th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11101111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11000000 ; 8th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10001100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$22
  STA iy
  LDA #$00
  STA ix
  LDA #%11001100 ; 9th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11001100 ; 10th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11001100 ; 11th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11001100 ; 12th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$23
  STA iy
  LDA #$00
  STA ix
  LDA #%11001100 ; 13th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11000000 ; 14th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11111111 ; 15th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  RTS
.endproc

.proc draw_background1R     
  LDA #$24
  STA iy
  LDA #$00
  STA ix
  LDA #%11111111 ; first four mega tiles
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11000000 ; 2nd row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10101011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11001111 ; 3rd row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11000000 ; 4th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110010
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$00
  STA ix
  LDA #$25
  STA iy
  LDA #%11001111 ; 5th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11000000 ; 6th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11111100 ; 7th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11000000 ; 8th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$26
  STA iy
  LDA #$00
  STA ix
  LDA #%11101111 ; 9th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00100011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11000000 ; 10th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11001100 ; 11th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00100011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11000000 ; 12th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$27
  STA iy
  LDA #$00
  STA ix
  LDA #%11101111 ; 13th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%00001111 ; 14th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00100111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11111111 ; 15th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  RTS
.endproc

.proc attributes_background1L
  ;Row 1 2
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C0
	STA PPUADDR
	LDA #%10010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C1
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C2
	STA PPUADDR
	LDA #%01000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C3
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C4
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C5
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C6
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C7
	STA PPUADDR
	LDA #%01000101
	STA PPUDATA

  ;Row 3 4
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C8
	STA PPUADDR
	LDA #%00010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C9
	STA PPUADDR
	LDA #%01000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CA
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CB
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CC
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CD
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CE
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CF
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 5 6
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D0
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D1
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D2
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D3
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D4
	STA PPUADDR
	LDA #%00010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D5
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D6
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D7
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 7 8
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D8
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D9
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DA
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DB
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DC
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DD
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DE
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DF
	STA PPUADDR
	LDA #%01000101
	STA PPUDATA

  ;Row 9 10
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E0
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E1
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E2
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E3
	STA PPUADDR
	LDA #%00010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E4
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E5
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E6
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E7
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 11 12
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E8
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E9
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$EA
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$EB
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$EC
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$ED
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$EE
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$EF
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 13 14
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F0
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F1
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F2
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F3
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F4
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F5
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F6
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F7
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  ;Row 15
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F8
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F9
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FA
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FB
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FC
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FD
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FE
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FF
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA
.endproc

.proc attributes_background1R
  ;Row 1 2
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C0
	STA PPUADDR
	LDA #%00010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C1
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C2
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C3
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C4
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C5
	STA PPUADDR
	LDA #%01000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C6
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C7
	STA PPUADDR
	LDA #%01000101
	STA PPUDATA

  ;Row 3 4
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C8
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C9
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CA
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CB
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CC
	STA PPUADDR
	LDA #%01000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CD
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CE
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CF
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 5 6
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D0
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D1
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D2
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D3
	STA PPUADDR
	LDA #%01000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D4
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D5
	STA PPUADDR
	LDA #%01010100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D6
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D7
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 7 8
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D8
	STA PPUADDR
	LDA #%00010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D9
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DA
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DB
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DC
	STA PPUADDR
	LDA #%01000000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DD
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DE
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DF
	STA PPUADDR
	LDA #%01010100
	STA PPUDATA

  ;Row 9 10
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E0
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E1
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E2
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E3
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E4
	STA PPUADDR
	LDA #%01000000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E5
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E6
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E7
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 11 12
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E8
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E9
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$EA
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$EB
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$EC
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$ED
	STA PPUADDR
	LDA #%01000000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$EE
	STA PPUADDR
	LDA #%01000000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$EF
	STA PPUADDR
	LDA #%01010100
	STA PPUDATA

  ;Row 13 14
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F0
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F1
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F2
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F3
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F4
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F5
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F6
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F7
	STA PPUADDR
	LDA #%01110101
	STA PPUDATA

  ;Row 15
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F8
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F9
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FA
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FB
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FC
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FD
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FE
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FF
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA
.endproc

.proc print_mega_tile1
  LDA current_mega_tile_set
  AND #%11000000
  CMP #%11000000
  BNE check10
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDX #$02
  STX PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDX #$03
  STX PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDX #$12
  STX PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDX #$13
  STX PPUDATA
  RTS

  check10:
  CMP #%10000000
  BNE check01
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$08
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$09
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$18
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$19
  STA PPUDATA
  RTS

  check01:
  CMP #%01000000
  BNE check00
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$26
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$27
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$36
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$37
  STA PPUDATA
  RTS

  check00:
  CMP #%00000000
  BNE exit
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$2C
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$2D
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$3C
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$3D
  STA PPUDATA
  exit:
  RTS


.endproc

.proc print_mega_tile2
  LDA current_mega_tile_set
  AND #%00110000
  CMP #%00110000
  BNE check10
  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
	STA PPUADDR
	LDY #$02
	STY PPUDATA

  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
  CLC
  ADC #$01
	STA PPUADDR
	LDY #$03
	STY PPUDATA

  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
  CLC
  ADC #$20
	STA PPUADDR
	LDY #$12
	STY PPUDATA

  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
  CLC
  ADC #$21
	STA PPUADDR
	LDY #$13
	STY PPUDATA
  RTS

  check10:
  CMP #%00100000
  BNE check01
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$08
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$09
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$18
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$19
  STA PPUDATA
  RTS

  check01:
  CMP #%00010000
  BNE check00
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$26
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$27
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$36
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$37
  STA PPUDATA
  RTS

  check00:
  CMP #%00000000
  BNE exit
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$2C
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$2D
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$3C
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$3D
  STA PPUDATA
  exit:
  RTS
.endproc

.proc print_mega_tile3
  LDA current_mega_tile_set
  AND #%00001100
  CMP #%00001100
  BNE check10
  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
	STA PPUADDR
	LDY #$02
	STY PPUDATA

  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
  CLC
  ADC #$01
	STA PPUADDR
	LDY #$03
	STY PPUDATA

  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
  CLC
  ADC #$20
	STA PPUADDR
	LDY #$12
	STY PPUDATA

  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
  CLC
  ADC #$21
	STA PPUADDR
	LDY #$13
	STY PPUDATA
  RTS

  check10:
  CMP #%00001000
  BNE check01
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$08
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$09
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$18
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$19
  STA PPUDATA
  RTS

  check01:
  CMP #%00000100
  BNE check00
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$26
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$27
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$36
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$37
  STA PPUDATA
  RTS

  check00:
  CMP #%00000000
  BNE exit
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$2C
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$2D
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$3C
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$3D
  STA PPUDATA
  exit:
  RTS


.endproc

.proc print_mega_tile4
  LDA current_mega_tile_set
  AND #%00000011
  CMP #%00000011
  BNE check10
  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
	STA PPUADDR
	LDY #$02
	STY PPUDATA

  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
  CLC
  ADC #$01
	STA PPUADDR
	LDY #$03
	STY PPUDATA

  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
  CLC
  ADC #$20
	STA PPUADDR
	LDY #$12
	STY PPUDATA

  LDA PPUSTATUS
	LDA iy
	STA PPUADDR
	LDA ix
  CLC
  ADC #$21
	STA PPUADDR
	LDY #$13
	STY PPUDATA
  RTS

  check10:
  CMP #%00000010
  BNE check01
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$08
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$09
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$18
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$19
  STA PPUDATA
  RTS

  check01:
  CMP #%00000001
  BNE check00
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$26
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$27
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$36
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$37
  STA PPUDATA
  RTS

  check00:
  CMP #%00000000
  BNE exit
  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  STA PPUADDR
  LDA #$2C
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$01
  STA PPUADDR
  LDA #$2D
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$20
  STA PPUADDR
  LDA #$3C
  STA PPUDATA

  LDA PPUSTATUS
  LDA iy
  STA PPUADDR
  LDA ix
  CLC
  ADC #$21
  STA PPUADDR
  LDA #$3D
  STA PPUDATA
  exit:
  RTS
.endproc

.proc draw_background2L     
  LDA #$20
  STA iy
  LDA #$00
  STA ix
  LDA #%11111111 ; first four mega tiles
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11011100 ; second row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000010
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10100000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11001100 ; third row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11001100 ; fourth row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$00
  STA ix
  LDA #$21
  STA iy
  LDA #%11001100 ; fifth row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11101100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10100011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11001100 ; sixth row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10101000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11101100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11001100 ; 7th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10101000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11001000 ; 8th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11101111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$22
  STA iy
  LDA #$00
  STA ix
  LDA #%11001100 ; 9th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11101111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11001100 ; 10th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11001100 ; 11th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11101111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11001100 ; 12th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11101111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$23
  STA iy
  LDA #$00
  STA ix
  LDA #%11001100 ; 13th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11101111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11000000 ; 14th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11111111 ; 15th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  RTS
.endproc

.proc draw_background2R     
  LDA #$24
  STA iy
  LDA #$00
  STA ix
  LDA #%11111111 ; first four mega tiles
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%00000000 ; second row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11001111 ; third row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11001111 ; fourth row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$00
  STA ix
  LDA #$25
  STA iy
  LDA #%11001111 ; fifth row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11001100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11000000 ; sixth row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00001000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00001000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10100011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11111111 ; 7th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11101111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11000000 ; 8th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000010
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10101000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$26
  STA iy
  LDA #$00
  STA ix
  LDA #%11001111 ; 9th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11001111 ; 10th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111100
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11000000 ; 11th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00001011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$C0
  STA ix
  LDA #%11001111 ; 12th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11101111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$27
  STA iy
  LDA #$00
  STA ix
  LDA #%11001111 ; 13th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11101111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11110011
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$40
  STA ix
  LDA #%11000000 ; 14th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000000
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%00000010
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%10000111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA #$80
  STA ix
  LDA #%11111111 ; 15th row
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  LDA ix
  CLC
  ADC #$02
  STA ix
  LDA #%11111111
  STA current_mega_tile_set
  JSR print_mega_tile1
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile2
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile3
  LDA ix
  CLC
  ADC #$02
  STA ix
  JSR print_mega_tile4
  RTS
.endproc

.proc attributes_background2L
  ;Row 1 2
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C0
	STA PPUADDR
	LDA #%10010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C1
	STA PPUADDR
	LDA #%00010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C2
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C3
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C4
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C5
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C6
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C7
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  ;Row 3 4
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C8
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$C9
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CA
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CB
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CC
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CD
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CE
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$CF
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 5 6
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D0
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D1
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D2
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D3
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D4
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D5
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D6
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D7
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 7 8
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D8
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D9
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DA
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DB
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DC
	STA PPUADDR
	LDA #%00010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DD
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DE
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DF
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 9 10
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E0
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E1
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E2
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E3
	STA PPUADDR
	LDA #%00010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E4
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E5
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E6
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E7
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 11 12
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E8
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$E9
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$EA
	STA PPUADDR
	LDA #%00010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$EB
	STA PPUADDR
	LDA #%01000000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$EC
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$ED
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$EE
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$EF
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 13 14
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F0
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F1
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F2
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F3
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F4
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F5
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F6
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F7
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 15
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F8
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$F9
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FA
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FB
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FC
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FD
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FE
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$FF
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA
.endproc

.proc attributes_background2R
  ;Row 1 2
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C0
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C1
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C2
	STA PPUADDR
	LDA #%01000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C3
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C4
	STA PPUADDR
	LDA #%01000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C5
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C6
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C7
	STA PPUADDR
	LDA #%01000101
	STA PPUDATA

  ;Row 3 4
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C8
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$C9
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CA
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CB
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CC
	STA PPUADDR
	LDA #%00010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CD
	STA PPUADDR
	LDA #%00010100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CE
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$CF
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 5 6
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D0
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D1
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D2
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D3
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D4
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D5
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D6
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D7
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 7 8
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D8
	STA PPUADDR
	LDA #%00010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$D9
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DA
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DB
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DC
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DD
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DE
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DF
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 9 10
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E0
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E1
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E2
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E3
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E4
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E5
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E6
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E7
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 11 12
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E8
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$E9
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$EA
	STA PPUADDR
	LDA #%01000000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$EB
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$EC
	STA PPUADDR
	LDA #%00010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$ED
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$EE
	STA PPUADDR
	LDA #%01010000
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$EF
	STA PPUADDR
	LDA #%01000100
	STA PPUDATA

  ;Row 13 14
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F0
	STA PPUADDR
	LDA #%00010001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F1
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F2
	STA PPUADDR
	LDA #%00000100
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F3
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F4
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F5
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F6
	STA PPUADDR
	LDA #%00000101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F7
	STA PPUADDR
	LDA #%01110100
	STA PPUDATA

  ;Row 15
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F8
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$F9
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FA
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FB
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FC
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FD
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FE
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$FF
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $3D, $0F, $00, $30
.byte $3D, $07, $17, $27
.byte $3D, $02, $21, $3C
.byte $3D, $0B, $1A, $29

sprites:
.byte $3D, $0F, $00, $30
.byte $3D, $07, $17, $27
.byte $3D, $02, $21, $3C
.byte $3D, $0B, $1A, $29

.segment "CHR"
.incbin "starfield.chr"
