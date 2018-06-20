assume cs:code, ds:data, ss:stack

data segment
    db 16 dup(?)
data ends

stack segment
    db 256 dup(?)
stack ends

code segment
main:
    mov ax, stack
    mov ss, ax
    mov sp, 256

    mov ax, data
    mov ds, ax
    mov si, 0

    ; 计算 100011 / 10, 即 0186abh / 0ah
    mov dx, 01h
    mov ax, 086abh
    mov cx, 0ah
    call divdw
    call dtoc

    push cx
    mov dh, 12
    mov dl, 40
    mov cl, 00100100b  ; 绿底红字
    call show_str

    pop ax
    call dtoc
    mov dh, 13
    mov dl, 40
    mov cl, 00100100b  ; 绿底红字
    call show_str

    mov ax, 4c00h
    int 21h


; func: show_str
; 功能：
;   在指定的位置，用指定的颜色，显示一个用 0 结束的字符串。
; 参数：
;   dh: 行号，取值范围 0-24。
;   dl: 列号，取值范围 0-79。
;   cl: 颜色。
;   ds:si 指向字符串的首地址。
show_str:
    push es
    push ax
    push bx
    push cx
    push dx
    push si

    mov ax, 0b800h
    mov es, ax

    ; 计算首个字符应该显示的地址, 保存在 bx 中
    ; address = 0a0h * 行号 + 02h * 列号
    mov al, 0a0h
    mov ah, 0
    mul dh
    mov dh, 0
    add ax, dx
    add ax, dx
    mov bx, ax

    ; 将颜色保存在 dl 中
    mov dl, cl

show_char:
    mov cl, ds:[si]
    mov ch, 0
    jcxz end_show_str
    mov ch, dl
    mov es:[bx], cx
    inc si
    add bx, 02h
    jmp short show_char

end_show_str:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    ret
; func ends


; func: divdw
; 功能：
;   进行不会产生溢出的除法运算进行不会产生溢出的除法运算，被除数为 dword 型，
;   除数为 word 型，结果为 dword 型。
; 参数：
;   ax: 保存 dword 型数据的低 16 位。
;   dx: 保存 dword 型数据的高 16 位。
;   cx: 保存除数。
; 结果：
;   dx: 保存结果的高 16 位。
;   ax: 保存结果的低 16 位。
;   cx: 保存余数。
; 思路：
;   X: 被除数，范围：[0, ffffffff]
;   N: 除数，范围：[0, ffff]
;   H: X 高 16 位，范围：[0, ffff]
;   L: X 低 16 位，范围：[0, ffff]
;
;   X / N = (H 除以 N 的商) * 65536 + [(H 除以 N 的余数) * 65536 + L] / N
;   假设: H 除以 N = k 余 m，m < N
;   则公式简化为 X / N = k * 65536 + (m * 65536 + L) / N
;   这个公式的正确性很容易看出来，而且 H 除以 N 这一步是肯定不会溢出的，下面
;   证明 (m * 65536 + L) / N 也不会溢出。
;   (m * 65536 + L) / N < (m * 65536 + 65536) / N = [(m + 1) / N] * 65536 <= 65536 = 2 ^ 16
divdw:
    push bx
    push ax

    ; H / N
    ; 结果：
    ;   dx 存余数 m
    ;   ax 存商 k
    mov ax, dx
    mov dx, 0
    div cx

    ; 将商 k 放在 bx 中
    mov bx, ax

    ; 恢复 ax，恢复后 ax 存储被除数的低 16 位
    pop ax

    ; 计算 (m * 65536 + L) / N
    ; 结果：
    ;   dx 存余数
    ;   ax 存商
    div cx

    ; 将余数放到 cx 中
    mov cx, dx
    ; 将商的高 16 位放在 dx 中（低 16 位已经在 ax 中，不需要处理）
    mov dx, bx

    pop bx
    ret
; func ends


; func: dtoc
; 功能：
;   将 word 型数据转变为表示十进制数的字符串，字符串以 0 为结尾符。
; 参数：
;   ax: 存储 word 型数据。
;   ds:si 指向字符串的首地址。
dtoc:
    push ax
    push si
    push dx
    push bx
    push cx

    mov bx, 0
    push bx
push_stack:
    mov dx, 0
    mov bx, 10
    div bx
    add dx, 30h
    push dx
    ; 将商移动到 cx
    mov cx, ax
    jcxz pop_stack
    jmp short push_stack

pop_stack:
    pop cx
    mov ds:[si], cl
    inc si
    jcxz end_dtoc
    jmp short pop_stack

end_dtoc:
    pop cx
    pop bx
    pop dx
    pop si
    pop ax
    ret
; func ends


code ends

end main
