 ; obliczanie sumy kontrolnej pliku HEX, bez pierwszej cyfry 10h /20h/
POB_PARAM: EQU 01F4h ; pobiera do HL 4. znaki -adres
LBYTE:     EQU 18h ; wysw. rej. A
LADR:      EQU 20h ; wysw. HL
CYF2:      EQU 0FFF9h
; formaty plikow INTEL HEX  - PRZYKLADY
; : 10 C000 00 31 66 FF D7 80 21 0D CA E7 44 CD F4 01 40 54 5D    32 / 32 TO SUMA KONTROLNA
; : 20 C000 00 31 66 FF D7 80 21 0D CA E7 44 CD F4 01 40 54 5D 06 10 3E F0 94 95 4E 23 91 10 FB DF 20 2B 7D DF   22 / 22 TO SUMA KONTROLNA
   ORG     0xFB00
 LD SP, 0FF66H
 STR:
 rst 10h ; to jest rozkaz D7 80
 defb 80h
 ld HL, 0CA0Dh
 rst LADR ; wysw. HL "CAOd"
 defb 44h
 call pob_param
 defb 40h
   STR1:
  ld D, H
  ld E, L ; pocz. adres
  ld b, 10h ; ilosc bajtów do odczytu; albo 20h jesli drugi przyklad 
  ld a, 0F0h ;od tej liczby odejmuj kolejno odczytane bajty,
            ;bez pierwszego /=10h/ lub E0 - bez pierwszego 20h w 
  sub h  ; starszy bajt adresu
  sub l  ; mlodszy bajt adresu
 LICZ:
  ld c,(hl)
  inc hl
  sub c
  djnz LICZ
   ; wyswietl adres i sume

  rst LBYTE ; suma INTEL HEX  DF 20
  defb 20h
  dec HL
  ld A, L
  rst LBYTE ; DF wysw. L - adr. konca sumy kontr
  defb 22h
  push HL
  ld H, D
  ld L, E
  rst LADR
  defb 44h
  ld hl, CYF2
  set 7, (HL)
  inc HL
  inc HL ; CYF4
  set 7, (HL)
  pop HL
  inc HL
 POB:
  rst 08h ; to jest CF, czekanie na wciœniecie klawisza
  cp 12h ; czy "=" dalej
  jr z, str1
  cp 11h ; "."  cofnij
  jr z, cofnij
  cp 10h ; "G" nowy adres
  jr z, str
  jr pob

 COFNIJ:
  ld bc, 0020h ; lub 0040h gdy przyklad 2 -  : 20 C000 00 ...
  sbc hl, bc
  jr str1

 defb 0DDh, 0E2h ; marker nazwy na LCD
 defm " SUMA HEX INTEL", 255









