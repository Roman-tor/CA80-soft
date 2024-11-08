w tym repozytorium będę zamieszczał /sukcesywnie/ programy do mikrokomputera CA80 na bazie procesora Z80
 
 program DS18B20 with Z80_for CA80 w assemblerze działa w kompilatorze Aside /DE/, również w innych, po stosownym dopasowniu składni
był przystosowany do dwóch czujników DS - linie programu (nie komentarzy!) na początku których są ";" należy wówczas skasować
opis portów układu 8255 - w MIK 05 p. S. Gardynika

ASide można ściągnąć z
http://www.theeg.de/aside/index.html - wersja niemiecka Shareware

program wyswietla dane też na LCD 20x4, LCD podłączone bezpośrednio do CA, schemat podłączenia w LCD_direct1, autorstwa kol. ZEGAR i mojej 

w mojej wersji uruchomiony na CA80 - mini komputerze, stworzonym w latach 80 ub. wieku przez p. Stanisława Gardynika

do prawidłowego działania, wymagane jest blokowanie przerwań NMI na niewielki czas podczas zapisywania danych do DS18B20

