
.model small
org 100h
.code

start:
    mov ax, @data
    mov ds, ax

    ; 초기 상태: Red만 켬
    mov ax, 0249h
    out 4, ax
    call delay5s

main_loop:
    ; 낮/밤 감지 (가상 입력 대체용)
    ; P 입력 시 낮 모드, N 입력 시 밤 모드
    mov ah, 1
    int 21h
    cmp al, 'N'
    je night_mode
    cmp al, 'P'
    je day_mode
    jmp main_loop


; 낮 모드 루틴
day_mode:
    call print_day

    ; 북-남 Green
    mov ax, 0000001100001100b
    out 4, ax
    call print_text_green
    call delay5s

    ; 전부 Yellow
    mov ax, 0000011110011110b
    out 4, ax
    call print_text_yellow
    call delay2s

    ; 동-서 Green
    mov ax, 0000100001100001b
    out 4, ax
    call print_text_green
    call delay5s

    ; 전부 Yellow
    mov ax, 0000110011110011b
    out 4, ax
    call print_text_yellow
    call delay2s

    
    ; 보행자 신호 처리: 키보드 'B' 입력 시 동작
    mov ah, 1
    int 21h
    cmp al, 'B'
    jne no_ped

    call pedestrian_signal

no_ped:
    jmp main_loop

; 밤 모드 루틴
night_mode:
    call print_night

night_loop:
    ; 노란불 켜기
    mov ax, 0000001000001000b
    out 4, ax
    call print_text_blink
    call delay1s

    ; 불 끄기
    mov ax, 0000000000000000b
    out 4, ax
    call print_text_off
    call delay1s

    ; 키 입력 여부 확인 (비차단 방식)
    mov ah, 01h
    int 16h          ; BIOS: Check for key press
    jz night_loop    ; ZF=1 → 키 없음 → 계속 루프

    ; 키 있음 → 읽기
    mov ah, 00h
    int 16h          ; AL에 입력된 문자

    cmp al, 'P'
    je main_loop     ; 낮 모드로 전환
    jmp night_loop

; 보행자 루틴
pedestrian_signal:
    ; Red ON
    mov al, 'R'
    call print_char
    call delay5s

    ; Green ON
    mov al, 'G'
    call print_char
    call delay5s

    ; 점멸 (느리게)
    mov si, 3
blink_loop:
    mov al, '*'
    call print_char
    call delay1s
    mov al, '.'
    call print_char
    call delay1s
    dec si
    jnz blink_loop

    ; 빠른 점멸
    mov si, 4
fast_blink:
    mov al, '*'
    call print_char
    call delay200ms
    mov al, '.'
    call print_char
    call delay200ms
    dec si
    jnz fast_blink

    ret

; --------- 텍스트 출력 루틴들 ---------

print_day:
    mov ah, 0Eh
    mov al, 'D'
    int 10h
    mov al, ':'
    int 10h
    ret

print_night:
    mov ah, 0Eh
    mov al, 'N'
    int 10h
    mov al, ':'
    int 10h
    ret

print_text_green:
    mov ah, 0Eh
    mov al, 'G'
    int 10h
    ret

print_text_yellow:
    mov ah, 0Eh
    mov al, 'Y'
    int 10h
    ret

print_text_blink:
    mov ah, 0Eh
    mov al, '*'
    int 10h
    ret

print_text_off:
    mov ah, 0Eh
    mov al, '.'
    int 10h
    ret

print_char:
    mov ah, 0Eh
    int 10h
    ret

; --------- Delay 루틴들 ---------

; 약 5초 지연
delay5s:
    mov cx, 4Ch
    mov dx, 4B40h
    mov ah, 86h
    int 15h
    ret

; 약 2초 지연
delay2s:
    mov cx, 20h   ; 1250
    mov dx, 4B40h
    mov ah, 86h
    int 15h
    ret

; 약 1초 지연
delay1s:
    mov cx, 10h   ; 625
    mov dx, 4B40h
    mov ah, 86h
    int 15h
    ret

; 약 200ms 지연
delay200ms:
    mov cx, 02h   ; 138
    mov dx, 4B40h
    mov ah, 86h
    int 15h
    ret

end start
