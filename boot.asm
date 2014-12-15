[org 0x7c00]
KERNEL_OFFSET equ 0x1000

mov [BOOT_DRIVE], dl

mov bp, 0x9000
mov sp, bp

mov bx, MSG_REAL_MODE
call print_string

call load_kernel
call switch_to_pm

jmp $

%include "print_string.asm"
%include "disk_load.asm"
%include "gdt.asm"
%include "print_string_pm.asm"
%include "switch_to_pm.asm"

[bits 16]

load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_string
    mov bx, KERNEL_OFFSET
    mov dh, 15
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret
    
[bits 32]
    
    BEGIN_PM:
    
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    
    call KERNEL_OFFSET
    
    jmp $
    
BOOT_DRIVE 	db 0
MSG_REAL_MODE	db "Started in 16-bit Real Mode", 0
MSG_PROT_MODE	db "Successfully landed in 32-bit Protected Mode", 0
MSG_LOAD_KERNEL	db "Loaded kernel into memory", 0

clear_screen:
    pusha		; save registers
    mov edx, 0xb8000	; start location of the video memory
    mov ebx, 0		; insert 0 into ebx
    clear_loop:		; clear loop
    cmp ebx, 10000	; compare if the loop has ended
    je clear_end	; jump if equal
    mov al, 32		; sets the character to be printed
    mov ah, 0x0f	; sets the color of the character
    mov [edx], ax	; sets the proper memory region of the character
    add edx, 2		; increment by 2 for the next character
    add ebx, 1		; increment by 1 for the next loop
    jmp clear_loop	; loop back
    clear_end:		; end of loop
    popa		; restore regesters
    ret			; return
    
move_cursor:
    pusha
    mov ah, 02h
    mov bh, 0
    mov dh, 1
    mov dl, 0
    int 10h
    popa
    ret


times 510-($-$$) db 0
dw 0xaa55