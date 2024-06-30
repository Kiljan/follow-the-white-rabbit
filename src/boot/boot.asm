ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; for bios parameter block
_start:
    jmp short start
    nop
times 33 db 0

start:
    jmp 0:step2

step2:
    cli ; ignore interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; start interrupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32

; GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code:        ; CS should point to this
    dw 0xffff    ; segment limit first 0-15 bits
    dw 0         ; base first 0-15 bits
    db 0         ; base 16-23 bits
    db 0x9a      ; access bite 
    db 11001111b ; high 4 bit flags and the low 4 bit flags
    db 0         ; base 24-31 bits

; offset 0x10
gdt_data:        ; should point to DS, SS, ES, FS, GS
    dw 0xffff    ; segment limit first 0-15 bits
    dw 0         ; base first 0-15 bits
    db 0         ; base 16-23 bits
    db 0x92      ; access bite 
    db 11001111b ; high 4 bit flags and the low 4 bit flags
    db 0         ; base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start


[BITS 32]
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax ; Backup LBA
    ; shr shift the highest bit, send the highest 8 bits of the lba to hard disk controller
    shr eax, 24
    or eax, 0xE0 ; This selects a master driver
    mov dx, 0x1F6
    out dx, al
    ; finished sending the highest 8 bits of the lba

    ; Send the total sector to read
    mov eax, ecx 
    mov dx, 0x1F2
    out dx, al
    ; finished sending the total sector to read

    ; Send more bits to the LBA
    mov eax, ebx ; Restore the backup LBA
    mov dx, 0x1F3
    out dx, al
    ; finished sending more bits to the LBA

    ; Send more bits to the LBA
    mov dx, 0x1F4
    mov eax, ebx ; Restore the backup LBA
    shr eax, 8
    out dx, al
    ; finished sending more bits to the LBA

    ; Send upper 16 bits of a LBA
    mov dx, 0x1F5
    mov eax, ebx ; Restore the backup LBA
    shr eax, 16
    out dx, al
    ; finished sending upper 16 bits of a LBA
    
    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

; Read all sectors into memory
.next_sector:
    push  ecx

; Checking if we need to read
.try_again:
    mov dx, 0x71F7
    in al, dx
    test al, 8
    jz .try_again

; We need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ; End of reading sectors
    ret

times 510-($ - $$) db 0
dw 0xAA55

