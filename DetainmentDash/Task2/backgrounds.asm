.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir: .res 1
anim_state_counter: .res 1
anim_state: .res 1
.exportzp player_x, player_y, player_dir

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
  ; update tiles *after* DMA transfer
  JSR increment_anim_state_counter
  JSR update_player
	STA $2005
	STA $2005
  RTI
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

.import reset_handler

.export main
.proc main
  LDA #$00
  STA anim_state_counter
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
  CPX #$04
  BNE load_sprites

; write nametables

; attribute tables

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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
  ; LDA #%01000001
  LDA #$03
  STA $0205
  LDA #$12
  STA $0209
  LDA #$13
  STA $020d

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #%01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e

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
  check_right:
  LDA player_dir
  CMP #%01
  BNE check_left
  LDA player_x
  CMP #$e0
  BNE move_right
  LDA #%00
  STA player_dir
  JMP move_down

  check_left:
  LDA player_dir
  CMP #%10
  BNE check_up
  LDA player_x
  CMP #$10
  BNE move_left
  LDA #%11
  STA player_dir
  JMP move_up

  check_up:
  LDA player_dir
  CMP #%11
  BNE check_down
  LDA player_y
  CMP #$10
  BNE move_up
  LDA #%01
  STA player_dir
  JMP move_right

  check_down:
  LDA player_dir
  CMP #%00
  BNE check_right
  LDA player_y
  CMP #$d0
  BNE move_down1
  LDA #%10
  STA player_dir
  JMP move_left

move_right:
  INC player_x
  LDA anim_state
  CMP #%00
  BEQ r1
  CMP #%01
  BEQ r2
  CMP #%10
  BEQ r3
  CMP #%11
  BEQ r4
  r1:
    JSR draw_player_right1
    JMP exit_subroutine
  r2:
    JSR draw_player_right2
    JMP exit_subroutine
  r3:
    JSR draw_player_right3
    JMP exit_subroutine
  r4:
    JSR draw_player_right4
    JMP exit_subroutine


move_left:
  DEC player_x
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
    JMP exit_subroutine
  l2:
    JSR draw_player_left2
    JMP exit_subroutine
  l3:
    JSR draw_player_left3
    JMP exit_subroutine
  l4:
    JSR draw_player_left4
    JMP exit_subroutine
move_down1:
  JMP move_down
move_up:
  DEC player_y
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
    JMP exit_subroutine
  u2:
    JSR draw_player_up2
    JMP exit_subroutine
  u3:
    JSR draw_player_up3
    JMP exit_subroutine
  u4:
    JSR draw_player_up4
    JMP exit_subroutine
move_down:
  INC player_y
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
    JMP exit_subroutine
  d2:
    JSR draw_player_down2
    JMP exit_subroutine
  d3:
    JSR draw_player_down3
    JMP exit_subroutine
  d4:
    JSR draw_player_down4
    JMP exit_subroutine
exit_subroutine:
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $3D, $00, $0F, $30
.byte $3D, $27, $0F, $37
.byte $3D, $0F, $11, $37
.byte $3D, $05, $05, $16

.byte $3D, $00, $0F, $30
.byte $3D, $27, $0F, $37
.byte $3D, $0F, $11, $37
.byte $3D, $05, $05, $16

sprites:
; prisoner front1
.byte $40, $02, $01, $40
.byte $40, $03, $01, $48
.byte $48, $12, $01, $40
.byte $48, $13, $01, $48

.byte $40, $04, $01, $40
.byte $40, $05, $01, $48
.byte $48, $14, $01, $40
.byte $48, $15, $01, $48



.segment "CHR"
.incbin "starfield.chr"
