Problem klienta:
Pan Tomek ma 3 lokalizacje escape roomów w Warszawie, Gdańsku i Poznaniu. Każda
lokalizacja ma kilka pokoi o różnej tematyce.

Wymagania klienta:

"Mam 3 lokalizacje, w każdej 2-4 pokoje. Każdy pokój ma: nazwę, tematykę,
poziom trudności (1–5), maksymalną liczbę graczy, czas na rozwiązanie (zwykle
60 lub 90 min) i cenę.
Klienci rezerwują pokój na konkretną datę i godzinę. Rezerwacja jest na zespół -
jedna osoba rezerwuje i podaje ile osób przyjdzie (od 2 do 6). Muszę wiedzieć
kto rezerwował, kontakt, na kiedy, ile osób, i czy zapłacono (płatność z góry lub
na miejscu).
Po grze zapisuję wynik: czy zespół uciekł (tak/nie), w jakim czasie, i ile
podpowiedzi użył. To jest ważne, bo prowadzę ranking - najlepsze czasy w
każdym pokoju. Chcę widzieć TOP 10 dla każdego pokoju.
Mam też pracowników - każdy jest przypisany do lokalizacji. Game masterzy
prowadzą gry - chcę wiedzieć kto prowadził którą sesję.
Stali klienci (3+ wizyty) powinni dostawać 15% zniżki. Chciałbym łatwo widzieć
kto się kwalifikuje.
Jeśli klient odwoła rezerwację mniej niż 24h przed terminem - chcę to wiedzieć,
ale nie chcę kasować rezerwacji, tylko oznaczyć jako anulowaną."

![Diagram ERD](Zagadka.png)

Dlaczego jest w schemacie 3NF?
Spełnia warunek 1NF, czyli:
- ma klucz główny,
- pola zawierają pojedyncze wartości (nie ma list w jednej kolumnie),
- nie ma grup powtarzających się.
- Każda komórka przechowuje jedną wartość.

Spełnia warunek 2NF, czyli:
- brak zależności częściowych od klucza głównego, to znaczy, że każda kolumna niebędąca kluczem musi zależeć od całego klucza głównego

Spełnia warunek 1NF, czyli:
- rak zależności przechodnich, to oznacza, że kolumny niebędące kluczem nie mogą zależeć od innych kolumn niebędących kluczem

Rozwiązanie pokoi:
Stworzenie tabeli "Pokoj" z kolumnami: Id_pokoj, Id_escape_room, Nazwa, Tematyka, Poziom_trudnosci(z ograniczeniem CHECK, sprawdzającym czy wartości mieszczą się w przedziale 1-5), Max_liczba_graczy, Czas( ograniczeniem CHECK, sprawdzającym czy wartości to 01:00:00 lub 01:30:00 i Cana
