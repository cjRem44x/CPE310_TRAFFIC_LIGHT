;==============================================================================
; Project:       Traffic Light Controller
; Processor:     ATmega328P
; Frequency:     16MHz
; 
; Description:   Educational implementation of a traffic light controller
;               demonstrating basic embedded systems concepts. Controls two
;               intersecting traffic signals (NS and EW) with appropriate
;               timing and safety delays.
;
; Register Usage:
;   R16 - General purpose I/O operations and port configuration
;   R17 - Outer delay loop counter
;   R18 - Middle delay loop counter
;   R19 - Inner delay loop counter
;
; Authors:       Carrick Remillard, David Dag
; Course:        CPE310 - Microprocessors I 
; Created:       2023
; Updated:       2024
; 
; Copyright (C) 2025 Carrick Remillard, David Dag  
; Licensed under the GNU General Public License v3 (GPLv3) 
;==============================================================================

.include "m328pdef.inc"

;==============================================================================
; Pin Configuration Constants
;==============================================================================
; North-South Traffic Light Pins (Port D)
.equ NS_GRE_ON = (1<<PD1)  ; Green light - Pin D1
.equ NS_YEL_ON = (1<<PD2)  ; Yellow light - Pin D2
.equ NS_RED_ON = (1<<PD3)  ; Red light - Pin D3

; East-West Traffic Light Pins (Port D)
.equ EW_GRE_ON = (1<<PD4)  ; Green light - Pin D4
.equ EW_YEL_ON = (1<<PD5)  ; Yellow light - Pin D5
.equ EW_RED_ON = (1<<PD6)  ; Red light - Pin D6

;==============================================================================
; Reset Vector
;==============================================================================
.org 0
    rjmp start  ; Jump to start routine at program reset

;==============================================================================
; Initialization
;==============================================================================
start:
    ; Initialize stack pointer to end of RAM
    LDI R16, low(RAMEND)    ; Load low byte of stack address
    OUT SPL, R16            ; Set Stack Pointer Low byte
    LDI R16, high(RAMEND)   ; Load high byte of stack address
    OUT SPH, R16            ; Set Stack Pointer High byte
    
    ; Configure all traffic light pins as outputs
    LDI R16, NS_GRE_ON | NS_YEL_ON | NS_RED_ON | EW_GRE_ON | EW_YEL_ON | EW_RED_ON
    OUT DDRD, R16           ; Set direction register

;==============================================================================
; Main Control Loop
;==============================================================================
driver:
    ; Complete traffic light cycle sequence
    rcall r_und_g           ; NS Red, EW Green (main green phase)
    rcall green_delay       ; Longer delay for green light
    
    rcall r_und_y           ; NS Red, EW Yellow (warning phase)
    rcall def_delay         ; Standard delay for yellow
    
    rcall r_und_r           ; All Red (safety phase)
    rcall def_delay         ; Safety delay
    
    ; Repeat sequence for other direction
    rcall g_und_r           ; NS Green, EW Red
    rcall green_delay       ; Main green phase
    
    rcall y_und_r           ; NS Yellow, EW Red
    rcall def_delay         ; Warning phase
    
    rcall r_und_r           ; All Red (safety phase)
    rcall def_delay         ; Safety delay
    
    rjmp driver             ; Repeat cycle indefinitely

;==============================================================================
; Traffic Light State Subroutines
;==============================================================================
; NS Red, EW Green
r_und_g:
    ldi r16, NS_RED_ON | EW_GRE_ON  ; Set NS Red, EW Green
    out portD, r16                   ; Output to Port D
    ret

; NS Red, EW Yellow
r_und_y:
    ldi r16, NS_RED_ON | EW_YEL_ON  ; Set NS Red, EW Yellow
    out portD, r16                   ; Output to Port D
    ret

; NS Green, EW Red
g_und_r:
    ldi r16, NS_GRE_ON | EW_RED_ON  ; Set NS Green, EW Red
    out portD, r16                   ; Output to Port D
    ret

; NS Yellow, EW Red
y_und_r:
    ldi r16, NS_YEL_ON | EW_RED_ON  ; Set NS Yellow, EW Red
    out portD, r16                   ; Output to Port D
    ret

; NS Red, EW Red
r_und_r:
    ldi r16, NS_RED_ON | EW_RED_ON   ; Set NS RED, EW Red
    out portD, r16                   ; Output to Port D
    ret

;==============================================================================
; Timing Delay Subroutines
;==============================================================================
green_delay:                ; Longer delay for green light phase
    ldi r17, 0xFF          ; Maximum outer loop count
A2: ldi r18, 0xFF          ; Middle loop initialization
A3: ldi r19, 0xFF          ; Inner loop initialization
A4: dec r19                ; Decrement inner counter
    brne A4                ; Continue inner loop if not zero
A5: dec r18                ; Decrement middle counter
    brne A3                ; Continue middle loop if not zero
    dec r17                ; Decrement outer counter
    brne A2                ; Continue outer loop if not zero
    ret                    ; Return from subroutine

def_delay:                 ; Standard delay for yellow/safety phases
    ldi r17, 0x52          ; Shorter outer loop count
L2: ldi r18, 0xFF          ; Middle loop initialization
L3: ldi r19, 0xFF          ; Inner loop initialization
L4: dec r19                ; Decrement inner counter
    brne L4                ; Continue inner loop if not zero
L5: dec r18                ; Decrement middle counter
    brne L3                ; Continue middle loop if not zero
    dec r17                ; Decrement outer counter
    brne L2                ; Continue outer loop if not zero
    ret                    ; Return from subroutine

;==============================================================================
; Program Termination
;==============================================================================
done:
    rjmp done              ; Safety infinite loop
