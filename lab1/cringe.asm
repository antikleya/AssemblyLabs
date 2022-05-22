   section .data
B 	dw   	21
chart   dw      256
   section .text
        global  _start
_start: mov ax, 1
	add [chart], ax
        ; exit
        mov     rax, 60
        xor     rdi, rdi
        syscall
