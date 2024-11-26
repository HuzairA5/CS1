; ------ CS1 ASSIGNMENT ------

; declaring symbols
.equ SREG,  0x3F    ; Status register

.equ DDRD,  0x0A    ; Data Direction Register D
.equ PORTD, 0x0B    ; Output port for PORTD

.equ DDRB,  0x04    ; Data Direction Register B
.equ PORTB, 0x05    ; Output port for PORTB

.org 0		; set start address

main:
	; clear Status Register
	ldi r16, 0
	out SREG, r16	; SREG set to 0

	; set lower nybble of port B to output mode
	ldi r16, 0x0F   ; set r16 to 0000 1111
	out DDRB, r16

	; set upper nybble of port D to output mode
	ldi r16, 0xF0   ; set r16 to 1111 0000
	out DDRD, r16

	; initialize iteration counter (r18) to 1
	ldi r18, 1	; r18 will hold the current iteration number (1-50)
	
	; Initialize modulo 5 counter (r19) to 1
	ldi r19, 1	; r19 will count iterations modulo 5


; 	====== (1) DISPLAY K-NUMBER ======
; 	My k-number:	k24000650

	; Display digit 2
	ldi r17, 0x02		; Load digit 2 into r17
	call display_value
	call delay_one_second

	; Display digit 4
	ldi r17, 0x04
	call display_value
	call delay_one_second

	; Display digit 0
	ldi r17, 0
	call display_value
	call delay_one_second

	; Repeat for the remaining digits
	ldi r17, 0	
	call display_value
    	call delay_one_second

	ldi r17, 0
	call display_value
	call delay_one_second

	ldi r17, 0x06
	call display_value
	call delay_one_second

	ldi r17, 0x05
	call display_value	
	call delay_one_second

	ldi r17, 0	
	call display_value
	call delay_one_second


; 	====== (2) DISPLAY INITIALS ======
; 	Name: Al-Huzair Ali (Initals: A.A)

	; Display 'A' (1)
	ldi r17, 0x01
	call display_value
	call delay_one_second

	; Display '.' (27)
	ldi r17, 0x1B
	call display_value
	call delay_one_second
	
	; Display 'A' (1)
	ldi r17, 0x01
	call display_value
	call delay_one_second


; ===== (3) DISPLAY MORSE CODE / ODD, EVEN MODULO 5 (one unit = 200ms, three units = 600ms) =====
; Letter sequence: ALH
; GENERATIVE AI was used to help with the command usage and making the right checks in order

loop2:
	; check if iteration counter (r18) == 51
	cpi r18, 51		; compare r18 with 51
	brne continue_loop	; if r18 != 51, continue
	rjmp mainloop		; if r18 == 51, end this program

continue_loop:
	; check if iteration is even or odd
	; we use the ANDI instruction to check the least significant bit (LSB)
	mov r20, r18		; Copy iteration counter to r20 for manipulation
	andi r20, 0x01		; AND with 0x01 to isolate LSB
	breq even_iteration	; If zero (LSB=0), it's even
	; Else, it's odd
	rjmp odd_iteration

even_iteration:
	; Even iteration: Display letters in reverse order (H, L, A)

	; Display Morse code for 'H' (dot, dot, dot, dot)
	call dot
	call delay_200ms	; space between parts
	call dot
	call delay_200ms
	call dot
	call delay_200ms
	call dot
	call delay_600ms

	; Display Morse code for 'L' (dot, dash, dot, dot)
	call dot
	call delay_200ms	; space between parts
	call dash
	call delay_200ms
	call dot
	call delay_200ms
	call dot
	call delay_600ms	; space between letters	

	; Display Morse code for 'A' (dot, dash)
	call dot
	call delay_200ms	; space between parts of the same letter (200ms)
	call dash
	call delay_600ms	; space between letters (600ms)

	rjmp check_divisible_by_5
	
odd_iteration:
	; Odd iteration: Display letters in normal order (A, L, H)
   
	; Display Morse code for 'A' (dot, dash)
	call dot
	call delay_200ms	; space between parts of the same letter (200ms)
	call dash
	call delay_600ms	; space between letters (600ms)

	; Display Morse code for 'L' (dot, dash, dot, dot)
	call dot
	call delay_200ms	; space between parts
	call dash
	call delay_200ms
	call dot
	call delay_200ms
	call dot
	call delay_600ms	; space between letters

	; Display Morse code for 'H' (dot, dot, dot, dot)
	call dot
	call delay_200ms	; space between parts
	call dot
	call delay_200ms
	call dot
	call delay_200ms
	call dot
	call delay_600ms

check_divisible_by_5:
	; check if iteration is divisible by 5
	cpi r19, 5        ; compare modulo 5 counter with 5
	brne skip_display_5
	; if equal, display '5' (dot, dot, dot, dot, dot) and reset modulo 5 counter
	call dot
	call delay_200ms	; space between parts
	call dot
	call delay_200ms
	call dot
	call delay_200ms
	call dot
	call delay_200ms
	call dot
	call delay_1400ms	; space between words

	ldi r19, 0        ; reset modulo 5 counter

skip_display_5:
	; Increment modulo 5 counter
	inc r19           ; r19 = r19 + 1

	; space between words (7 units -> 1400 ms OFF)	
	call delay_1400ms

	; increment iteration counter
	inc r18           ; r18 = r18 + 1

	; jump back to the start of the loop
	rjmp loop2

mainloop:
;	====== (4) PING-PONG ======
;	GENERATIVE AI was used to help change directions

	; initialize ping-pong pattern
	ping_pong_init:
	; initialize the value to display
	ldi r17, 0x08     ; Starting with bit 3 set

	; initialize direction flag
	; if (r18 == 0), it's shifting to the right
	; if (r18 == 1), it's shifting to the left
	ldi r18, 0        ; Direction = 0 (moving right)

ping_pong_loop:
	
	; Display value on LEDs

	; output lower 4 bits to PORTB
	mov r16, r17
	andi r16, 0x0F		; mask lower nybble
	out PORTB, r16

	; output upper 4 bits to PORTD
	mov r16, r17
	andi r16, 0xF0		; mask upper nybble
	out PORTD, r16

	call delay_200ms

	; check direction
	cpi r18, 0		; is direction == 0 (moving right)?
	brne move_left		; if not, move left

	; Moving right
	; check if value == 0x01 (at the edge / bit 0)
	cpi r17, 0x01
	brne shift_right
	; if value == 0x01, change direction to left and shift left
	ldi r18, 1		; set direction == 1 (moving left)
	lsl r17			; shift left to move back
	rjmp ping_pong_loop

shift_right:
	; shift value right
	lsr r17
	rjmp ping_pong_loop

move_left:
	; moving left
	; check if value == 0x08
	cpi r17, 0x08
	brne shift_left
	; if value == 0x08, change direction to right and shift right
	ldi r18, 0 	; set direction == 0 (moving right)
	lsr r17		; shift right to start moving right again
	rjmp ping_pong_loop

shift_left:
	; shift value left
	lsl r17
	rjmp ping_pong_loop


;	======SUBROUTINES=====

; Subroutine to display the digit in r17 on the LEDs
display_value:

	; Output lower 4 bits to PORTB
	mov r16, r17
	andi r16, 0x0F		; Mask to ensure only lower nybble is used
	out PORTB, r16

	; Output upper 4 bits to PORTD
	mov r16, r17
	andi r16, 0xF0		; Mask to ensure only upper nybble is used
	out PORTD, r16

	ret

; FOLLOWING MODIFIED FROM LAB 4 PROGRAMS: blink_halfsec.s & blink_delay.s

; 1 second delay subroutine - delays for 1000 ms (1 second)
delay_one_second:  	ldi r23, 100 	; 100*10ms = 1000ms
			call delay
			ret

; Subroutines for MORSE CODE:
; LED representation for a dot (one unit)
dot:		
			; turn ON the LED(s)
			ldi r16, 0xFF
			out PORTB, r16
    			out PORTD, r16

			call delay_200ms	; Delay for 200 ms

			; Turn OFF the LED(s)
			ldi r16, 0
			out PORTB, r16
			out PORTD, r16

			ret

; LED representation for a dash (three units)
dash:
			; turn ON the LED(s)
			ldi r16, 0xFF
			out PORTB, r16
			out PORTD, r16

			call delay_600ms	; Delay for 600 ms

			; Turn OFF the LED(s)
			ldi r16, 0
			out PORTB, r16
			out PORTD, r16
			
			ret

; 200 millisecond delay subroutine - delays for 200ms
delay_200ms:		ldi r23, 20	; 20*10ms = 200ms
			call delay
			ret

; 600 millisecond delay subroutine - delays for 600ms
delay_600ms:		ldi r23, 60	; 60*10ms = 600ms
			call delay
			ret

; 1400 millisecond delay subroutine - delays for 1400ms
delay_1400ms:		ldi r23, 140	; 140*10ms = 1400ms
			call delay
			ret


; DELAY SUBROUTINE - delays for r23 at 10 milliseconds steps - (r23 * 10)ms
delay:    ldi r21, 255
          ldi r22, 126 ; initialise loop for 1 ms
          ; inner loop is 5 cycles so 1 outer loop iteration is:
          ; 5 cycles * r21 * r22 = 
          ; 5 cycles * 255 *  126 = 160650 cycles
          ; 160650 cycles / 16,000,000 = 0.010040625 seconds (~10 ms) 

loop1:    nop        ; 1 cycle
          dec r21    ; 1 cycle
          cpi r21, 0 ; 1 cycle
          brne loop1 ; 2 cycles

          ldi r21, 255 ; reset inner loop
          dec r22
          cpi r22, 0
          brne loop1

          ldi r22, 126 ; reset first outer loop
          dec r23
          cpi r23, 0
          brne loop1
          ret
