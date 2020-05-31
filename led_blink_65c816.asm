; LED Blink - by Michael Kohn
; http://www.mikekohn.net/micro/modern_6502.php
;
; LICENSE: GPL-2.0 because of the original license from Mike Kohn

; Extended by Karl Matthias May 31, 2020 to support external LEDs on Port 0 and
; an extended blink of all the LEDs on the board.
; https://relistan.com/wdc-w65c265-mensch-hello-world

.65816
.org 0x00b6

; Control register
.define BCR0	0xdf40

; Data direction registers
.define PDD0	0xdf04

; Data registers
.define PD0		0xdf00
.define PD7		0xdf23

; Port 7 Chip Select
.define PCS7	0xdf27

start:
  ; Disable interrupts to protect from ROM routines running
  sei

  ; Set native mode
  clc
  xce

  ; Set A to 8-bit
  sep #0x20

  ; Set X/Y to 16-bit
  rep #0x10

main:
  ;; Port7 doesn't have a data direction register since it's always 
  ;; output (chip select). But we have to put it under manual control
  ;; to use it for LED blinking.
  lda.b #0x00
  sta PCS7 ;; PCS to manual output for Port 7

  ;; To use pins as I/O instead of address and data bus. The board
  ;; initializes with them as address pins. The control register
  ;; allows us to take manual control.
  lda.b #0x00
  sta BCR0

  ;; Setup for external LED
  lda.b #0xff
  sta PDD0	

blink:
  ;; External LEDs flip
  lda.b #0x55
  sta PD0

  ;; LED flip
  lda.b #0xaa
  sta PD7
  jsr delay

  ;; External LEDs flip
  lda.b #0xaa
  sta PD0
 
  ;; LED flip
  lda.b #0x55
  sta PD7
  jsr delay

  jmp blink

delay:
  ldy #0x55
delay_outer:
  ldx #0x1000
delay_inner:
  dex
  bne delay_inner
  dey
  bne delay_outer
  rts
