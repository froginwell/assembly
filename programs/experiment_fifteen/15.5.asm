; 安装一个新的 int 9 中断例程，使得原 int 9 中断例程的功能得到扩展
; F1 改变背景色

assume cs:code

stack segment
    db 128 dup(0)
stack ends

data segment
    dw 0, 0
data ends

code segment
start:
; ******************** 安装 F1 中断例程 **************************
    mov ax, stack
    mov ss, ax
    mov sp, 128

    push cs
    pop ds

    mov ax, 0
    mov es, ax

    mov si, offset int9
    mov di, 204h
    mov cx, offset int9end - offset int9
    cld
    rep movsb

    push es:[9 * 4]
    pop es:[200h]
    push es:[9 * 4 + 2]
    pop es:[202h]

    cli
    mov word ptr es:[9 * 4], 204h
    mov word ptr es:[9 * 4 + 2], 0
    sti

; ********************* 安装 Esc 中断例程 ***************************
    ; 将原来的 int 9 中断例程的入口地址保存在 ds:0, ds:2 单元中
    push es:[9 * 4]
    pop ds:[0]
    push es:[9 * 4 + 2]
    pop ds:[2]
    

    cli  ; 屏蔽中断
    mov word ptr es:[9 * 4], offset int9_1
    mov es:[9 * 4 + 2], cs
    sti  ; 开启中断

    mov ax, 0b800h
    mov es, ax
    mov ah, 'a'
s:
    mov es:[160 * 12 + 40 * 2], ah
    call delay
    inc ah
    cmp ah, 'z'
    jna s

    mov ax, 0
    mov es, ax

    ; 将中断向量表中 int 9 中断例程的入口恢复为原来的地址
    push ds:[0]
    pop es:[9 * 4]
    push ds:[2]
    pop es:[9 * 4 + 2]

    mov ax, 4c00h
    int 21h

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

; Esc 改变字母颜色
int9_1:
    push ax
    push bx
    push es

    in al, 60h

    pushf
    call dword ptr ds:[0]

    cmp al, 1
    jne int9_1ret

    ; 改变颜色
    mov ax, 0b800h
    mov es, ax
    inc byte ptr es:[160 * 12 + 40 * 2 + 1]

int9_1ret:
    pop es
    pop bx
    pop ax
    iret

; F1 改变背景色
int9:
    push ax
    push bx
    push cx
    push es

    in al, 60h

    pushf
    call dword ptr cs:[200h]

    cmp al, 3bh  ; F1 的扫描码为 3bh
    jne int9ret

    mov ax, 0b800h
    mov es, ax
    mov bx, 1
    mov cx, 2000
s2:
    inc byte ptr es:[bx]
    add bx, 2
    loop s2

int9ret:
    pop es
    pop cx
    pop bx
    pop ax
    iret

int9end:
    nop

code ends

end start
