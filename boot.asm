ORG 0x7c00
BITS 16

start:

.pass: 
  mov si, message
  call print
  call seekinput
  ; compare and check if password is correct
  mov si, input_buffer
  mov di, Password
  call compare_strings
  cmp ax, 0
  je .done
  jmp .pass
.done:
  ; Bootloading


  jmp $

print:
  mov bx, 0 ; Something Related to Paging
.loop:
  lodsb
  cmp al, 0
  je .done
  call print_char
  jmp .loop
.done:
  ret

print_char:
  mov ah, 0eh
  int 0x10
  ret

seekinput:
  mov di, input_buffer  ; Set destination index to the start of the buffer
.loop:
  mov ah, 0x00
  int 0x16
  cmp al, 0x0D         ; Check if Enter key (ASCII 0x0D) is pressed
  je .done
  call print_char
  stosb                ; Store the character in the buffer
  jmp .loop
.done:
  mov byte [di], 0     ; Null-terminate the input buffer
  call newline
  ret

newline:
  ; Get current cursor position
  mov ah, 0x03
  mov bh, 0x00
  int 0x10

  ; Move to the start of the next line
  inc dh               ; Increment row
  mov dl, 0x00         ; Set column to 0
  mov ah, 0x02         ; Set cursor position function
  int 0x10
  ret

compare_strings:
.loop:
  lodsb                ; Load byte from input_buffer into AL and increment SI
  cmp al, 0
  je .check_end        ; If null-terminator reached, check end condition
  mov ah, [di]
  cmp al, ah
  jne .not_equal       ; If characters do not match, strings are not equal
  inc di               ; Increment DI to point to next character in Password
  jmp .loop
.check_end:
  mov al, [di]
  cmp al, 0
  je .equal            ; If end of Password string is reached, strings are equal
.not_equal: ; Incorrect password
  mov ax, 1
  jmp .done

.equal:
  ; Correct password
  mov ax, 0
  jmp .done

.done:
  ret

message:
  db 'Enter Password: ', 0

Password:
  db 'Talkative_Banana', 0

input_buffer:
  times 32 db 0

times 510-($ - $$) db 0
dw 0xAA55

