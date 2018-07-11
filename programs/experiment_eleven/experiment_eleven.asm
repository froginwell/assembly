; 将包含任意字符，以 0 结尾的字符串中的小写字母转变成大写字母。

assume cs:code

data segment
    db "Hello, world!", 0
data ends

code segment
main:
    mov ax, data
    mov ds, ax
    mov si, 0
    call letterc

    mov ax, 4c00h
    int 21h

letterc:
    mov cl, [si]
    cmp cl, 0
    je end_letterc
    cmp cl, 97
    jb add_one
    cmp cl, 122
    ja add_one
    sub cl, 32
    mov [si], cl
add_one:
    inc si
    jmp letterc
end_letterc:
    ret

code ends

end main
