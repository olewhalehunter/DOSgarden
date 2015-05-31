.MODEL SMALL
.STACK 100H
.DATA
OUTMSG DB '...', 0AH, '$'
EXTRA DB 'eeeeeeee->', '$'
WAVE_SIZE DW 1
FILE_SIZE DW 40000
IMG_FNAME DB 'C:\TASM\TASM\out.dat', 0
IMGB_FNAME DB 'face.dat', 0
PAL_FNAME DB 'PALETTE.dat', 0
FILE_HANDLE DW 0
FILE_BUFFER DB 40000 DUP (?), '$'
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

 MOV BX, FILE_HANDLE	
 MOV AH,3EH
 INT 21H 
	
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
inc di
mov AH, [ds:FILE_BUFFER+di]
push ax
inc di

mov dx, 0
yloopa:
mov cx, 0
xloopa:
mov ah, 0ch
mov al, [ds:FILE_BUFFER+di]
cmp al, 01h
je skipalphaa
mov bh, 0
int 10h
skipalphaa:
inc di
pop ax
push ax

inc cx
cmp al, cl
jg xloopa

inc dx
cmp ah, dl
jg yloopa

PUSH AX
 PUSH BX
 PUSH CX
 PUSH DX

 MOV AH, 3DH
 MOV AL, 0
 MOV DX, OFFSET IMGB_FNAME
 INT 21H
 MOV FILE_HANDLE, AX
	
 MOV AH, 3FH
 MOV CX, FILE_SIZE
 MOV DX, OFFSET FILE_BUFFER
 MOV BX, FILE_HANDLE
 INT 21H

 MOV BX, FILE_HANDLE	
 MOV AH,3EH
 INT 21H 
	
 POP DX
 POP CX
 POP BX
 POP AX
mov ah, 01h
int 21h

MOV DI, 0
mov AL, [ds:FILE_BUFFER+di]
inc di
mov AH, [ds:FILE_BUFFER+di]
push ax
inc di

mov dx, 0
yloopb:
mov cx, 0
xloopb:
mov ah, 0ch
mov al, [ds:FILE_BUFFER+di]
cmp al, 01h
je skipalphab
mov bh, 0
int 10h
skipalphab:
inc di
pop ax
push ax

inc cx
cmp al, cl
jg xloopb

inc dx
cmp ah, dl
jg yloopb

mov ah, 01h
int 21h
MOV AL, 0 		
MOV AH, 4CH
INT 21H
END START

