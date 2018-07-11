; 编写 0 号中断的处理程序，使得在除法溢出发生时，在屏幕中间显示字符串
; "divide error!"，然后返回 dos。

assume cs:code

code segment
main:
    ; 将中断代码搬移到 0000:0200h
    mov ax, cs
    mov ds, ax
    mov si, offset do0_start  ; 设置 ds:si 指向源地址
    mov ax, 0
    mov es, ax
    mov di, 0200h  ; 设置 es:di 指向目的地址

    mov cx, offset do0_end - offset do0_start  ; 设置 cx 为传输长度
    cld  ; 设置传输方向为正
    rep movsb

    ; 设置中断向量表
    mov ax, 0
    mov es, ax
    mov word ptr es:[0 * 4], 0200h
    mov word ptr es:[0 * 4 + 2], 0

    ; 触发除法溢出中断, 如果程序正确的话会在屏幕中间显示 divide error!
    mov ax, 01000h
    mov bl, 1
    div bl

    mov ax, 4c00h
    int 21h

do0_start:
    jmp do0
    db 'divide error!'
do0:
    ; ds:si 指向字符串
    mov ax, cs
    mov ds, ax
    mov si, 0203h

    ; es:di 指向显存空间的中间位置
    mov ax, 0b800h
    mov es, ax
    mov di, 12 * 160 + 36 * 2

    ; 将字符串搬移到显存区
    mov cx, 13
s:
    mov al, [si]
    mov es:[di], al
    inc si
    add di, 2
    loop s

    mov ax, 4c00h
    int 21h
do0_end: nop

code ends

end main
