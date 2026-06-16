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

Spełnia warunek 3NF, czyli:
- brak zależności przechodnich, to oznacza, że kolumny niebędące kluczem nie mogą zależeć od innych kolumn niebędących kluczem

Rozwiązanie pokoi:

Stworzenie tabeli "Pokoj" z kolumnami: Id_pokoj, Id_escape_room(z kluczem obcym pokazującym, do jakiego escape roomu należy pokój), Nazwa, Tematyka, Poziom_trudnosci(z ograniczeniem CHECK, sprawdzającym czy wartości mieszczą się w przedziale 1-5), Max_liczba_graczy, Czas( ograniczeniem CHECK, sprawdzającym czy wartości to 01:00:00 lub 01:30:00) i Cana

Rezerwacje pokoi + możliwość zobaczenia, czy klient odwołał rezerwację poniżej 24h:

Stworzenie tabeli "Rezerwacje" z kolumnami: Id_rezerwacja, Id_klient(z kluczem obcym wskazującym do jakiego klienta należy rezerwacja), Id_pokój(z kluczem obcym pokazującym którego pokoju należy rezerwacja), Termin, Liczba_uczestników, Czy_zapłacono(z DEFAULT ustawiającym domyśnie pole na FALSE) i Status(pokazującym jaki status ma rezerwacja z domyślną wartością "Aktywna" i z polem CHECK, czy wartość pola to "Aktywna", "Anulowana" lub "Anulowana_Late"(gdy klient anuluje rezerwację poniżej 24h)

Wyniki po grze:

W  tym celu stworzyłem tabelę "Sesja" z kolumnami: Id_Sesja, Id_rezerwacja(z kluczem obcym pokazującym, do której rezerwacji należy dana gra), Id_pracownik(z kluczem obcym wskazującym na pracownika, który obsługiwał daną grę), Czy_ucieknięto(pokazującym czy grupie udało się uciec czy nie) i polem polem DEFAULT z domyślną wartością TRUE, Czas_gry z polem CHECK(sprawdzającym, czy grupa uciekła w maksymalnie 1,5h, inaczej pole ma wartość maksymalną, czyli 01:30:00, i Czy_ucieknięto ma wartość FALSE) i Liczba_podpowiedzi

Rozwiązanie pracowników:

Stworzenie tabeli "Pracownik" z kolumnami: Id_pracownik, Imie, Nazwisko, Id_kontakt(z kluczem obcym połączonym z tabelą "Kontakt" wskazującym na numer telefonu i adres e-mail danego pracownika), Id_adres(z kluczem obcym połączonym z tabelą "Adres" wskazującym ulicę,  numer budunku, kod pocztowy i id miasta danego pracownika) oraz Id_escape_room(z kluczem obcym pokazującym id escape roomu, do którego należy pracownik)

Stali klienci:

W tabeli "Klient" dodałem kulumny Wizyty(zliczającą wynik o 1 po każdej Sesji)

 Widok:
 
CREATE VIEW Ranking_sesja AS
SELECT Id_sesja, Id_pokoj, Czas_gry, Liczba_podpowiedzi FROM Sesja
INNER JOIN Rezerwacja ON Sesja.Id_rezerwacja = Rezerwacja.Id_rezerwacja
ORDER BY Czas_gry ASC LIMIT 10;


Funkcja:

CREATE FUNCTION Oblicz_cene (p_Id_pokoj INT, p_Id_klient INT, p_Liczba_uczestnikow INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN (
    SELECT (P.Cena * p_Liczba_uczestnikow * IF(K.Czy_znizka = 1, 0.85, 1.00))
    FROM Pokoj P
    CROSS JOIN Klient K
    WHERE P.Id_pokoj = p_Id_pokoj AND K.Id_klient = p_Id_klient
);

Procedura:

CREATE PROCEDURE Dodaj_rezerwacje (IN p_Id_klient INT, IN p_Id_pokoj INT, IN p_Termin DATETIME, IN p_Liczba_uczestnikow INT)
DETERMINISTIC
BEGIN
    INSERT INTO Rezerwacja (Id_klient, Id_pokoj, Termin, Liczba_uczestnikow, Czy_oplacono) 
    VALUES (p_Id_klient, p_Id_pokoj, p_Termin, p_Liczba_uczestnikow, FALSE);
    
    UPDATE Klient 
    SET Wizyty = Wizyty + 1,
        Czy_znizka = IF(Wizyty + 1 >= 3, TRUE, Czy_znizka)
    WHERE Id_klient = p_Id_klient;
END;

Trigger:

CREATE TRIGGER Aktualizuj_znizke_klienta
AFTER UPDATE ON Rezerwacja
FOR EACH ROW
UPDATE Klient 
SET Wizyty = Wizyty + 1,
    Czy_znizka = IF(Wizyty + 1 >= 3, TRUE, Czy_znizka)
WHERE Id_klient = NEW.Id_klient 
  AND NEW.Czy_oplacono = TRUE 
  AND OLD.Czy_oplacono = FALSE;

Transakcja:
START TRANSACTION;

INSERT INTO Klient (Imie, Nazwisko, Id_kontakt, Wizyty, Czy_znizka) 
VALUES ('Jan', 'Kowalski', 1, 0, FALSE);

INSERT INTO Rezerwacja (Id_klient, Id_pokoj, Termin, Liczba_uczestnikow, Czy_oplacono) 
VALUES (LAST_INSERT_ID(), 1, '2024-07-01 18:00:00', 4, FALSE);

COMMIT;
