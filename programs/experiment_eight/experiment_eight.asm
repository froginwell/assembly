; 在屏幕中间分别显示绿色、绿底红字、白底蓝色的字符串 'welcome to masm!'

assume cs:code

data segment
    db 'welcome to masm!'
data ends

code segment
start:
    mov ax, data
    mov ds, ax
    mov ax, 0b800h
    mov es, ax

    mov bx, 0
    mov cx, 16  ; welcome to masm! 的长度为 16
display:
    mov di, bx
    mov al, ds:[bx]

    mov ah, 00000010b  ; 绿色
    mov es:[bx + di + 06e0h + 40h], ax  ; 第 12 行

    mov ah, 00100100b  ; 绿底红字
    mov es:[bx + di + 06e0h + 00a0h + 40h], ax  ; 第 13 行

    mov ah, 01110001b  ; 白底蓝字
    mov es:[bx + di + 06e0h + 00a0h + 00a0h + 40h], ax  ; 第 14 行

    inc bx
    loop display

    mov ax, 4c00h
    int 21h
code ends

end start
