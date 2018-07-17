; 安装一个新的 int 7ch 中断例程，为显示输出提供如下功能子程序:
; 1. 清屏
; 2. 设置前景色
; 3. 设置背景色
; 4. 向上滚动一行
; 参数说明:
; 1. 用 ah 寄存器传递功能号：0 表示清屏，1 表示设置前景色，2 表示设置背景色，
;    3 表示向上滚动一行。
; 2. 对于 1、2 号功能，用 al 传送颜色值，al 可以为 0, 1, 2, 3, 4, 5, 6, 7。

assume cs:code, ds:data

data segment
    original_int dw 0, 0
    str db 'Hello world!'
data ends

code segment
start:
    mov ax, data
    mov ds, ax

    mov ax, 0
    mov es, ax
    ; 将原来的 int 7ch 中断例程的入口地址保存在 original_int 中
    push es:[7ch * 4]
    pop original_int[0]
    push es:[7ch * 4 + 2]
    pop original_int[1]

    cli  ; 屏蔽中断
    mov word ptr es:[7ch * 4], offset int_setscreen
    mov es:[7ch * 4 + 2], cs
    sti  ; 开启中断

; Test start
    ; 在屏幕中间显示 Hello world!
    mov bx, 0b800h
    mov es, bx
    mov bx, 160 * 12 + 80
    mov si, 0
    mov cx, 12
display:
    mov al, str[si]
    mov es:[bx], al
    add bx, 2
    inc si
    loop display

    ; 设置前景色
    mov ah, 1
    mov al, 3
    int 7ch
    call delay

    ; 设置背景色
    mov ah, 2
    mov al, 1
    int 7ch
    call delay

    ; 滚屏
    mov cx, 10
roll:
    mov ah, 3
    int 7ch
    loop roll
    call delay

    ; 清屏
    mov ah, 0
    int 7ch
; Test End
    
    mov ax, 0
    mov es, ax
    ; 将中断向量表中 int 7ch 中断例程的入口恢复为原来的地址
    push original_int[0]
    pop es:[7ch * 4]
    push original_int[1]
    pop es:[7ch * 4 + 2]

    mov ax, 4c00h
    int 21h

int_setscreen:
    call setscreen
    iret

setscreen:
    jmp short set
    table dw sub1, sub2, sub3, sub4
set:
    push bx
    cmp ah, 3
    ja sret
    mov bl, ah
    mov bh, 0
    add bx, bx
    call word ptr table[bx]
sret:
    pop bx
    ret

; 清屏
sub1:
    push bx
    push cx
    push es
    mov bx, 0b800h
    mov es, bx
    mov bx, 0
    mov cx, 2000
sub1s:
    mov byte ptr es:[bx], ' '
    add bx, 2
    loop sub1s
    pop es
    pop cx
    pop bx
    ret

; 设置前景色
; al 传颜色值
sub2:
    push bx
    push cx
    push es
    mov bx, 0b800h
    mov es, bx
    mov bx, 1
    mov cx, 2000
sub2s:
    add byte ptr es:[bx], 11111000b
    or es:[bx], al
    add bx, 2
    loop sub2s
    pop es
    pop cx
    pop bx
    ret

; 设置背景色
; al 传颜色值
sub3:
    push bx
    push cx
    push es
    mov cl, 4
    shl al, cl
    mov bx, 0b800h
    mov es, bx
    mov bx, 1
    mov cx, 2000
sub3s:
    and byte ptr es:[bx], 10001111b
    or es:[bx], al
    add bx, 2
    loop sub3s
    pop es
    pop cx
    pop bx
    ret

; 向上滚动一行
sub4:
    push cx
    push si
    push di
    push es
    push ds
    
    mov si, 0b800h
    mov es, si
    mov ds, si
    mov si, 160  ; ds:si 指向第 n + 1 行
    mov di, 0  ; es:di 指向第 n 行
    cld
    mov cx, 24  ; 共复制 24 行
sub4s:
    push cx
    mov cx, 160
    rep movsb
    pop cx
    loop sub4s

    ; 清空最后一行
    mov cx, 80
sub4s1:
    mov byte ptr es:[di], ' '
    add di, 2
    loop sub4s1

    pop ds
    pop es
    pop di
    pop si
    pop cx
    ret

delay:
    push ax
    push dx
    mov dx, 100h
    mov ax, 0
s1:
    sub ax, 1
    sbb dx, 0
    cmp ax, 0
    jne s1
    cmp dx, 0
    jne s1
    pop dx
    pop ax
    ret
code ends

end start
