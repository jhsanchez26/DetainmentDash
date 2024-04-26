.include "constants.inc"
.include "header.inc"
.include "famitone5.s"
.include "heatman.s"
.include "gameover.s"
.include "gamewon.s"

.segment "ZEROPAGE"
iy: .res 1
ix: .res 1
current_mega_tile_set: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
player_x: .res 1
player_y: .res 1
player_dir: .res 1
police1_x: .res 1
police1_y: .res 1
police1_dir: .res 1
police2_x: .res 1
police2_y: .res 1
police2_dir: .res 1
police1_x_left: .res 1
police1_y_up: .res 1
police2_x_left: .res 1
police2_y_up: .res 1
police1_x_right: .res 1
police1_y_down: .res 1
police2_x_right: .res 1
police2_y_down: .res 1
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
timer_ones: .res 1
timer_tens: .res 1
timer_timer: .res 1
.exportzp pad1, player_x, player_y, police1_x, police1_y, police2_x, police2_y


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
  
  LDA stage
  CMP #$CC
  BEQ do_nothing
  CMP #$FF
  BEQ load_game_won_screen
  CMP #$F0
  BEQ load_game_over_screen1
  CMP #%100
  BEQ load_new_screen

  JSR read_controller1
  JSR increment_anim_state_counter

  JSR update_player
  JSR update_police1
  JSR update_police2
  JSR verify_caught
  JSR verify_stage_change

  JSR draw_timer_ones
  JSR draw_timer_tens
  continue_to_timer:
  LDA timer_timer
  CMP #0
  BEQ reset_timer_timer1
  DEC timer_timer

  do_nothing:
  JSR FamiToneUpdate
  RTI
  load_game_over_screen1:
  JMP load_game_over_screen
  
  load_new_screen:
  LDA #$00
  STA $2001
  STA $2000
  JSR draw_background2L
  JSR draw_background2R
  JSR attributes_background2L
  JSR attributes_background2R
  LDA #%10
  STA stage
  LDA $2002 ;avoid getting a partial vblank
	LDA #%10010001  ; turn on NMIs, sprites use first pattern table
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

  RTI
  reset_timer_timer1:
  JMP reset_timer_timer
  load_game_won_screen:
  LDX #<gamewon_music_data ;low
  LDY #>gamewon_music_data ;high
  LDA #1 ;NTSC = 1, PAL = 0
  JSR FamiToneInit
	LDA #0
	JSR FamiToneMusicPlay
  LDA #$00
  STA $2001
  STA $2000
  JSR draw_game_won_screen
  LDA #$CC
  STA stage
  LDA $2002 ;avoid getting a partial vblank
	LDA #%10010001  ; turn on NMIs, sprites use first pattern table
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

  RTI

  load_game_over_screen:
  LDX #<gameover_music_data ;low
  LDY #>gameover_music_data ;high
  LDA #1 ;NTSC = 1, PAL = 0
  JSR FamiToneInit
	LDA #0
	JSR FamiToneMusicPlay
  LDA #$00
  STA $2001
  STA $2000
  JSR draw_game_over_screen
  LDA #$CC
  STA stage
  LDA $2002 ;avoid getting a partial vblank
	LDA #%10010001  ; turn on NMIs, sprites use first pattern table
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

  RTI
  
  reset_timer_timer:
  LDA #$40
  STA timer_timer
  JSR decrease_timer
  RTI
.endproc

.import reset_handler

.export main
.proc main
  LDX #<heatman_music_data ;low
  LDY #>heatman_music_data ;high
  LDA #1 ;NTSC = 1, PAL = 0
  JSR FamiToneInit
	LDA #0
	JSR FamiToneMusicPlay
  LDA #%00
  STA stage
  STA anim_state_counter
  STA player_dir
  STA police1_dir
  STA police2_dir
  LDA #9
  STA timer_tens
  STA timer_ones
  LDA #$0F
  STA police1_y_up
  LDA #$2F
  STA police1_y_down
  LDA #$7F
  STA police1_x_left
  LDA #$E2
  STA police1_x_right
  STA police2_x_right
  LDA #$8F
  STA police2_y_down
  LDA #$6F
  STA police2_y_up
  LDA #$90
  STA police2_x_left
  LDA #255
  STA scroll
  LDA #%10
  STA $0232
  STA $0236
  STA $023a
  STA $023e
  STA $0242
  STA $0246
  STA $024a
  STA $024e
  
  LDA $00
  STA FamiToneMusicPlay

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
  LDA #$02 ;temp
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
  CMP #%00
  BEQ get_background1L
  CMP #%10
  BEQ get_background2L
  CMP #%01
  BEQ get_background1R
  CMP #%11
  BEQ get_background2R
  RTS
  get_background2R:
  LDA background2R, X
  JMP background_got
  get_background1L:
  LDA background1L, X
  JMP background_got
  get_background1R:
  LDA background1R, X
  JMP background_got
  get_background2L:
  LDA background2L, X
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
  CMP #%00
  BEQ bush_background1L
  CMP #%10
  BEQ bush_background2L
  CMP #%01
  BEQ bush_background1R
  CMP #%11
  BEQ bush_background2R
  RTS
  bush_background2R:
  LDA background2R, X
  JMP bush_background_got
  bush_background1L:
  LDA background1L, X
  JMP bush_background_got
  bush_background1R:
  LDA background1R, X
  JMP bush_background_got
  bush_background2L:
  LDA background2L, X
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

.proc verify_stage_change
  LDA stage
  CMP #%00
  BNE verify_stage1R
  LDA tile_y
  CMP #$0E
  BNE exit_verify_stage_change1
  LDA tile_x
  CMP #$0F
  BNE exit_verify_stage_change1
  LDA #$03
  STA player_x
  LDA #%01
  STA stage
  LDA #0
  STA scroll
  STA police1_dir
  STA police2_dir
  LDA #$82
  STA police1_x
  STA police1_x_right
  LDA #$7F
  STA police1_y
  STA police1_y_up
  LDA #$50
  STA police1_x_left
  LDA #$CF
  STA police1_y_down
  LDA #$C2
  STA police2_x
  STA police2_x_right
  LDA #$9F
  STA police2_y
  STA police2_y_up
  LDA #$A0
  STA police2_x_left
  LDA #$CF
  STA police2_y_down
  RTS
  exit_verify_stage_change1:
  JMP exit_verify_stage_change
  verify_stage1R:
  LDA stage
  CMP #%01
  BNE verify_stage2L
  LDA tile_y
  CMP #$0E
  BNE exit_verify_stage_change2
  LDA tile_x
  CMP #$0E
  BNE exit_verify_stage_change2
  LDA #%100
  STA stage
  LDA #255
  STA scroll
  LDA #17
  STA player_x
  LDA #15
  STA player_y
  LDA #0
  STA police1_dir
  STA police2_dir
  LDA #$72
  STA police1_x
  STA police1_x_right
  LDA #$0F
  STA police1_y
  STA police1_y_up
  LDA #$30
  STA police1_x_left
  LDA #$6F
  STA police1_y_down
  LDA #$E2
  STA police2_x
  STA police2_x_right
  LDA #$8F
  STA police2_y
  STA police2_y_up
  LDA #$90
  STA police2_x_left
  LDA #$CF
  STA police2_y_down
  RTS
  exit_verify_stage_change2:
  JMP exit_verify_stage_change
  verify_stage2L:
  LDA stage
  CMP #%10
  BNE verify_stage2R
  LDA tile_y
  CMP #$02
  BNE exit_verify_stage_change
  LDA tile_x
  CMP #$0F
  BNE exit_verify_stage_change
  LDA #$03
  STA player_x
  LDA #%11
  STA stage
  LDA #0
  STA scroll
  STA police1_dir
  STA police2_dir
  LDA #$42
  STA police1_x
  STA police1_x_right
  LDA #$0F
  STA police1_y
  STA police1_y_up
  LDA #$10
  STA police1_x_left
  LDA #$4F
  STA police1_y_down
  LDA #$E2
  STA police2_x
  STA police2_x_right
  LDA #$2F
  STA police2_y
  STA police2_y_up
  LDA #$B0
  STA police2_x_left
  LDA #$6F
  STA police2_y_down
  verify_stage2R:
  LDA stage
  CMP #%11
  BNE exit_verify_stage_change
  LDA tile_y
  CMP #$0E
  BNE exit_verify_stage_change
  LDA tile_x
  CMP #$0E
  BNE exit_verify_stage_change
  LDA #$FF
  STA stage
  exit_verify_stage_change:
  RTS
  .endproc

.proc decrease_timer
  LDA timer_tens
  CMP #0
  BEQ check_lost
  LDA timer_ones
  CMP #0
  BEQ decrease_tens
  DEC timer_ones
  RTS
  decrease_tens:
  DEC timer_tens
  LDA #9
  STA timer_ones
  RTS
  check_lost:
  LDA timer_ones
  CMP #0
  BEQ lost
  DEC timer_ones
  RTS
  lost:
  LDA #$F0
  STA stage
  LDA #9
  STA timer_ones
  RTS
  .endproc

.proc draw_timer_ones
  
  LDA timer_ones
  CMP #9
  BEQ draw_ones_nine
  CMP #8
  BEQ draw_ones_eight
  CMP #7
  BEQ draw_ones_seven
  CMP #6
  BEQ draw_ones_six
  CMP #5
  BEQ draw_ones_five_sc
  CMP #4
  BEQ draw_ones_four_sc
  CMP #3
  BEQ draw_ones_three_sc
  CMP #2
  BEQ draw_ones_two_sc
  CMP #1
  BEQ draw_ones_one_sc
  LDA #$60
  STA $0211
  LDA #$61
  STA $0215
  LDA #$70
  STA $0219
  LDA #$71
  STA $021d
  JMP draw_ones

  draw_ones_nine:
  LDA #$82
  STA $0211
  LDA #$83
  STA $0215
  LDA #$92
  STA $0219
  LDA #$93
  STA $021d
  JMP draw_ones

  draw_ones_eight:
  LDA #$80
  STA $0211
  LDA #$81
  STA $0215
  LDA #$90
  STA $0219
  LDA #$91
  STA $021d
  JMP draw_ones

  draw_ones_seven:
  LDA #$6E
  STA $0211
  LDA #$6F
  STA $0215
  LDA #$7E
  STA $0219
  LDA #$7F
  STA $021d
  JMP draw_ones
  
  draw_ones_five_sc:
  JMP draw_ones_five
  draw_ones_four_sc:
  JMP draw_ones_four
  draw_ones_three_sc:
  JMP draw_ones_three
  draw_ones_two_sc:
  JMP draw_ones_two
  draw_ones_one_sc:
  JMP draw_ones_one

  draw_ones_six:
  LDA #$6C
  STA $0211
  LDA #$6D
  STA $0215
  LDA #$7C
  STA $0219
  LDA #$7D
  STA $021d
  JMP draw_ones

  draw_ones_five:
  LDA #$6A
  STA $0211
  LDA #$6B
  STA $0215
  LDA #$7A
  STA $0219
  LDA #$7B
  STA $021d
  JMP draw_ones
  
  draw_ones_four:
  LDA #$68
  STA $0211
  LDA #$69
  STA $0215
  LDA #$78
  STA $0219
  LDA #$79
  STA $021d
  JMP draw_ones

  draw_ones_three:
  LDA #$66
  STA $0211
  LDA #$67
  STA $0215
  LDA #$76
  STA $0219
  LDA #$77
  STA $021d
  JMP draw_ones

  draw_ones_two:
  LDA #$64
  STA $0211
  LDA #$65
  STA $0215
  LDA #$74
  STA $0219
  LDA #$75
  STA $021d
  JMP draw_ones

  draw_ones_one:
  LDA #$62
  STA $0211
  LDA #$63
  STA $0215
  LDA #$72
  STA $0219
  LDA #$73
  STA $021d
  JMP draw_ones

  draw_ones:
  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  ; top left tile:
  LDA #$00
  STA $0210
  LDA #$82
  STA $0213

  ; top right tile (x + 8):
  LDA #$00
  STA $0214
  LDA #$82
  CLC
  ADC #$08
  STA $0217

  ; bottom left tile (y + 8):
  LDA #$00
  CLC
  ADC #$08
  STA $0218
  LDA #$82
  STA $021b

  ; bottom right tile (x + 8, y + 8)
  LDA #$00
  CLC
  ADC #$08
  STA $021c
  LDA #$82
  CLC
  ADC #$08
  STA $021f
  RTS
  .endproc

.proc draw_timer_tens
  
  LDA timer_tens
  CMP #9
  BEQ draw_tens_nine
  CMP #8
  BEQ draw_tens_eight
  CMP #7
  BEQ draw_tens_seven
  CMP #6
  BEQ draw_tens_six
  CMP #5
  BEQ draw_tens_five_sc
  CMP #4
  BEQ draw_tens_four_sc
  CMP #3
  BEQ draw_tens_three_sc
  CMP #2
  BEQ draw_tens_two_sc
  CMP #1
  BEQ draw_tens_one_sc
  LDA #$60
  STA $0221
  LDA #$61
  STA $0225
  LDA #$70
  STA $0229
  LDA #$71
  STA $022d
  JMP draw_tens

  draw_tens_nine:
  LDA #$82
  STA $0221
  LDA #$83
  STA $0225
  LDA #$92
  STA $0229
  LDA #$93
  STA $022d
  JMP draw_tens

  draw_tens_eight:
  LDA #$80
  STA $0221
  LDA #$81
  STA $0225
  LDA #$90
  STA $0229
  LDA #$91
  STA $022d
  JMP draw_tens

  draw_tens_seven:
  LDA #$6E
  STA $0221
  LDA #$6F
  STA $0225
  LDA #$7E
  STA $0229
  LDA #$7F
  STA $022d
  JMP draw_tens
  
  draw_tens_five_sc:
  JMP draw_tens_five
  draw_tens_four_sc:
  JMP draw_tens_four
  draw_tens_three_sc:
  JMP draw_tens_three
  draw_tens_two_sc:
  JMP draw_tens_two
  draw_tens_one_sc:
  JMP draw_tens_one

  draw_tens_six:
  LDA #$6C
  STA $0221
  LDA #$6D
  STA $0225
  LDA #$7C
  STA $0229
  LDA #$7D
  STA $022d
  JMP draw_tens

  draw_tens_five:
  LDA #$6A
  STA $0221
  LDA #$6B
  STA $0225
  LDA #$7A
  STA $0229
  LDA #$7B
  STA $022d
  JMP draw_tens
  
  draw_tens_four:
  LDA #$68
  STA $0221
  LDA #$69
  STA $0225
  LDA #$78
  STA $0229
  LDA #$79
  STA $022d
  JMP draw_tens

  draw_tens_three:
  LDA #$66
  STA $0221
  LDA #$67
  STA $0225
  LDA #$76
  STA $0229
  LDA #$77
  STA $022d
  JMP draw_tens

  draw_tens_two:
  LDA #$64
  STA $0221
  LDA #$65
  STA $0225
  LDA #$74
  STA $0229
  LDA #$75
  STA $022d
  JMP draw_tens

  draw_tens_one:
  LDA #$62
  STA $0221
  LDA #$63
  STA $0225
  LDA #$72
  STA $0229
  LDA #$73
  STA $022d
  JMP draw_tens

  draw_tens:
  LDA #$00
  STA $0222
  STA $0226
  STA $022a
  STA $022e

  ; top left tile:
  LDA #$00
  STA $0220
  LDA #$72
  STA $0223

  ; top right tile (x + 8):
  LDA #$00
  STA $0224
  LDA #$72
  CLC
  ADC #$08
  STA $0227

  ; bottom left tile (y + 8):
  LDA #$00
  CLC
  ADC #$08
  STA $0228
  LDA #$72
  STA $022b

  ; bottom right tile (x + 8, y + 8)
  LDA #$00
  CLC
  ADC #$08
  STA $022c
  LDA #$72
  CLC
  ADC #$08
  STA $022f
  RTS
  .endproc

.proc draw_game_over_screen
  LDA PPUSTATUS ;game
	LDA #$21
	STA PPUADDR
	LDA #$8C
	STA PPUADDR
	LDX #$46
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8D
	STA PPUADDR
	LDX #$47
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$AC
	STA PPUADDR
	LDX #$56
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$AD
	STA PPUADDR
	LDX #$57
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8E
	STA PPUADDR
	LDX #$44
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$8F
	STA PPUADDR
	LDX #$45
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$AE
	STA PPUADDR
	LDX #$54
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$AF
	STA PPUADDR
	LDX #$55
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$90
	STA PPUADDR
	LDX #$60
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$91
	STA PPUADDR
	LDX #$61
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$B0
	STA PPUADDR
	LDX #$70
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$B1
	STA PPUADDR
	LDX #$71
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$92
	STA PPUADDR
	LDX #$48
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$93
	STA PPUADDR
	LDX #$49
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$B2
	STA PPUADDR
	LDX #$58
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$B3
	STA PPUADDR
	LDX #$59
	STX PPUDATA

  LDA PPUSTATUS ; over
	LDA #$21
	STA PPUADDR
	LDA #$CC
	STA PPUADDR
	LDX #$64
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$CD
	STA PPUADDR
	LDX #$65
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$EC
	STA PPUADDR
	LDX #$74
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$ED
	STA PPUADDR
	LDX #$75
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$CE
	STA PPUADDR
	LDX #$62
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$CF
	STA PPUADDR
	LDX #$63
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$EE
	STA PPUADDR
	LDX #$72
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$EF
	STA PPUADDR
	LDX #$73
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D0
	STA PPUADDR
	LDX #$48
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D1
	STA PPUADDR
	LDX #$49
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F0
	STA PPUADDR
	LDX #$58
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F1
	STA PPUADDR
	LDX #$59
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D2
	STA PPUADDR
	LDX #$4E
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$D3
	STA PPUADDR
	LDX #$4F
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F2
	STA PPUADDR
	LDX #$5E
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F3
	STA PPUADDR
	LDX #$5F
	STX PPUDATA

  LDA PPUSTATUS ; attributes
	LDA #$23
	STA PPUADDR
	LDA #$DB
	STA PPUADDR
	LDA #$00
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DC
	STA PPUADDR
	LDA #$00
	STA PPUDATA

  ;Draw again on right screen
  LDA PPUSTATUS ;game
	LDA #$25
	STA PPUADDR
	LDA #$8C
	STA PPUADDR
	LDX #$46
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$8D
	STA PPUADDR
	LDX #$47
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$AC
	STA PPUADDR
	LDX #$56
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$AD
	STA PPUADDR
	LDX #$57
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$8E
	STA PPUADDR
	LDX #$44
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$8F
	STA PPUADDR
	LDX #$45
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$AE
	STA PPUADDR
	LDX #$54
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$AF
	STA PPUADDR
	LDX #$55
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$90
	STA PPUADDR
	LDX #$60
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$91
	STA PPUADDR
	LDX #$61
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$B0
	STA PPUADDR
	LDX #$70
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$B1
	STA PPUADDR
	LDX #$71
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$92
	STA PPUADDR
	LDX #$48
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$93
	STA PPUADDR
	LDX #$49
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$B2
	STA PPUADDR
	LDX #$58
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$B3
	STA PPUADDR
	LDX #$59
	STX PPUDATA

  LDA PPUSTATUS ; over
	LDA #$25
	STA PPUADDR
	LDA #$CC
	STA PPUADDR
	LDX #$64
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$CD
	STA PPUADDR
	LDX #$65
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$EC
	STA PPUADDR
	LDX #$74
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$ED
	STA PPUADDR
	LDX #$75
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$CE
	STA PPUADDR
	LDX #$62
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$CF
	STA PPUADDR
	LDX #$63
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$EE
	STA PPUADDR
	LDX #$72
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$EF
	STA PPUADDR
	LDX #$73
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$D0
	STA PPUADDR
	LDX #$48
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$D1
	STA PPUADDR
	LDX #$49
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$F0
	STA PPUADDR
	LDX #$58
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$F1
	STA PPUADDR
	LDX #$59
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$D2
	STA PPUADDR
	LDX #$4E
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$D3
	STA PPUADDR
	LDX #$4F
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$F2
	STA PPUADDR
	LDX #$5E
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$F3
	STA PPUADDR
	LDX #$5F
	STX PPUDATA

  LDA PPUSTATUS ; attributes
	LDA #$27
	STA PPUADDR
	LDA #$DB
	STA PPUADDR
	LDA #$00
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DC
	STA PPUADDR
	LDA #$00
	STA PPUDATA

  RTS
  .endproc


.proc draw_game_won_screen
  LDA PPUSTATUS ;stage
	LDA #$25
	STA PPUADDR
	LDA #$8C
	STA PPUADDR
	LDX #$40
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$8D
	STA PPUADDR
	LDX #$41
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$AC
	STA PPUADDR
	LDX #$50
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$AD
	STA PPUADDR
	LDX #$51
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$8E
	STA PPUADDR
	LDX #$42
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$8F
	STA PPUADDR
	LDX #$43
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$AE
	STA PPUADDR
	LDX #$52
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$AF
	STA PPUADDR
	LDX #$53
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$90
	STA PPUADDR
	LDX #$44
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$91
	STA PPUADDR
	LDX #$45
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$B0
	STA PPUADDR
	LDX #$54
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$B1
	STA PPUADDR
	LDX #$55
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$92
	STA PPUADDR
	LDX #$46
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$93
	STA PPUADDR
	LDX #$47
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$B2
	STA PPUADDR
	LDX #$56
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$B3
	STA PPUADDR
	LDX #$57
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$94
	STA PPUADDR
	LDX #$48
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$95
	STA PPUADDR
	LDX #$49
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$B4
	STA PPUADDR
	LDX #$58
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$B5
	STA PPUADDR
	LDX #$59
	STX PPUDATA


  LDA PPUSTATUS ; clear
	LDA #$25
	STA PPUADDR
	LDA #$CC
	STA PPUADDR
	LDX #$4A
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$CD
	STA PPUADDR
	LDX #$4B
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$EC
	STA PPUADDR
	LDX #$5A
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$ED
	STA PPUADDR
	LDX #$5B
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$CE
	STA PPUADDR
	LDX #$4C
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$CF
	STA PPUADDR
	LDX #$4D
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$EE
	STA PPUADDR
	LDX #$5C
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$EF
	STA PPUADDR
	LDX #$5D
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$D0
	STA PPUADDR
	LDX #$48
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$D1
	STA PPUADDR
	LDX #$49
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$F0
	STA PPUADDR
	LDX #$58
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$F1
	STA PPUADDR
	LDX #$59
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$D2
	STA PPUADDR
	LDX #$44
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$D3
	STA PPUADDR
	LDX #$45
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$F2
	STA PPUADDR
	LDX #$54
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$F3
	STA PPUADDR
	LDX #$55
	STX PPUDATA


  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$D4
	STA PPUADDR
	LDX #$4E
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$D5
	STA PPUADDR
	LDX #$4F
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$F4
	STA PPUADDR
	LDX #$5E
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$25
	STA PPUADDR
	LDA #$F5
	STA PPUADDR
	LDX #$5F
	STX PPUDATA


  LDA PPUSTATUS ; attributes
	LDA #$27
	STA PPUADDR
	LDA #$DB
	STA PPUADDR
	LDA #$FF
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DC
	STA PPUADDR
	LDA #$FF
	STA PPUDATA
  
  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$DD
	STA PPUADDR
	LDA #%01110011
	STA PPUDATA

  RTS
  .endproc

.proc update_police1
  police1_check_right:
  LDA police1_dir
  CMP #%01
  BNE police1_check_left
  LDA police1_x
  CMP police1_x_right
  BNE police1_move_right
  LDA #%00
  STA police1_dir
  JMP police1_move_down

  police1_check_left:
  LDA police1_dir
  CMP #%10
  BNE police1_check_up
  LDA police1_x
  CMP police1_x_left
  BNE police1_move_left
  LDA #%11
  STA police1_dir
  JMP police1_move_up

  police1_check_up:
  LDA police1_dir
  CMP #%11
  BNE police1_check_down
  LDA police1_y
  CMP police1_y_up
  BNE police1_move_up
  LDA #%01
  STA police1_dir
  JMP police1_move_right

  police1_check_down:
  LDA police1_dir
  CMP #%00
  BNE police1_check_right
  LDA police1_y
  CMP police1_y_down
  BNE police1_move_down1
  LDA #%10
  STA police1_dir
  JMP police1_move_left

  police1_move_right:
    INC police1_x
    LDA anim_state
    CMP #%00
    BEQ police1_r1
    CMP #%01
    BEQ police1_r2
    CMP #%10
    BEQ police1_r3
    CMP #%11
    BEQ police1_r4
    police1_r1:
      JSR draw_police1_right1
      JMP exit_update_police1
    police1_r2:
      JSR draw_police1_right2
      JMP exit_update_police1
    police1_r3:
      JSR draw_police1_right1
      JMP exit_update_police1
    police1_r4:
      JSR draw_police1_right4
      JMP exit_update_police1


  police1_move_left:
    DEC police1_x
    LDA anim_state
    CMP #%00
    BEQ police1_l1
    CMP #%01
    BEQ police1_l2
    CMP #%10
    BEQ police1_l3
    CMP #%11
    BEQ police1_l4
    police1_l1:
      JSR draw_police1_left1
      JMP exit_update_police1
    police1_l2:
      JSR draw_police1_left2
      JMP exit_update_police1
    police1_l3:
      JSR draw_police1_left1
      JMP exit_update_police1
    police1_l4:
      JSR draw_police1_left4
      JMP exit_update_police1
  police1_move_down1:
    JMP police1_move_down
  police1_move_up:
    DEC police1_y
    LDA anim_state
    CMP #%00
    BEQ police1_u1
    CMP #%01
    BEQ police1_u2
    CMP #%10
    BEQ police1_u3
    CMP #%11
    BEQ police1_u4
    police1_u1:
      JSR draw_police1_up1
      JMP exit_update_police1
    police1_u2:
      JSR draw_police1_up2
      JMP exit_update_police1
    police1_u3:
      JSR draw_police1_up1
      JMP exit_update_police1
    police1_u4:
      JSR draw_police1_up4
      JMP exit_update_police1
  police1_move_down:
  INC police1_y
  LDA anim_state
  CMP #%00
  BEQ police1_d1
  CMP #%01
  BEQ police1_d2
  CMP #%10
  BEQ police1_d3
  CMP #%11
  BEQ police1_d4
  police1_d1:
    JSR draw_police1_down1
    JMP exit_update_police1
  police1_d2:
    JSR draw_police1_down2
    JMP exit_update_police1
  police1_d3:
    JSR draw_police1_down1
    JMP exit_update_police1
  police1_d4:
    JSR draw_police1_down4
    JMP exit_update_police1
  exit_update_police1:
  RTS
  .endproc

.proc update_police2
    police2_check_right:
  LDA police2_dir
  CMP #%01
  BNE police2_check_left
  LDA police2_x
  CMP police2_x_right
  BNE police2_move_right
  LDA #%00
  STA police2_dir
  JMP police2_move_down

  police2_check_left:
  LDA police2_dir
  CMP #%10
  BNE police2_check_up
  LDA police2_x
  CMP police2_x_left
  BNE police2_move_left
  LDA #%11
  STA police2_dir
  JMP police2_move_up

  police2_check_up:
  LDA police2_dir
  CMP #%11
  BNE police2_check_down
  LDA police2_y
  CMP police2_y_up
  BNE police2_move_up
  LDA #%01
  STA police2_dir
  JMP police2_move_right

  police2_check_down:
  LDA police2_dir
  CMP #%00
  BNE police2_check_right
  LDA police2_y
  CMP police2_y_down
  BNE police2_move_down1
  LDA #%10
  STA police2_dir
  JMP police2_move_left

  police2_move_right:
    INC police2_x
    LDA anim_state
    CMP #%00
    BEQ police2_r1
    CMP #%01
    BEQ police2_r2
    CMP #%10
    BEQ police2_r3
    CMP #%11
    BEQ police2_r4
    police2_r1:
      JSR draw_police2_right1
      JMP exit_update_police2
    police2_r2:
      JSR draw_police2_right2
      JMP exit_update_police2
    police2_r3:
      JSR draw_police2_right1
      JMP exit_update_police2
    police2_r4:
      JSR draw_police2_right4
      JMP exit_update_police2


  police2_move_left:
    DEC police2_x
    LDA anim_state
    CMP #%00
    BEQ police2_l1
    CMP #%01
    BEQ police2_l2
    CMP #%10
    BEQ police2_l3
    CMP #%11
    BEQ police2_l4
    police2_l1:
      JSR draw_police2_left1
      JMP exit_update_police2
    police2_l2:
      JSR draw_police2_left2
      JMP exit_update_police2
    police2_l3:
      JSR draw_police2_left1
      JMP exit_update_police2
    police2_l4:
      JSR draw_police2_left4
      JMP exit_update_police2
  police2_move_down1:
    JMP police2_move_down
  police2_move_up:
    DEC police2_y
    LDA anim_state
    CMP #%00
    BEQ police2_u1
    CMP #%01
    BEQ police2_u2
    CMP #%10
    BEQ police2_u3
    CMP #%11
    BEQ police2_u4
    police2_u1:
      JSR draw_police2_up1
      JMP exit_update_police2
    police2_u2:
      JSR draw_police2_up2
      JMP exit_update_police2
    police2_u3:
      JSR draw_police2_up1
      JMP exit_update_police2
    police2_u4:
      JSR draw_police2_up4
      JMP exit_update_police2
  police2_move_down:
  INC police2_y
  LDA anim_state
  CMP #%00
  BEQ police2_d1
  CMP #%01
  BEQ police2_d2
  CMP #%10
  BEQ police2_d3
  CMP #%11
  BEQ police2_d4
  police2_d1:
    JSR draw_police2_down1
    JMP exit_update_police2
  police2_d2:
    JSR draw_police2_down2
    JMP exit_update_police2
  police2_d3:
    JSR draw_police2_down1
    JMP exit_update_police2
  police2_d4:
    JSR draw_police2_down4
    JMP exit_update_police2
  exit_update_police2:
  RTS
  .endproc
.proc draw_police1_right1
  ; write police tile numbers
  LDA #$24
  STA $0231
  LDA #$25
  STA $0235
  LDA #$34
  STA $0239
  LDA #$35
  STA $023d


  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc
.proc draw_police1_right2
  ; write police tile numbers
  LDA #$26
  STA $0231
  LDA #$27
  STA $0235
  LDA #$36
  STA $0239
  LDA #$37
  STA $023d


  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc
.proc draw_police1_right4
  ; write police tile numbers
  LDA #$28
  STA $0231
  LDA #$29
  STA $0235
  LDA #$38
  STA $0239
  LDA #$39
  STA $023d


  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc

.proc draw_police1_down1
  ; write police tile numbers
  LDA #$20
  STA $0231
  LDA #$21
  STA $0235
  LDA #$30
  STA $0239
  LDA #$31
  STA $023d


  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc

.proc draw_police1_down2
  ; write police tile numbers
  LDA #$22
  STA $0231
  LDA #$23
  STA $0235
  LDA #$32
  STA $0239
  LDA #$33
  STA $023d


  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc

.proc draw_police1_down4
  ; write police tile numbers
  LDA #$C0
  STA $0231
  LDA #$C1
  STA $0235
  LDA #$D0
  STA $0239
  LDA #$D1
  STA $023d


  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc

.proc draw_police1_up1
  ; write police tile numbers
  LDA #$2A
  STA $0231
  LDA #$2B
  STA $0235
  LDA #$3A
  STA $0239
  LDA #$3B
  STA $023d


  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc

.proc draw_police1_up2
  ; write police tile numbers
  LDA #$2C
  STA $0231
  LDA #$2D
  STA $0235
  LDA #$3C
  STA $0239
  LDA #$3D
  STA $023d

  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc

.proc draw_police1_up4
  ; write police tile numbers
  LDA #$C2
  STA $0231
  LDA #$C3
  STA $0235
  LDA #$D2
  STA $0239
  LDA #$D3
  STA $023d


  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc

.proc draw_police1_left1
  ; write police tile numbers
  LDA #$4A
  STA $0231
  LDA #$4B
  STA $0235
  LDA #$5A
  STA $0239
  LDA #$5B
  STA $023d


  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc

.proc draw_police1_left2
  ; write police tile numbers
  LDA #$4C
  STA $0231
  LDA #$4D
  STA $0235
  LDA #$5C
  STA $0239
  LDA #$5D
  STA $023d


  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc

.proc draw_police1_left4
  ; write police tile numbers
  LDA #$4E
  STA $0231
  LDA #$4F
  STA $0235
  LDA #$5E
  STA $0239
  LDA #$5F
  STA $023d


  ; store tile locations
  ; top left tile:
  LDA police1_y
  STA $0230
  LDA police1_x
  STA $0233

  ; top right tile (x + 8):
  LDA police1_y
  STA $0234
  LDA police1_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA police1_y
  CLC
  ADC #$08
  STA $0238
  LDA police1_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA police1_y
  CLC
  ADC #$08
  STA $023c
  LDA police1_x
  CLC
  ADC #$08
  STA $023f
  RTS
  .endproc

.proc draw_police2_right1
  ; write police tile numbers
  LDA #$24
  STA $0241
  LDA #$25
  STA $0245
  LDA #$34
  STA $0249
  LDA #$35
  STA $024d


  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc
.proc draw_police2_right2
  ; write police tile numbers
  LDA #$26
  STA $0241
  LDA #$27
  STA $0245
  LDA #$36
  STA $0249
  LDA #$37
  STA $024d


  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc
.proc draw_police2_right4
  ; write police tile numbers
  LDA #$28
  STA $0241
  LDA #$29
  STA $0245
  LDA #$38
  STA $0249
  LDA #$39
  STA $024d


  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc

.proc draw_police2_down1
  ; write police tile numbers
  LDA #$20
  STA $0241
  LDA #$21
  STA $0245
  LDA #$30
  STA $0249
  LDA #$31
  STA $024d


  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc

.proc draw_police2_down2
  ; write police tile numbers
  LDA #$22
  STA $0241
  LDA #$23
  STA $0245
  LDA #$32
  STA $0249
  LDA #$33
  STA $024d


  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc

.proc draw_police2_down4
  ; write police tile numbers
  LDA #$C0
  STA $0241
  LDA #$C1
  STA $0245
  LDA #$D0
  STA $0249
  LDA #$D1
  STA $024d


  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc

.proc draw_police2_up1
  ; write police tile numbers
  LDA #$2A
  STA $0241
  LDA #$2B
  STA $0245
  LDA #$3A
  STA $0249
  LDA #$3B
  STA $024d


  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc

.proc draw_police2_up2
  ; write police tile numbers
  LDA #$2C
  STA $0241
  LDA #$2D
  STA $0245
  LDA #$3C
  STA $0249
  LDA #$3D
  STA $024d

  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc

.proc draw_police2_up4
  ; write police tile numbers
  LDA #$C2
  STA $0241
  LDA #$C3
  STA $0245
  LDA #$D2
  STA $0249
  LDA #$D3
  STA $024d


  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc

.proc draw_police2_left1
  ; write police tile numbers
  LDA #$4A
  STA $0241
  LDA #$4B
  STA $0245
  LDA #$5A
  STA $0249
  LDA #$5B
  STA $024d


  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc

.proc draw_police2_left2
  ; write police tile numbers
  LDA #$4C
  STA $0241
  LDA #$4D
  STA $0245
  LDA #$5C
  STA $0249
  LDA #$5D
  STA $024d


  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc

.proc draw_police2_left4
  ; write police tile numbers
  LDA #$4E
  STA $0241
  LDA #$4F
  STA $0245
  LDA #$5E
  STA $0249
  LDA #$5F
  STA $024d


  ; store tile locations
  ; top left tile:
  LDA police2_y
  STA $0240
  LDA police2_x
  STA $0243

  ; top right tile (x + 8):
  LDA police2_y
  STA $0244
  LDA police2_x
  CLC
  ADC #$08
  STA $0247

  ; bottom left tile (y + 8):
  LDA police2_y
  CLC
  ADC #$08
  STA $0248
  LDA police2_x
  STA $024b

  ; bottom right tile (x + 8, y + 8)
  LDA police2_y
  CLC
  ADC #$08
  STA $024c
  LDA police2_x
  CLC
  ADC #$08
  STA $024f
  RTS
  .endproc

.proc verify_caught
  LDA police1_y
  LSR
  LSR
  LSR
  LSR
  CLC
  ADC #2
  CMP tile_y
  BNE check_police2
  LDA police1_x
  CLC
  ADC #1
  LSR
  LSR
  LSR
  LSR
  CMP tile_x
  BNE check_police2
  LDA #$F0
  STA stage
  RTS
  check_police2:
  LDA police2_x
  CLC
  ADC #1
  LSR
  LSR
  LSR
  LSR
  CMP tile_x
  BNE exit_verify_caught
  LDA police2_y
  LSR
  LSR
  AND #%11111100
  LSR
  LSR
  CLC
  ADC #2
  CMP tile_y
  BNE exit_verify_caught
  LDA #$F0
  STA stage
  exit_verify_caught:
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

background2L:
.byte $FF, $FF, $FF, $FF
.byte $DC, $00, $02, $A0
.byte $CC, $FC, $FC, $FB
.byte $CC, $FC, $00, $FB
.byte $CC, $FC, $EC, $A3
.byte $CC, $A8, $EC, $F3
.byte $CC, $FC, $A8, $33
.byte $C8, $00, $C8, $03
.byte $CC, $FF, $EF, $F3
.byte $CC, $FC, $00, $03
.byte $CC, $F0, $EF, $F3
.byte $CC, $C3, $EF, $F3
.byte $CC, $CF, $EF, $F3
.byte $C0, $00, $00, $03
.byte $FF, $FF, $FF, $FF

background2R:
.byte $FF, $FF, $FF, $FF
.byte $00, $30, $30, $03
.byte $CF, $33, $03, $B3
.byte $CF, $03, $CC, $03
.byte $CF, $3B, $CC, $F3
.byte $C0, $08, $08, $A3
.byte $FF, $EF, $FC, $F3
.byte $C0, $02, $A8, $03
.byte $CF, $B3, $FC, $FB
.byte $CF, $B3, $FC, $FB
.byte $C0, $00, $00, $0B
.byte $CF, $3F, $EF, $FB
.byte $CF, $3F, $EF, $F3
.byte $C0, $00, $02, $87
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
.byte $3D, $0F, $01, $37
.byte $3D, $0B, $1A, $29

.segment "CHR"
.incbin "starfield.chr"