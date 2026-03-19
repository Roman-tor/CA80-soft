
 PRINT:       EQU 01D4H ; wyœwietla tekst wg (HL), + PWyœw np. CD D4 01 44
 KO3:         EQU 0A23h ; adres komunikatu "ERROR"
 CLR:         EQU 10h ; czyszczenie wyswietlacza
 CO:          EQU 01E0h;
 EXPRW:       EQU 19B4h; j.w. ale tylko cyfry dziesietne
 LCI:         EQU 0FFE8h ; liczenie do tylu, -1 co 2 ms
 CZASK:       EQU 1225h  ; Wysw. MIES/DZIEN np. 5  09 na PWYS 63
 TI1:         EQU 8
 LADR:        EQU 20h    ;wyswietlenie HL w postaci 4. liczby
 TABM:        EQU 32Dh   ; tabela ograniczen miesiecy
 TABD:        EQU 123Fh  ; tabl. dni, symbole literowe, np. PN, WT CA88
 WYSKOM:      EQU 1217h  ; procedura wysw. dnia tyg. z CA88
 DATA_M:      EQU 0FE10h ; pamiec pobranej daty
 DATA_W:      EQU 0FE20h  ; wzorzec daty do obiczen dnia tygodnia
  
   ;  - eliminacja dni 5.10.1582 -14.10.1582 - zmiana kalendarza na gregorianski
   ; uwzglednia tez lata nieprzestepne: 1700, 1800, 1900, 2100                          

              ; kalendarz wyswietla: m-c, dzien, dzien tygodnia,= lub G to rok
              ;[rok] [.] [m-c] [dzien] [=]
             
; kalendarz wieczny,  wylicza dzien tygodnia wg zadanej daty
; bazowalem na kalendarzu wg S. Gardynika, eleminujac niewielkie bledy w nim zawarte, przy
; wyliczaniu dnia tygodnia
; Oblicza i wyswietla dzien tygodnia w postaci
; symbolicznej /PN, WT itd/ dla lat od 1 do 9999 r., nie bylo roku 0000 /SK/
; #d[ROK][.][MIESIAC][.][DZIEN MIES][=]
; kazdy nastepny rok ZWIEKSZA dzien tygodnia o 1, jesli rok przestepny to o 2
; kazde stulecie ZMNIEJSZA dzien tygodnia o 1 ; jesli przestepny to o 2
; np. 1.1.1999.to piatek, 1.1.2000 to  sobota, 1.1.2001 - poniedzialek, a 1.1.2002 to wtorek
; 1.1.1583 to sobota / brak dni 5-14.10.1582 !!! zmiana kalendarza na gregorianski
; 15.7.1410-bitwa pod Grunwaldem to wtorek
; upadek Konstantynopola 29.5.1453 wtorek
; lata podzielne przez 4 beda przestepne, z wyjatkiem
; tych niepodzielnych przez 400 (lata 1600, 2000, 2400 itd beda w kalendarzu
; gregorianskim przestepne, a 1700, 1800, 1900, 2100, 2300 itd nie).
; przy sprawdzaniu poprawnosci obliczen bazowalem na programie K. Borkowskiego z UMK Torun
; https://www.astro.uni.torun.pl/~kb/Efemerydy/JulianDay.htm
; 1.1.1600 - sobota
; 1.1.1700 - piatek
; 1.1.1800 - sroda
; 1.1.1900 - poniedz
; 1.1.2000 - sobota

         ORG #C000 ; oryginal programu z C800 /MIK 11 str. 161, teraz po moich przerobkach
UD:  ld HL, wzor_dr1; wzorzec daty 1.1.0001 to sobota lub 1.1.1583 to sobota
     ld DE, DATA_W ; wzor daty w RAM
     ld BC, 8
     LDIR
     ld HL, r_r
     call print
     defb #80
     ld B, 10
     call U4X ; opoznienie ok. 1 sek
   UD1X:
     RST     CLR
     DEFB     80H
     LD     C,0DH     ;Nr zlecenia
     CALL     CO
     DEFB     17H
     LD     C,3     ;3 parametry
     CALL     EXPRW     ;Tylko cyfr. dziesietne
     DEFB     40H
     LD     HL,DATA_M     ;Pamiec daty
     POP     DE
     LD     (HL),E     ;Dzien miesiaca
     POP     DE
     INC     HL
     LD     (HL),E     ;Miesiac
     POP     HL
     LD     (DATA_M+2),HL ;Rok zadany
     ld A, H ; zapamietaj stulecie do wysw. daty
     push AF
     call kor_r ; korekcja roku, c0 400 lat sa tre same dni tygodnia,
                ; wiec np. zamien rok 20xx na 16xx
     push HL               
     call spr5_14 ; czy data lezy miedzy 5 - 14 pazdzier 1582 blad
     OR     A     ; CY=0 wazne !!
     ld HL, #1582
     ld DE, (DATA_M+2) ; rok zadany
     sbc HL, DE
     pop HL
     jr nC, UD1A ; rok zadany <= od 1582, wzor daty 1.1.0001, sobota
       ; rok zadany >= 1583
     ld BC, (wzor_DR1+6) ; C=6 -sobota, B = 1- bo do nast. roku przest. zostal 1. rok
     ld DE, (wzor_DR1+4) ;1583 r.
     jr UD1A1 
 UD1A:   ; do 4.10.1582 dni tygodnia beda prawidlowe wg ponizszego wzoru 
     LD     BC, (wzor_DR1+2) ;C=6 ;B=3 bo nastepny rok przestep za 3 lata, C=6 - sobota
     LD     DE,(wzor_DR1) ; rok odniesienia 0001
UD1A1:     ld     A, (DATA_M+3)  ; stulecie
     cp #20
     jr C, UD1 ; stulecie < 20
     ld BC, (wzor_DR1+10)
     ld DE, (wzor_DR1+8)          
 UD1:    CALL     SROK     ; szukanie roku
     LD     DE,(DATA_M) ; E - dzien, D - miesiac
     CALL     SDZIEN     ; szukanie dnia
     JR     Z,U4A     ; dzien znaleziono
;Error - data falszywa
UD1_ERR:     LD     HL,KO3     ;Error
     CALL     PRINT
     DEFB     50H
;Opoznienie 0.7 sek
     LD     B,7
U4X:     CALL     DEL100
     DJNZ     U4X
     JR     UD1X
;Wyswietlenie znalezionego dnia
;WE: C - dzien tygodnia (1-Pn,2-Wt,3-Sr....)
U4A: 
     pop AF  ; odtworz zadane stulecie 
     ld (DATA_M+3), A
     call spr_NP ; sprawdz czy  nieprzestepny
     LD     HL,TABD     ;Tabl. dni tygodn.
     LD     A,C
     DEC    A
     ADD    A,A     ;A*2
     ADD    A,L
     LD     L,A     ;Adr. dnia
     CALL     WYSKOM     ;Wysw.dnia tygodn. np. "So" na PWYS-20
U4B:     RST     CLR
     DEFB   62H
     LD     HL,DATA_M     ;Zadana data
     CALL   CZASK     ;Wysw. MIES/DZIEN np. 5  09 na PWYS 63
CZEK:     RST     TI1  ;                  " 5 09 So"
     CP     11H     ;SPAC ?
     JP     Z,UD     ;Powtorzenie
     RST    CLR
     DEFB   62H
     LD     HL,(DATA_M+2) ;ROK  , np. "2024   So"
     RST    LADR
     DEFB   44H
     RST    TI1
     CP     11H
     jp   Z,UD
     JR     U4B
; SROK - szukanie roku
; 0001.01.01 - SOBOTA - dzien odniesienia
; 0001 - rok nieprzestepny, 1700, 1800, 1900, 2100, 2300, 2500 tez
; 365 dni - rok normalny
; 366 dni - rok przestepny co 4 lata
; 52tygodnie * 7 = 364 dni
; WE: DATA+2 - etykieta wskazujaca zadany rok
; HL = zadany rok
; WY: C - dzien tygodnia w dniu 1 stacznia
;    B = co 4. lata - rok przestepny
SROK:     
     OR     A     ;CY=0
     SBC    HL,DE
     RET    Z     ;Zad.rok=0000
;ROK ZADANY > 0000
     nop ;INC    C     ;0000 - przestepny
P0001:     LD     A,E ; jednosci i dziesiatki lat
     ADD    A,1
     DAA
     LD     E,A
     LD     A,D ; setki i tysiace lat
     ADC    A,0     ;Dodanie CY
     DAA
     LD     D,A
     LD     HL,(DATA_M+2) ;Rok zadany
     INC    C     ;Rok normalny
     LD     A,C
     CP     8
     JR     C,P2A
     LD     C,1     ;Poniedzialek
P2A:     DEC     B     ;Czy rok przestepny ?
     JR     NZ,P2C     ;Nie
     LD     B,4     ;Rok przestepny
     OR     A     ;CY=0
     SBC    HL,DE
     RET    Z     ;Rok przestepny
     INC    C
     LD     A,C     ;Dzien tygodnia
     CP     8
     JR     C,P2B
     LD     C,1     ;Poniedzialek
P2B:     JR     P0001     ;Nastepny rok
P2C:     OR     A     ;CY=0
     SBC    HL,DE
     JR     NZ,P0001 ;Nastepny rok
     ; rok znaleziony
     RET
 ;===========
;SDZIEN - szukanie dnia tygodnia w roku
;WE: B= pozostalosc z poprzednich obliczen po dodawaniu lat 
;    C   - dzien tygodnia w dniu 1 stycznia
;    E   - dzien zadany
;    D   - miesiac zadany
;WYJ: C   - znaleziony dzien tygodnia
;    Z=0 - Error (rej.C - nieokreslony)
;ZMIENIA: HL,C,AF
SDZIEN:     LD     A,B; pozostalosc po dodawaniu lat
     CP     4     ; czy rok przestepny ?
     JR     NZ,NPRZE
; rok przestepny
     LD     A,D     ; miesiac zadany
     CP     3
     CALL   NC,INCC ; miesiac 3-12
     CP     2     ; czy luty ?
     JR     NZ,NPRZE ; nie luty
     LD     A,E     ; zadany dzien
     CP     29H      ; czy 29 luty
     JR     NZ,NPRZE
;Zadany dzien 29 luty
     call spr_luty ; w 1700, 1800, 1900, 2100 luty nie byl przestepny !
     LD     B,3     ;Dodanie 3 dni
 LICZD:     CALL     INCC
     DJNZ   LICZD
     RET          ;Z=1 dobrze
NPRZE:     LD     HL,TABM
     LD     B,1     ;Licznik miesiecy
NASA:     LD     A,1     ;Licznik dni
 DNAST:    CP     E
     JR   NZ,DNA
    ; dzien zgodny
     PUSH   AF     ;Ochrona dnia
     LD     A,B     ;Miesiac biezacy
     CP     D     ;D-miesiac zadany
     JR     NZ,NZG
     POP    AF
     RET          ;Z=1 dobrze
NZG:     POP     AF     ;Dzien biezacy
 DNA:     OR     A     ;CY=0
     INC    A
     DAA
     call spr_X_1582 ; pazdziernik 1582
     CALL   INCC
     CP     (HL)     ;Ost. dzien mies ?
     JR     C,DNAST ;Nastepny dzien
     LD     A,B
     INC    A
     DAA
     LD     B,A     ;Biezacy miesiac
     INC    HL     ;Nastepny miesiac
     LD     A,39H     ;Str.21 w MIK08
     CP     (HL)     ;mies 13 !!
     JR     NZ,NASA
     OR     A
     RET          ;Z=0 Error
;INCC - zwiekszenie dni tygodnie w rej. C
INCC:     PUSH     AF
     INC    C
     LD     A,C
     CP     8
     JR     C,INC1
     LD     C,1     ; poniedzialek
INC1:     POP     AF
     RET
;Opoznienie 100 msek
DEL100:     PUSH     BC
     LD     B,10
DEL22:     CALL     DEL10     ;10 mSEK
     DJNZ   DEL22
     POP    BC
     RET

spr_NP: ; 1700, 1800, 1900, 2100, 2300 to lata nieprzestepne !
     ;ld A, D
     ld DE, 3 ; E = 3- marzec, D = 0 dziesiatki i jednosci lat czyli koniec stulecia
     ld A, (DATA_M+3) ; stulecie, np. 17xx, 18xx itd
     ld B, 1
     cp #17 ; 1700 
     jr z, decc1_1 ; B = 1
     inc B
     cp #18
     jr z, decc1_1 ; B = 2
     inc B
     cp #19
     jr z, decc1_1 ; B = 3
;     cp #20
;     jr z, decc20 ; B = 3 gdy miesiac >= 3 lub B = 4 gdy styczen i luty 
;    
;     cp #21 ; 1.1.2100 to piatek
;     jr z, decc21 ; B = 7
     
     ret ; powrot z procedury <spr_NP> jesli jesli lata inne niz 1700, 1800.. j.w.

         ; 1700 nie byl przestepny         
 decc1_1:  ld A, C
 decc1_2:  dec A
          jr nz, decc1_3
          ld A, 7 ; dni liczone 1-PN, 2-WT...7-ND
 decc1_3: 
          djnz decc1_2
               ; jesli styczen lub luty, zwieksz C- dzien tygodnia
          or A ; CY = 0
          ld HL, (DATA_M + 1) ; H = rok zadany, L = miesiac zadany
          sbc HL, DE
          ld C, A
          ret nc ; miesiac > 3 
          ; styczen lub luty
 decc1_20:    inc A
          ld C, A
          cp 8
          ret nz 
          ld C, 1
          ret ; powrot z procedury <spr_NP>

decc20:   ld A, C
          jr decc1_20
    

  decc21:    ; OK od 2100 do 28.2.2200
  ld B,7
  jr decc1_1

spr5_14:  ; jesli data miedzy 5-14.10.1582 to blad
   ; w HL rok zadany
  or A
  ld DE, #1582
  sbc Hl, DE
  ret nz
  ld A, (DATA_M+1) ; miesiac zadany
  cp #10 ; czy pazdziernik
  ret nz
  ld A, (DATA_M) ;  dzien zadany
  cp #15 ; nie ma dni 5-14.10
  ret nc ; dzien >= 15
   ; dzien < od 15
 spr5_1:
  cp 5
  ret c ; dzien <= 4 ; jest OK
 spr5_1a:
  jp UD1_Err ; error

spr_luty:
   exx
   ex AF,AF'

   or A ; CY = 0 wazne przy sbc !!
   ld HL, #1700
   ld DE, (DATA_M+2) ; rok zadany
   sbc HL, DE
   jr z, spr5_1a

   or A
   ld HL, #1800
   sbc HL, DE
   jr z, spr5_1a

   or A
   ld Hl, #1900
   sbc HL, DE
   jr z, spr5_1a
   ex AF, AF'
   exx
   ret

spr_X_1582: ; jesli 5.10.1582 to zwieksz dzien na 15
    ; A - aktualny dzien
   cp 5
   ret nz
     ; sprawdz miesiac, jest w D, czy pazdziernik
   ld IXL, A ; ochrona dnia miesiaca
   ld A, B ; B - aktualnie obliczany miesiac
   cp #10
   ld A, IXL
   ret nz
   exx ; ochrona HL, DE, BC
   or A
   ld HL, (DATA_M+2)
   ld DE, #1582
   sbc HL, DE
   exx
   ret nz
   ld A, #15
   ret 
  ; w kalendarzu gregorianskim, co 400 lat dni tygodnia
  ; w roku sa identyczne ! np. w 1600 - 2000 - 2400,
  ; 1700 - 2100 - 2500 itd, 1800 - 2200 - 2600 itd, 1900 - 2300 - 2700 itd
  ; i to wykorzystamy do obliczen lat do 9999 ! czy swiat bedzie jeszcze istnial ???
  
kor_r:  ; sprawdz rok i skoryguj zadany rok na czas obl. procedury <SROK>   
   ld A,(DATA_M+3) ; stulecie
   cp #20
   ret C
  kor_r1:
   sub 4 ; "400" lat
   daa
   cp 4
   jr nc, kor_r1
       ; A - ile dodac do 16xx i ten rok wprowadz jako zadany
   ld C, #16
   add A, C
   daa
   ld (DATA_M+3), A
   ret
      
;Opoznienie ok. 10 msek
DEL10:     LD     A,5     ;5*2msek=10msek
     LD     (LCI),A
 DE11:     LD     A,(LCI)
     OR     A
     JR     NZ,DE11
     RET
     
wzor_dr1:     defb 1,0,6,3,83h,15h,6,1,0,20h,6,4 
   ; komunikaty na CA80
r_r:          defb #50, #50, #50, #D0,  ; r r r r. -rok
dd:           defb #5E, #DE, ;          ; d d.     - dzien
mm:           defb #54, #D4, 255        ; nn.      - miesiac 
 defb 0DDh, 0E2h ; DDE2 - marker nazwy programu, jesli mamy LCD i magazyn programow np. 
      ; https://github.com/Roman-tor/programy-magazyn-w-CA80/blob/main/1.README.md
 defm " KALENDARZ WIECZNY",255 ; nazwa programu

