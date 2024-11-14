.include "m328pdef.inc"

.equ NS_GRE_ON = (1<<PD1)
.equ NS_YEL_ON = (1<<PD2)
.equ NS_RED_ON = (1<<PD3)

.equ EW_GRE_ON = (1<<PD4)
.equ EW_YEL_ON = (1<<PD5)
.equ EW_RED_ON = (1<<PD6)

.org 0
	rjmp start

start:
	LDI R16, low(RAMEND) ; Initialize Stack Pointer
	OUT SPL,R16
	LDI R16, high (RAMEND)
	OUT SPH, R16
	LDI R16, NS_GRE_ON | NS_YEL_ON | NS_RED_ON | EW_GRE_ON | EW_YEL_ON | EW_RED_ON
	OUT DDRD,R16 ; I/O mapped (see m328pdef.inc)

driver:
	rcall r_und_g
	rcall mydelay

	rcall r_und_y
	rcall mydelay

	rcall g_und_r
	rcall mydelay

	rcall y_und_r
	rcall mydelay

	rjmp driver

// The following subroutines are structure as followed:
//		NsLight_und_EwLight
r_und_g:
	ldi r16, NS_RED_ON | EW_GRE_ON
	out portD, r16
	ret

r_und_y:
	ldi r16, NS_RED_ON | EW_YEL_ON
	out portD, r16
	ret

g_und_r:
	ldi r16, NS_GRE_ON | EW_RED_ON 
	out portD, r16
	ret

y_und_r:
	ldi r16, NS_YEL_ON | EW_RED_ON
	out portD, r16
	ret

mydelay:
	ldi r17,0xFF ;outer loop
L2: ldi r18,0xFF ;middle loop
L3: ldi r19,0xFF ;inner loop
L4: dec r19 ;
	brne L4
L5: dec r18
	brne L3
	dec r17
	brne L2
	ret

done:
	rjmp done