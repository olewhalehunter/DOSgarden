.MODEL SMALL
.STACK 100H
.DATA
OUTMSG DB '...', 0AH, '$'
EXTRA DB 'eeeeeeee->', '$'
WAVE_SIZE DW 1
FILE_SIZE DW 10
IMG_FNAME DB 'C:\TASM\TASM\IMAGES.TXT', 0
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

PUSH AX
PUSH BX
PUSH CX
PUSH DX

INIT_PALETTE_L PROC
 push ax
 mov ax,1010h
 int 10h
 pop ax
 ret
INIT_PALETTE_L ENDP

INIT_PALETTE PROC
MOV BX, 0
MOV dh, 0
MOV ch, 0
MOV cl, 0

rloop:
CALL INIT_PALETTE_L
INC BX
INC dh
CMP DH, 3fh
JNE rloop

gloop:
MOV dh, 0
MOV cl, 0
CALL INIT_PALETTE_L
inc ch
INC BX
CMP ch, 3fh
JNE gloop

bloop:
MOV dh, 0
MOV ch, 0
CALL INIT_PALETTE_L
inc cl
INC BX
CMP cl, 3fh
JNE bloop

MOV cl, 0
gbloop:
MOV dh, 3fh
MOV ch, 0
CALL INIT_PALETTE_L
inc cl
INC BX
CMP cl, 3fh
JNE gbloop
ret
INIT_PALETTE ENDP


POP AX
POP BX
POP CX
POP DX
START:
MOV AX, 13h
MOV AH, 0
INT 10H
MOV AX, @DATA 
MOV DS, AX
xor di, di
xor dl, dl
readpal:

mov bh, dl
mov ax, 1007h
int 10h ;; load color register # to BX

mov bl, dl
MOV AX, 1015h
INT 10H 
mov [ds:PALETTE_BUFFER+di], DH
inc di
mov [ds:PALETTE_BUFFER+di], CH
inc di
mov [ds:PALETTE_BUFFER+di], CL
inc di ;; rgb values -> buffer

inc dl
cmp di, 02FDh
jne readpal

MOV AX, 3D01h
MOV DX, OFFSET PAL_FNAME
INT 21H
MOV FILE_HANDLE, AX ;; open file and assign handle

mov ah, 40h
mov bx, FILE_HANDLE
mov cx, 02FDh  ;; 256*3=768
lea dx, PALETTE_BUFFER
INT 21h         ;; write palette to file


MOV AL, 0 		
MOV AH, 4CH
INT 21H
END START

