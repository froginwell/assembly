# Assembly

此 Git 库保存了:

1. 本人学习王爽的 《汇编语言（第三版）》时所写的代码(见 programs 目录)。
2. masm5.0 程序(见 software 目录)，这一系列程序用来编译、链接、调试我们写的代码。

# 在 ubuntu 上搭建 dos 环境

由于本人用的操作系统是 ubuntu，所以所有的实验都是在 ubuntu 系统上进行的，下面
介绍一下如何在 ubuntu 系统上搭建 dos 环境。

操作系统用的是 ubuntu 16.04.4。需要用到的软件有：

1. dosbox。一个模拟 dos 的软件。
2. masm 系列软件。用来编译、调试程序。

## 安装 dosbox

```
sudo apt install dosbox
```

## 安装 masm

为了方便大家下载，我在 github 上上传了一份，下载地址为：[https://github.com/froginwell/assembly/tree/master/software](https://github.com/froginwell/assembly/tree/master/software)。
这个是 masm5.0 版本的，里面已经集成了 debug.exe。如果需要其它版本可自行在网上搜索下载。

下载完成后在终端执行 `dosbox` 启动 dosbox，启动后执行 `mount c /the_directory_of_masm` 将 masm 所在目录挂载为 c 盘。
the\_directory\_of\_masm 请根据实际情况替换。为了避免每次启动都手动执行这个命令，可以把它加在 ~/.dosbox/dosbox-0.74.conf
的 [autoexec] 节中。

## 使用 masm

根据传统，在此写一个输出 "Hello world!" 的程序。程序源码如下：

hello\_world.asm

```asm
assume cs:code, ds:data

data segment
    str db 'Hello world!', 10, 13, '$'
data ends

code segment
start:
    mov ax, data
    mov ds, ax
    lea dx, str
    mov ah, 9
    int 21h

    mov ax, 4c00h
    int 21h
code ends

end start
```

执行过程如下：

1. 将其放到你挂载的目录下；
2. 执行 dosbox 启动 dosbox；
3. 执行 `masm.exe hello_world.asm` 编译；
4. 执行 `link.exe hello_world.obj` 链接；
5. 执行 `hello_world.exe` 输出 "Hello world!"。
