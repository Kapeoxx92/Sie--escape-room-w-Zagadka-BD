// Zapytania SELECT:
SELECT * FROM Klient WHERE Czy_znizka = TRUE;
SELECT Nazwa, Tematyka, Poziom_trudnosci FROM Pokoj WHERE  Czas = '01:30:00';
SELECT Imie, Nazwisko FROM Pracownik WHERE Id_escape_room = 1;
SELECT Pracownik.Imie, Pracownik.Nazwisko, Escape_room.Nazwa FROM Pracownik INNER JOIN Escape_room ON Pracownik.Id_escape_room = Escape_room.Id_escape_room WHERE Escape_room.Id_escape_room = 1;
SELECT Klient.Imie, Klient.Nazwisko, Pokoj.Nazwa FROM Rezerwacja INNER JOIN Klient ON Rezerwacja.Id_klient = Klient.Id_klient INNER JOIN Pokoj ON Rezerwacja.Id_pokoj = Pokoj.Id_pokoj WHERE Rezerwacja.Czy_oplacono = FALSE;
SELECT Pokoj.Nazwa, Pokoj.Tematyka, Pokoj.Poziom_trudnosci, Escape_room.Nazwa FROM Pokoj LEFT JOIN Escape_room ON Pokoj.Id_escape_room = Escape_room.Id_escape_room WHERE Escape_room.Id_escape_room = 1;
SELECT Escape_room.Nazwa, COUNT(Pokoj.Id_pokoj) AS Liczba_pokoi FROM Escape_room INNER JOIN Pokoj ON Escape_room.Id_escape_room = Pokoj.Id_escape_room GROUP BY Escape_room.Nazwa HAVING COUNT(Pokoj.Id_pokoj) > 4;
SELECT Czas_gry FROM Sesja WHERE Czy_ucieknieto = TRUE ORDER BY Czas_gry ASC LIMIT 5;
SELECT * FROM Sesja WHERE Id_sesja IN (SELECT Id_sesja FROM Sesja WHERE Liczba_podpowiedzi < 2);
SELECT Imie, Nazwisko FROM Klient WHERE Id_klient IN (SELECT Id_klient FROM Rezerwacja WHERE Id_pokoj IN (SELECT Id_pokoj FROM Pokoj WHERE Tematyka = 'Horror'));

// Liczba pokoi:
SELECT
    e.Id_escape_room,
    e.Nazwa,
    COUNT(p.Id_pokoj) AS Liczba_pokoi
FROM Escape_room e
LEFT JOIN Pokoj p
    ON e.Id_escape_room = p.Id_escape_room
GROUP BY e.Id_escape_room, e.Nazwa;

// Liczba pracowników:
SELECT
    e.Id_escape_room,
    e.Nazwa,
    COUNT(pr.Id_pracownik) AS Liczba_pracownikow
FROM Escape_room e
LEFT JOIN Pracownik pr
    ON e.Id_escape_room = pr.Id_escape_room
GROUP BY e.Id_escape_room, e.Nazwa;

// Widok:
CREATE VIEW Ranking_sesja AS
SELECT Id_sesja, Id_pokoj, Czas_gry, Liczba_podpowiedzi FROM Sesja
INNER JOIN Rezerwacja ON Sesja.Id_rezerwacja = Rezerwacja.Id_rezerwacja
ORDER BY Czas_gry ASC LIMIT 10;

// Funkcja:
CREATE FUNCTION Oblicz_cene (p_Id_pokoj INT, p_Id_klient INT, p_Liczba_uczestnikow INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN (
    SELECT (P.Cena * p_Liczba_uczestnikow * IF(K.Czy_znizka = 1, 0.85, 1.00))
    FROM Pokoj P
    CROSS JOIN Klient K
    WHERE P.Id_pokoj = p_Id_pokoj AND K.Id_klient = p_Id_klient
);

// Procedura:
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

// Trigger:
CREATE TRIGGER Aktualizuj_znizke_klienta
AFTER UPDATE ON Rezerwacja
FOR EACH ROW
UPDATE Klient 
SET Wizyty = Wizyty + 1,
    Czy_znizka = IF(Wizyty + 1 >= 3, TRUE, Czy_znizka)
WHERE Id_klient = NEW.Id_klient 
  AND NEW.Czy_oplacono = TRUE 
  AND OLD.Czy_oplacono = FALSE;


CREATE TRIGGER Przed_Anulowaniem_Rezerwacji
BEFORE UPDATE ON Rezerwacja
FOR EACH ROW
SET NEW.Status = IF(
    NEW.Status = 'Anulowana' AND OLD.Status = 'Aktywna' AND TIMESTAMPDIFF(HOUR, NOW(), OLD.Termin) < 24,
    'Anulowana_Late',
    NEW.Status
);

// Transakcja:
START TRANSACTION;

INSERT INTO Klient (Imie, Nazwisko, Id_kontakt, Wizyty, Czy_znizka) 
VALUES ('Jan', 'Kowalski', 1, 0, FALSE);

INSERT INTO Rezerwacja (Id_klient, Id_pokoj, Termin, Liczba_uczestnikow, Czy_oplacono) 
VALUES (LAST_INSERT_ID(), 1, '2024-07-01 18:00:00', 4, FALSE);

COMMIT;


CREATE PROCEDURE Anuluj_Rezerwacje (IN p_Id_rezerwacja INT)
BEGIN
    UPDATE Rezerwacja 
    SET Status = 'Anulowana' 
    WHERE Id_rezerwacja = p_Id_rezerwacja;
END;
