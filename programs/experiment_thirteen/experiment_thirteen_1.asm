; 编写并安装 int 7ch 中断例程，功能为显示一个用 0 结束的字符创，中断例程安装
; 在 0:200 处。
; 参数：dh 行号, dl 列号, cl 颜色, ds:si 指向字符串首地址

assume cs:code

data segment
    db 'Welcome to masm!', 0
data ends

code segment
main:
    ; 将中断代码搬移到 0000:0200h
    mov ax, cs
    mov ds, ax
    mov si, offset show_str  ; 设置 ds:si 指向源地址
    mov ax, 0
    mov es, ax
    mov di, 0200h  ; 设置 es:di 指向目的地址

    mov cx, offset end_show_str - offset show_str  ; 设置 cx 为传输长度
    cld  ; 设置传输方向为正
    rep movsb

    ; 设置中断向量表
    mov ax, 0
    mov es, ax
    mov word ptr es:[07ch * 4], 0200h
    mov word ptr es:[07ch * 4 + 2], 0

    ; 显示数据
    mov ax, data
    mov ds, ax
    mov si, 0
    mov dh, 12
    mov dl, 40
    mov cl, 00100100b  ; 绿底红字
    int 07ch

    mov ax, 4c00h
    int 21h

; dh 行号
; dl 列号
; cl 颜色
; ds:si 指向字符串首地址
show_str:
    mov ax, 0b800h
    mov es, ax
    ; 首字符地址为 160 * (行号 - 1) + 2 * (列号 - 1)
    mov ax, 160
    mul dh
    sub ax, 160
    mov bx, ax
    mov ax, 2
    mul dl
    sub ax, 2
    add ax, bx
    mov di, ax

    mov dh, cl
show_char:
    mov dl, ds:[si]
    cmp dl, 0
    je end_show_char
    mov es:[di], dx
    inc si
    add di, 2
    jmp show_char
end_show_char:
    iret
end_show_str:
    nop
    
code ends

end main
