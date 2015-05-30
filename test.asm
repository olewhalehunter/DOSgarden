.MODEL SMALL
.STACK 100H
.DATA
OUTMSG DB '...', 0AH, '$'
EXTRA DB 'eeeeeeee->', '$'
WAVE_SIZE DW 1
FILE_SIZE DW 5000
IMG_FNAME DB 'C:\TASM\TASM\out.dat', 0
PAL_FNAME DB 'PALETTE.dat', 0
FILE_HANDLE DW 0
FILE_BUFFER DB 100 DUP (?), '$'
PALETTE_BUFFER DB 768 DUP (?)
.CODE
JMP START

FILE_READ PROC NEAR
 PUSH AX
 PUSH BX
 PUSH CX
 PUSH DX

 MOV AH, 3DH
 MOV AL, 0
 MOV DX, OFFSET IMG_FNAME
 INT 21H
 MOV FILE_HANDLE, AX
	
 MOV AH, 3FH
 MOV CX, FILE_SIZE
 MOV DX, OFFSET FILE_BUFFER
 MOV BX, FILE_HANDLE
 INT 21H

 ;; MOV BX, FILE_HANDLE	
 ;; MOV AH,3EH
 ;; INT 21H 
	
 POP DX
 POP CX
 POP BX
 POP AX
 RET
ENDP

START:
MOV AX, 13h
MOV AH, 0
INT 10H
MOV AX, @DATA 
MOV DS, AX
CALL FILE_READ
MOV DI, 0
mov AL, [ds:FILE_BUFFER+di]
push ax
inc di
mov AL, [ds:FILE_BUFFER+di]
push ax
inc di

mov dx, 0
yloop:
mov cx, 0
xloop:
mov ah, 0ch
mov al, [ds:FILE_BUFFER+di]
mov bh, 0
int 10h

inc di
pop ax
pop bx
push ax
push bx

inc cx
add al, 1
cmp al, cl
jne xloop
inc dx
add bl, 1
cmp bl, dl
jne yloop


mov ah, 01h
int 21h
MOV AL, 0 		
MOV AH, 4CH
INT 21H
END START

