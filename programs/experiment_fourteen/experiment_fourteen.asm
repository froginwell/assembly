; 从 CMOS RAM 中读取年月日信息，以 "年/月/日 时:分:秒" 的格式显示。
; 在 CMOS RAM 中，存放着当前的时间：年、月、日、时、分、秒。这 6 个信息的长度
; 都为 1 字节，存放单元为：
; 秒: 0, 分: 2, 时: 4, 日: 7, 月: 8, 年: 9

assume cs:code

data segment
    db 9, 0, '/', 8, 0, '/', 7, 0, ' ', 4, 0, ':', 2, 0, ':', 0, 0
data ends

code segment
start:
    mov ax, data
    mov ds, ax
    mov si, 0

    mov cx, 6
s:
    push cx

    mov al, ds:[si]
    out 70h, al
    in al, 71h

    mov ah, al
    mov cl, 4
    shr ah, cl
    and al, 00001111b

    add ah, 30h
    add al, 30h

    mov ds:[si], ah
    mov ds:[si + 1], al

    add si, 3

    pop cx
    loop s


    mov si, 0

    mov ax, 0b800h
    mov es, ax
    mov di, 2000  ; 160 * 12 + 40 * 2 第 13 行，第 41 列

    mov cx, 17
display:
    mov al, ds:[si]
    mov byte ptr es:[di], al
    
    inc si
    add di, 2

    loop display

    mov ax, 4c00h
    int 21h
code ends

end start
