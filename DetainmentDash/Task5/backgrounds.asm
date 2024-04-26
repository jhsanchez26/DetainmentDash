.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
iy: .res 1
ix: .res 1
current_mega_tile_set: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
player_x: .res 1
player_y: .res 1
player_dir: .res 1
anim_state_counter: .res 1
anim_state: .res 1
scroll: .res 1
tile_x: .res 1
tile_y: .res 1
y_offset: .res 1
x_offset: .res 1
collision_byte: .res 1
x_shift_amt: .res 1
collision_bits: .res 1
isSolid: .res 1
isSolid1: .res 1
isBush: .res 1
isBush1: .res 1
stage: .res 1
.exportzp pad1, player_x, player_y


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

  LDA scroll
	STA PPUSCROLL
  LDA #$00
	STA PPUSCROLL
  
  JSR read_controller1
  JSR increment_anim_state_counter
  JSR update_player
  JSR verify_scroll1LR

  RTI
.endproc

.import reset_handler

.export main
.proc main
  LDA #%00
  STA stage
  LDA #$00
  STA anim_state_counter
  LDA #%00
  STA player_dir
  LDA #255
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
  JMP forever
.endproc

.proc increment_anim_state_counter
  LDA anim_state_counter
  CMP #$10
  BEQ reset_anim_state_counter
  CMP #00
  BEQ set_anim_state_1
  CMP #$04
  BEQ set_anim_state_2
  CMP #$08
  BEQ set_anim_state_3
  CMP #$0C
  BEQ set_anim_state_4
  INC anim_state_counter
  RTS
  reset_anim_state_counter:
  LDA #$00
  STA anim_state_counter
  RTS
  set_anim_state_1:
  INC anim_state_counter
  LDA #%00
  STA anim_state
  RTS
  set_anim_state_2:
  INC anim_state_counter
  LDA #%01
  STA anim_state
  RTS
  set_anim_state_3:
  INC anim_state_counter
  LDA #%10
  STA anim_state
  RTS
  set_anim_state_4:
  INC anim_state_counter
  LDA #%11
  STA anim_state
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

.proc draw_player_right1
  ; write player tile numbers
  LDA #$06
  STA $0201
  LDA #$07
  STA $0205
  LDA #$16
  STA $0209
  LDA #$17
  STA $020d


  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_right2
  ; write player tile numbers
  LDA #$08
  STA $0201
  LDA #$09
  STA $0205
  LDA #$18
  STA $0209
  LDA #$19
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_right3
  ; write player tile numbers
  LDA #$06
  STA $0201
  LDA #$07
  STA $0205
  LDA #$16
  STA $0209
  LDA #$17
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_right4
  ; write player tile numbers
  LDA #$0A
  STA $0201
  LDA #$0B
  STA $0205
  LDA #$1A
  STA $0209
  LDA #$1B
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_down1
  ; write player tile numbers
  LDA #$02
  STA $0201
  LDA #$03
  STA $0205
  LDA #$12
  STA $0209
  LDA #$13
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_down2
  ; write player tile numbers
  LDA #$04
  STA $0201
  ; LDA #%01000001
  LDA #$05
  STA $0205
  LDA #$14
  STA $0209
  LDA #$15
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_down3
  ; write player tile numbers
  LDA #$02
  STA $0201
  LDA #$03
  STA $0205
  LDA #$12
  STA $0209
  LDA #$13
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_down4
  ; write player tile numbers
  LDA #$46
  STA $0201
  LDA #$47
  STA $0205
  LDA #$56
  STA $0209
  LDA #$57
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc
.proc draw_player_left1
  ; write player tile numbers
  LDA #$40
  STA $0201
  LDA #$41
  STA $0205
  LDA #$50
  STA $0209
  LDA #$51
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_left2
  ; write player tile numbers
  LDA #$42
  STA $0201
  LDA #$43
  STA $0205
  LDA #$52
  STA $0209
  LDA #$53
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_left3
  ; write player tile numbers
  LDA #$40
  STA $0201
  LDA #$41
  STA $0205
  LDA #$50
  STA $0209
  LDA #$51
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_left4
  ; write player tile numbers
  LDA #$44
  STA $0201
  LDA #$45
  STA $0205
  LDA #$54
  STA $0209
  LDA #$55
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_up1
  ; write player tile numbers
  LDA #$0C
  STA $0201
  LDA #$0D
  STA $0205
  LDA #$1C
  STA $0209
  LDA #$1D
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_up2
  ; write player tile numbers
  LDA #$0E
  STA $0201
  LDA #$0F
  STA $0205
  LDA #$1E
  STA $0209
  LDA #$1F
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_up3
  ; write player tile numbers
  LDA #$0C
  STA $0201
  LDA #$0D
  STA $0205
  LDA #$1C
  STA $0209
  LDA #$1D
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc draw_player_up4
  ; write player tile numbers
  LDA #$48
  STA $0201
  LDA #$49
  STA $0205
  LDA #$58
  STA $0209
  LDA #$59
  STA $020d

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f
  RTS
  .endproc

.proc update_player
  LDA player_x ; check if draw on top of tile or behind tile
  CLC
  ADC #4
  LSR
  LSR
  LSR
  LSR
  STA tile_x
  LSR
  LSR
  STA x_offset
  LDA player_y
  CLC
  ADC #2
  LSR
  LSR
  AND #%11111100
  STA y_offset
  LSR
  LSR
  STA tile_y
  INC tile_y
  JSR verify_bush
  LDA isBush
  STA isBush1
  LDA player_x ; check if draw on top of tile or behind tile
  CLC
  ADC #13
  LSR
  LSR
  LSR
  LSR
  STA tile_x
  LSR
  LSR
  STA x_offset
  LDA player_y
  CLC
  ADC #13
  LSR
  LSR
  AND #%11111100
  STA y_offset
  LSR
  LSR
  STA tile_y
  INC tile_y
  JSR verify_bush
  LDA isBush
  CMP #$01
  BEQ draw_behind
  LDA isBush1
  CMP #$01
  BEQ draw_behind
  LDA #%00000001
  STA $0202
  STA $0206
  STA $020a
  STA $020e
  JMP check_left
  draw_behind:
  LDA #%00100001
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  check_left:
  LDA pad1
  AND #BTN_LEFT
  BEQ check_right
  JMP move_left
  check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  JMP move_right
  check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  JMP move_up
  check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ idle1
  JMP move_down1
  move_right:
    LDA #%01
    STA player_dir
    LDA player_x
    CLC
    ADC #14
    LSR
    LSR
    LSR
    LSR
    STA tile_x
    LSR
    LSR
    STA x_offset
    LDA player_y
    CLC
    ADC #2
    LSR
    LSR
    AND #%11111100
    STA y_offset
    LSR
    LSR
    STA tile_y
    INC tile_y
    JSR verify_collision
    LDA isSolid
    STA isSolid1
    LDA player_x
    CLC
    ADC #14
    LSR
    LSR
    LSR
    LSR
    STA tile_x
    LSR
    LSR
    STA x_offset
    LDA player_y
    CLC
    ADC #15
    LSR
    LSR
    AND #%11111100
    STA y_offset
    LSR
    LSR
    STA tile_y
    INC tile_y
    JSR verify_collision
    LDA isSolid
    CMP #%1
    BEQ dont_move_right
    LDA isSolid1
    CMP #%1
    BEQ dont_move_right
    INC player_x
    dont_move_right:
    LDA anim_state
    CMP #%00
    BEQ r1
    CMP #%01
    BEQ r2
    CMP #%10
    BEQ r3
    CMP #%11
    BEQ r4
    idle1:
      JMP idle ;shortcut
    r1:
      JSR draw_player_right1
      RTS
    
    r2:
      JSR draw_player_right2
      RTS
    r3:
      JSR draw_player_right3
      RTS
    r4:
      JSR draw_player_right4
      RTS


  
  move_left:
    LDA #%10 ; this stores the player direction (will only be used for animation)
    STA player_dir
    LDA player_x ; this is to calculate the tile to the left of the player 
    SEC
    SBC #1
    LSR
    LSR
    LSR
    LSR
    STA tile_x
    LSR
    LSR
    STA x_offset
    LDA player_y
    CLC
    ADC #2
    LSR
    LSR
    AND #%11111100
    STA y_offset
    LSR
    LSR
    STA tile_y
    INC tile_y
    JSR verify_collision
    LDA isSolid
    STA isSolid1
    LDA player_x
    SEC
    SBC #1
    LSR
    LSR
    LSR
    LSR
    STA tile_x
    LSR
    LSR
    STA x_offset
    LDA player_y
    CLC
    ADC #15
    LSR
    LSR
    AND #%11111100
    STA y_offset
    LSR
    LSR
    STA tile_y
    INC tile_y
    JSR verify_collision
    LDA isSolid
    CMP #%1
    BEQ dont_move_left 
    LDA isSolid1
    CMP #%1
    BEQ dont_move_left
    DEC player_x
    dont_move_left:
    LDA anim_state
    CMP #%00
    BEQ l1
    CMP #%01
    BEQ l2
    CMP #%10
    BEQ l3
    CMP #%11
    BEQ l4
    
    l1:
      JSR draw_player_left1
      RTS
    l2:
      JSR draw_player_left2
      RTS
    l3:
      JSR draw_player_left3
      RTS
    l4:
      JSR draw_player_left4
      RTS
    move_down1: ;shortcut
      JMP move_down   
  move_up:
    LDA #%11
    STA player_dir
    LDA player_x
    CLC
    ADC #13
    LSR
    LSR
    LSR
    LSR
    STA tile_x
    LSR
    LSR
    STA x_offset
    LDA player_y
    LSR
    LSR
    AND #%11111100
    STA y_offset
    LSR
    LSR
    STA tile_y
    INC tile_y
    JSR verify_collision
    LDA isSolid
    STA isSolid1
    LDA player_x
    CLC
    ADC #1
    LSR
    LSR
    LSR
    LSR
    STA tile_x
    LSR
    LSR
    STA x_offset
    LDA player_y
    LSR
    LSR
    AND #%11111100
    STA y_offset
    LSR
    LSR
    STA tile_y
    INC tile_y
    JSR verify_collision
    LDA isSolid
    CMP #%1
    BEQ dont_move_up 
    LDA isSolid1
    CMP #%1
    BEQ dont_move_up
    DEC player_y
    dont_move_up:
    LDA anim_state
    CMP #%00
    BEQ u1
    CMP #%01
    BEQ u2
    CMP #%10
    BEQ u3
    CMP #%11
    BEQ u4
    u1:
      JSR draw_player_up1
      RTS
    u2:
      JSR draw_player_up2
      RTS
    u3:
      JSR draw_player_up3
      RTS
    u4:
      JSR draw_player_up4
      RTS
    r1sc: ;shortcut
      JMP r1
  move_down:
    LDA #%00
    STA player_dir
    LDA player_x
    CLC
    ADC #13
    LSR
    LSR
    LSR
    LSR
    STA tile_x
    LSR
    LSR
    STA x_offset
    LDA player_y
    CLC
    ADC #17
    LSR
    LSR
    AND #%11111100
    STA y_offset
    LSR
    LSR
    STA tile_y
    INC tile_y
    JSR verify_collision
    LDA isSolid
    STA isSolid1
    LDA player_x
    CLC
    ADC #1
    LSR
    LSR
    LSR
    LSR
    STA tile_x
    LSR
    LSR
    STA x_offset
    LDA player_y
    CLC
    ADC #17
    LSR
    LSR
    AND #%11111100
    STA y_offset
    LSR
    LSR
    STA tile_y
    INC tile_y
    JSR verify_collision
    LDA isSolid
    CMP #%1
    BEQ dont_move_down
    LDA isSolid1
    CMP #%1
    BEQ dont_move_down
    INC player_y
    dont_move_down:
    LDA anim_state
    CMP #%00
    BEQ d1
    CMP #%01
    BEQ d2
    CMP #%10
    BEQ d3
    CMP #%11
    BEQ d4
    d1:
      JSR draw_player_down1
      RTS
      r1sc2: ;sc
      JMP r1sc
    u1sc:
      JMP u1
    d2:
      JSR draw_player_down2
      RTS
    d3:
      JSR draw_player_down3
      RTS
    d4:
      JSR draw_player_down4
      RTS
  idle:
    LDA player_dir
    CMP #%01
    BEQ r1sc2
    CMP #%10
    BEQ l1sc2
    CMP #%11
    BEQ u1sc
    JMP d1
    l1sc2:
    JSR draw_player_left1
    RTS
  exit_subroutine:
    RTS
  .endproc

.proc verify_collision
  LDA y_offset
  CLC
  ADC x_offset
  TAX
  LDA stage
  CMP #%01
  BEQ get_background1R
  LDA background1L, X
  JMP background_got
  get_background1R:
  LDA background1R, X
  background_got:
  STA collision_byte
  LDA tile_x
  AND #%00000011
  TAX
  LDA collision_byte
  AND collision_bits_mask, X
  CMP collision_bits_mask, X
  BEQ solid_block
  LDA #%0
  STA isSolid
  RTS
  solid_block:
  LDA #%1
  STA isSolid
  RTS
  .endproc

.proc verify_bush
  LDA y_offset
  CLC
  ADC x_offset
  TAX
  LDA stage
  CMP #%01
  BEQ bush_get_background1R
  LDA background1L, X
  JMP bush_background_got
  bush_get_background1R:
  LDA background1R, X
  bush_background_got:
  STA collision_byte
  LDA tile_x
  AND #%00000011
  TAX
  LDA collision_byte
  
  AND bush_bits_mask, X
  CMP bush_bits_mask, X
  BEQ bush
  LDA #%0
  STA isBush
  RTS
  bush:
  LDA #%1
  STA isBush
  RTS
  .endproc

.proc verify_scroll1LR
  LDA stage
  CMP #%01
  BEQ exit_verify_scroll
  LDA tile_y
  CMP #$0E
  BNE exit_verify_scroll
  LDA tile_x
  CMP #$0F
  BNE exit_verify_scroll
  LDA #250
	STA PPUSCROLL
  LDA #$00
	STA PPUSCROLL
  LDA #$02
  STA player_x
  LDA #%01
  STA stage
  LDA #0
  STA scroll
  exit_verify_scroll:
  RTS
.endproc

background1L:
.byte $FF, $FF, $FF, $FF
.byte $D0, $32, $00, $03
.byte $FF, $33, $3F, $F3
.byte $C3, $33, $00, $03
.byte $CF, $33, $FF, $FB
.byte $C0, $30, $C0, $03
.byte $EF, $FC, $EF, $FF
.byte $C0, $8C, $C0, $03
.byte $CC, $C0, $CC, $33
.byte $CC, $CC, $C0, $03
.byte $CC, $CC, $FF, $FB
.byte $CC, $CC, $00, $F3
.byte $CC, $CC, $FC, $F3
.byte $C0, $CC, $00, $F0
.byte $FF, $FF, $FF, $FF

background1R:
.byte $FF, $FF, $FF, $FF
.byte $C0, $00, $03, $AB
.byte $CF, $FF, $F3, $BB
.byte $C0, $00, $32, $BB
.byte $CF, $CF, $03, $03
.byte $C0, $C3, $FF, $F3
.byte $FC, $F3, $00, $03
.byte $C0, $FB, $BF, $FF
.byte $EF, $C0, $23, $03
.byte $C0, $CF, $3B, $F3
.byte $CC, $CF, $30, $23
.byte $C0, $CF, $33, $3F
.byte $EF, $CF, $33, $3F
.byte $0F, $C0, $30, $27
.byte $FF, $FF, $FF, $FF


collision_bits_mask:
.byte %11000000
.byte %00110000
.byte %00001100
.byte %00000011

bush_bits_mask:
.byte %10000000
.byte %00100000
.byte %00001000
.byte %00000010


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
.byte $3D, $27, $0F, $37
.byte $3D, $02, $21, $3C
.byte $3D, $0B, $1A, $29

.segment "CHR"
.incbin "starfield.chr"
