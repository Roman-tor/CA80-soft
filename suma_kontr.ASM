; suma kontrolna bajtow od <ADR1> do <ADR2>
EXPR:  EQU 0213h ; pobieranie liczb na stos
HILO:  EQU 023Bh ; HL=HL-1 DE=HL?

    ORG 0C000h
   ; program relokowalny!!, mozna wpisac w dowolnym obszarze RAM

suma_kontr: ; suma kontrolna RAM <OD>, <DO>, 4. bajtowa
  ld SP, 0FF66h ; stos
  ld hl, 0EEEh ; "EEE" na wysw. CA
  rst 20h ; E7 wysw. HL
  defb 35h
 suK:
  rst 10h ; D7
  defb 40h
  ld IX, 0
  ld BC, 0
  push IX
  ld C, 2 ; dwa parametry
  call EXPR ; pobierz dwa adresy, od i do
  defb 40h
  pop DE
  pop HL
 suk1:
  ld c, (HL)
  add IX,  BC
  call HILO
  jr nc, suk1
  push IX
  pop HL
  rst 20h ; wysw. HL
  defb 40h 
  rst 8 ; CF czekaj na klaw
  jr suK 
