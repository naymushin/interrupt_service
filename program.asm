; Program written in i8086 assembler that performs
; interrupt service as described in README
.model tiny

assume cs:mycode
assume ds:mydata
assume ss:mystack

mydata segment 
myarr db 'Hello world!!', 0
mydata ends

mycode segment
						; user interruption handler
myhandler:
	sti
	mov dx, 3f8h
	in al, dx
	mov ah, 00001110b 	; yellow color
	mov es:[di], ax
	inc di
	inc di          	; twice for di parity
	mov al, 20h
    out 20h, al     	; stop processor
    iret
						; subroutine comport
comport PROC
						; Initializing of COM-port
initialize:
						; reconfiguring vectors for normal mode
	mov bp, 0
	mov ds, bp
	mov si, 48
	mov bp, ds:[si]
	inc si
	inc si
	mov bx, ds:[si]
	dec si
	dec si
	mov cx, offset myhandler
	mov dx, mycode
	mov ds:[si], cx
	inc si
	inc si
	mov ds:[si], dx
						; 1. setting transmission rate
    mov dx, 3FBh
    in al, dx
    or al, 10000000b
    out dx, al

    mov dx, 3F8h
    mov al, 01100000b 	; lowest byte of frequency denominator
    out dx, al
    inc dx
    mov al, 00000000b 	; highest byte of frequency denominator
    out dx, al

    mov dx, 3FBh
    in al, dx
    and al, 01111111b
    out dx, al
						; 2. setting format for asynchronous transfer
    mov dx, 3FBh
    mov al, 00011111b
    out dx, al
						; 3. enable diagnostic mode and allow COM-port
						; produce interrupt requests    
    mov dx, 3FCh
    mov al, 00011000b
    out dx, al
						; 4. enable COM-port to produce interrupt requests
						; after receiving
    mov dx, 3F9h
    mov al, 00000010b 
    out dx, al
						; 5. Enable interrupt processing in interrupt controller
    in al, 21h
    and al, 11101111b
    out 21h, al
						; main part
	mov cx, mydata
	mov dx, offset myarr
	mov si, dx
	mov ds, cx
qwer:
	mov dx, 3f8h
	mov cl, ds:[si]
	mov al, cl
	out dx,al
	inc si
	mov dx, ds:[si]
	cmp dx, 0
	jnz qwer	
						;transfer interrupt vectors back
	mov dx, 0
	mov ds, dx
	mov si, 48
	mov ds:[si], bp
	inc si
	inc si
	mov ds:[si], bx	
        
        ret
comport ENDP
						; program entry point
mystart:  
	      
    mov ax, mydata
    mov ds, ax        
    mov ax, 0
    mov es, ax
    mov ax, mystack
    mov ss, ax
    mov sp, 0
						; main program code
	mov cx, 0b800h
	mov es, cx
	mov di, 0
	sti
	call comport
						; exit to DOS
    mov ax, 4C00h
    int 21h
mycode ends

.stack
mystack segment
    db 1000 dup(?)  	; stack size 1000 bytes
mystack ends

end mystart