; 在屏幕中间依次显示 'a' ~ 'z', 并可以让人看清。在显示的过程中，按下 Esc 键后，
; 改变显示的颜色。

assume cs:code

stack segment
    db 128 dup(0)
stack ends

data segment
    dw 0, 0
data ends

code segment
start:
    mov ax, stack
    mov ss, ax
    mov sp, 128

    mov ax, data
    mov ds, ax
    
    mov ax, 0
    mov es, ax

    ; 将原来的 int 9 中断例程的入口地址保存在 ds:0, ds:2 单元中
    push es:[9 * 4]
    pop ds:[0]
    push es:[9 * 4 + 2]
    pop ds:[2]
    

    cli  ; 屏蔽中断
    mov word ptr es:[9 * 4], offset int9
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

; 新的 int 9 中断例程
int9:
    push ax
    push bx
    push es

    in al, 60h

    ; 模拟中断调用过程
    pushf  ; 1. 保存标志位

    ; 2. IF=0 TF=0
    pushf
    pop bx
    and bh, 11111100b
    push bx
    popf
    ; 3. IP, CS 入栈然后调用相应程序，此处的相应程序为原来的 int 9 中断例程
    call dword ptr ds:[0]

    cmp al, 1
    jne int9ret

    ; 改变颜色
    mov ax, 0b800h
    mov es, ax
    inc byte ptr es:[160 * 12 + 40 * 2 + 1]

int9ret:
    pop es
    pop bx
    pop ax
    iret

code ends
end start
