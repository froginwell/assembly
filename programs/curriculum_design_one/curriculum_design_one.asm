assume cs:code, ds:data, ss:stack

data segment
    ; 1975 ~ 1995
    db '1975', '1976', '1977', '1978', '1979', '1980', '1981', '1982', '1983'
    db '1984', '1985', '1986', '1987', '1988', '1989', '1990', '1991', '1992'
    db '1993', '1994', '1995'
    ; 公司总收入
    dd 16, 22, 382, 1356, 2390, 8000, 16000, 24486, 50065, 97479, 140417, 197514
    dd 345980, 590827, 803530, 1183000, 1843000, 2759000, 3753000, 4649000, 5937000
    ; 雇员人数
    dw 3, 7, 9, 13, 28, 38, 130, 220, 476, 778, 1001, 1442, 2258, 2793, 4037
    dw 5635, 8226, 11542, 14430, 15257, 17800
data ends

table segment
    ; 21 * 16 bytes
    db 21 dup(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
table ends

print_buffer segment
    db 11 dup(0)
print_buffer ends

stack segment
    db 1000 dup(?)
stack ends

code segment
main:
    mov ax, data
    mov ds, ax
    mov ax, table
    mov es, ax

    mov si, 0
    mov di, 0
    mov bx, 0

    mov cx, 21
s:
; ***************************************************************************
; *                               移动年份                                  *
; ***************************************************************************
    mov ax, ds:[si]
    mov es:[di], ax
    mov ax, ds:[si + 2]
    mov es:[di + 2], ax

    mov byte ptr es:[di + 4], ' '

; ***************************************************************************
; *                              移动总收入                                 *
; ***************************************************************************
    mov ax, ds:[si + 84]
    mov es:[di + 5], ax
    mov ax, ds:[si + 86]
    mov es:[di + 7], ax
    
    mov byte ptr es:[di + 9], ' '

; ***************************************************************************
; *                              移动雇员人数                               *
; ***************************************************************************
    mov ax, ds:[bx + 168]
    mov es:[di + 10], ax

    mov byte ptr es:[di + 12], ' '

; ***************************************************************************
; *                              计算平均收入                               *
; ***************************************************************************
    ; dx 存放高 16 位
    mov dx, es:[di + 7]
    ; ax 存放低 16 位
    mov ax, es:[di + 5]
    div word ptr es:[di + 10]
    ; 将商移动到正确的位置
    mov es:[di + 13], ax

    mov byte ptr es:[di + 15], ' '

    add si, 4
    add di, 16
    add bx, 2
    loop s


; ***************************************************************************
; *                              输出表格数据                               *
; ***************************************************************************
    mov ax, table
    mov ds, ax
    mov ax, print_buffer
    mov es, ax

    mov bx, 0
    mov di, 0
    mov dh, 1
    mov dl, 1
    mov cx, 21
print_year:
    push dx

    ; 移动年份
    mov dx, ds:[bx]
    mov es:[di], dx
    mov dx, ds:[bx + 2]
    mov es:[di + 2], dx
    ; 填充 1 个 0
    mov byte ptr es:[di + 4], 0

    pop dx

    ; 打印
    push ds
    push si
    push ax
    push cx

    mov ax, print_buffer
    mov ds, ax
    mov si, 0
    mov cl, 00100100b  ; 绿底红字
    call show_str

    pop cx
    pop ax
    pop si
    pop ds

    add dh, 1
    add bx, 16
    loop print_year


    mov dh, 1
    mov dl, 13
    mov bx, 5
    mov cx, 21
print_gross_income:
    push cx
    push ds
    push dx

    mov dx, ds:[bx + 2]
    mov ax, ds:[bx]
    mov si, 0

    push ax
    mov ax, print_buffer
    mov ds, ax
    pop ax

    call dtoc

    pop dx

    mov cl, 00100100b  ; 绿底红字
    call show_str

    pop ds
    pop cx

    add dh, 1
    add bx, 16
    loop print_gross_income


    mov dh, 1
    mov dl, 25
    mov bx, 10
    mov cx, 21
print_employer_number:
    push cx
    push ds
    push dx

    mov dx, 0
    mov ax, ds:[bx]
    mov si, 0

    push ax
    mov ax, print_buffer
    mov ds, ax
    pop ax

    call dtoc

    pop dx

    mov cl, 00100100b  ; 绿底红字
    call show_str

    pop ds
    pop cx

    add dh, 1
    add bx, 16
    loop print_employer_number


    mov dh, 1
    mov dl, 37
    mov bx, 13
    mov cx, 21
print_average_income:
    push cx
    push ds
    push dx

    mov dx, 0
    mov ax, ds:[bx]
    mov si, 0

    push ax
    mov ax, print_buffer
    mov ds, ax
    pop ax

    call dtoc

    pop dx

    mov cl, 00100100b  ; 绿底红字
    call show_str

    pop ds
    pop cx

    add dh, 1
    add bx, 16
    loop print_average_income
    

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
;   将 dword 型数据转变为表示十进制数的字符串，字符串以 0 为结尾符。
; 参数：
;   dx: 存储 dword 型数据的高 16 位。
;   ax: 存储 dword 型数据的低 16 位。
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
    mov cx, 10
    call divdw

    add cx, 30h
    push cx

    mov cx, dx
    jcxz judge_low_16bits
    jmp short push_stack
judge_low_16bits:
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
