;	CPE310:			TRAFFIC LIGHT CODE
;
;	Authors:		Carrick Remillard, David Dag
;	Description:	TODO
;

.include "m328pdef.inc"
.org 0
	rjmp MAIN

MAIN:
	; Set up stack pointer
	ldi r16, low(RAMEND)
	out spl, r16
	ldi r16, high(RAMEND)
	out sph, r16

	; Configure PD5, PD6, and PD7 as outputs
	ldi r16, (1<<PD7) | (1<<PD6) | (1<<PD5)
	out DDRD, r16

TEST:
	LDI R16, (1<<PD5)
	OUT portD, R16
	CALL DELAY

	LDI R16, ~(1<<PD5)
	OUT portD, R16
	RCALL DELAY

	rjmp TEST

DELAY:
	LDI r17, 0x52	; Delay time
L2: LDI r18, 0xFF
L3: LDI r19, 0xFF

L4: DEC r19
	BRNE L4

	DEC r18
	BRNE L3

	DEC r17
	BRNE L2
	RET

DONE:
	jmp DONE
