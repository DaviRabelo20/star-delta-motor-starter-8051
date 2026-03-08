; Simulacao rodando com clock de 12 MHz
; P1.0 = k1
; P1.1 = k4
; P1.2 = k2
; P1.3 = k3
; P2.0, 1 e 2 = bits de tempo
; P2.3 = start
; P2.4 = inverter rotacao
org 0000h
jmp start
org 000bh
jmp isrt0
org 001bh
jmp isrt1
isrt0:
clr tf0
djnz r3, skip0
cpl P1.2
cpl P1.3
clr et0
reti
skip0:
mov th0, #03ch
mov tl0, #0b0h
reti
isrt1:
clr tf1
djnz r4, skip1
cpl P1.0
cpl P1.1
clr et1
reti
skip1:
mov th1, #03ch
mov tl1, #0b0h
reti
start:
mov tmod, #11h ; Timer 0 e 1 no modo 1
mov th0, #03ch ; 50 ms overflow (t0)
mov tl0, #0b0h
mov th1, #03ch ; o mesmo para t1
mov tl1, #0b0h
mov ie, #8ah ; ea = 1, et0 = 1, et1 = 1
main:
jb P2.3, $
mov a, p2
cpl a
anl a, #07h
mov dptr, #timer_counts
movc a, @a+dptr
mov r3, a
cpl P1.0 ; K1
cpl P1.2 ; K2
setb tr0 ; Inicia o timer 0
rot:
jb P2.4, rot ; Inverter rotacao
mov r4, #60 ; Delay de 3 segundos
setb tr1 ; Inicia o timer 1
sjmp $
timer_counts:
db 20
db 40
db 60
db 80
db 100
db 120
db 140
db 160
end
