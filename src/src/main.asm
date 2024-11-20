;
;	CPE310:			Traffic Light Project Code
;
;	Authors:		Carrick Remillard, David Dag
;
;	Description:	ATmega328P assembly code to control a traffic 
;					light system with NS (North-South) and EW (East
;					-West) traffic signals using delays to simulate 
;					light changes.  
;

.include "m328pdef.inc"

; ==============================
; Defined Constants and Pin Mapping  
; ==============================
.equ NS_GRE_ON = (1<<PD1)  ; North-South Green Light on PD1
.equ NS_YEL_ON = (1<<PD2)  ; North-South Yellow Light on PD2
.equ NS_RED_ON = (1<<PD3)  ; North-South Red Light on PD3

.equ EW_GRE_ON = (1<<PD4)  ; East-West Green Light on PD4
.equ EW_YEL_ON = (1<<PD5)  ; East-West Yellow Light on PD5
.equ EW_RED_ON = (1<<PD6)  ; East-West Red Light on PD6

; ==============================
; Start - Program Initialization
; ==============================
.org 0
	rjmp start  ; Jump to start routine at program reset

start:
	; Initialize the Stack Pointer
	LDI R16, low(RAMEND)    ; Load the low byte of RAMEND into R16
	OUT SPL, R16            ; Set low byte of Stack Pointer
	LDI R16, high(RAMEND)   ; Load the high byte of RAMEND into R16
	OUT SPH, R16            ; Set high byte of Stack Pointer
	
	; Configure Port D pins as outputs for traffic lights
	LDI R16, NS_GRE_ON | NS_YEL_ON | NS_RED_ON | EW_GRE_ON | EW_YEL_ON | EW_RED_ON
	OUT DDRD, R16           ; Set Port D as output for traffic light control

; ==============================
; Main Traffic Light Control Loop
; ==============================
driver:
	rcall r_und_r			; Call subroutine for NS Red, EW RED
	rcall def_delay 

	rcall r_und_g           ; Call subroutine for NS Red, EW Green
	rcall green_delay           
	
	rcall r_und_y           ; Call subroutine for NS Red, EW Yellow
	rcall def_delay           

	rcall g_und_r           ; Call subroutine for NS Green, EW Red
	rcall green_delay           
	
	rcall y_und_r           ; Call subroutine for NS Yellow, EW Red
	rcall def_delay          
	
	rjmp driver             ; Repeat the sequence indefinitely

; ==============================
; Traffic Light State Subroutines
; Naming Convention: NsLight_und_EwLight
; ==============================

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

; ==============================
; Delay Subroutine
; ==============================
green_delay:
	ldi r17, 0xFF
A2: ldi r18, 0xFF        
A3: ldi r19, 0xFF        
A4: dec r19              
	brne L4               
A5: dec r18              
	brne L3               
	dec r17               
	brne L2               
	ret  

def_delay:
	ldi r17, 0x52
L2: ldi r18, 0xFF        
L3: ldi r19, 0xFF        
L4: dec r19              
	brne L4               
L5: dec r18              
	brne L3               
	dec r17               
	brne L2               
	ret                  

; ==============================
; End - Infinite Loop to Halt Program Execution
; ==============================
done:
	rjmp done             ; Infinite loop to halt execution