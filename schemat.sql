CREATE DATABASE Zagadka;
USE Zagadka;
SET NAMES 'utf8mb4';
SET CHARACTER SET utf8mb4;


CREATE TABLE Miasto (
    Id_miasto INT PRIMARY KEY AUTO_INCREMENT,
    Nazwa VARCHAR(32) NOT NULL
);

CREATE TABLE Adres (
    Id_adres INT PRIMARY KEY AUTO_INCREMENT,
    Ulica VARCHAR(32) NOT NULL,
    Nr_budynku INT NOT NULL,
    Kod_pocztowy VARCHAR(6) NOT NULL UNIQUE
        CHECK (Kod_pocztowy REGEXP '^[0-9]{2}-[0-9]{3}$'),
    Id_miasto INT NOT NULL,
    CONSTRAINT fk_adres_miasto
        FOREIGN KEY (Id_miasto) REFERENCES Miasto(Id_miasto)
);

CREATE TABLE Kontakt (
    Id_kontakt INT PRIMARY KEY AUTO_INCREMENT,
    Nr_telefonu VARCHAR(9) NOT NULL UNIQUE
        CHECK (Nr_telefon REGEXP '^[0-9]{9}$'),
    Adres_email VARCHAR(64) NOT NULL UNIQUE
        CHECK (Adres_email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
);

CREATE TABLE Escape_room (
    Id_escape_room INT PRIMARY KEY AUTO_INCREMENT,
    Nazwa VARCHAR(32) NOT NULL,
    Id_adres INT NOT NULL,
    Id_kontakt INT NOT NULL,

    FOREIGN KEY (Id_adres) REFERENCES Adres(Id_adres),
    FOREIGN KEY (Id_kontakt) REFERENCES Kontakt(Id_kontakt)
);

CREATE TABLE Pracownik (
    Id_pracownik INT PRIMARY KEY AUTO_INCREMENT,
    Imie VARCHAR(16) NOT NULL,
    Nazwisko VARCHAR(32) NOT NULL,
    Id_kontakt INT NOT NULL,
    Id_adres INT NOT NULL,
    Id_escape_room INT NOT NULL,

    FOREIGN KEY (Id_kontakt) REFERENCES Kontakt(Id_kontakt),
    FOREIGN KEY (Id_adres) REFERENCES Adres(Id_adres),
    FOREIGN KEY (Id_escape_room) REFERENCES Escape_room(Id_escape_room)
);

CREATE TABLE Pokoj (
    Id_pokoj INT PRIMARY KEY AUTO_INCREMENT,
    Id_escape_room INT NOT NULL,
    Nazwa VARCHAR(32) NOT NULL,
    Tematyka VARCHAR(32) NOT NULL,
    Poziom_trudnosci INT NOT NULL DEFAULT 3
        CHECK (Poziom_trudnosci BETWEEN 1 AND 5),
    Max_liczba_graczy INT NOT NULL,
    Czas TIME NOT NULL,
    Cena DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (Id_escape_room) REFERENCES Escape_room(Id_escape_room),

    CHECK (Czas IN ('01:00:00', '01:30:00'))
);

CREATE TABLE Klient (
    Id_klient INT PRIMARY KEY AUTO_INCREMENT,
    Imie VARCHAR(16) NOT NULL,
    Nazwisko VARCHAR(32) NOT NULL,
    Id_kontakt INT NOT NULL,
    Wizyty INT NOT NULL DEFAULT 0,
    Czy_znizka BOOLEAN NOT NULL DEFAULT FALSE,

    FOREIGN KEY (Id_kontakt) REFERENCES Kontakt(Id_kontakt)
);

CREATE TABLE Rezerwacja (
    Id_rezerwacja INT PRIMARY KEY AUTO_INCREMENT,
    Id_klient INT NOT NULL,
    Id_pokoj INT NOT NULL,
    Termin DATETIME NOT NULL,
    Liczba_uczestnikow INT NOT NULL,
    Czy_oplacono BOOLEAN NOT NULL DEFAULT FALSE,
    Status VARCHAR(16) NOT NULL DEFAULT 'Aktywna',
    
    CONSTRAINT chk_status CHECK (Status IN ('Aktywna', 'Anulowana', 'Anulowana_Late')),    
    FOREIGN KEY (Id_klient) REFERENCES Klient(Id_klient),
    FOREIGN KEY (Id_pokoj) REFERENCES Pokoj(Id_pokoj)
);

CREATE TABLE Sesja (
    Id_sesja INT PRIMARY KEY AUTO_INCREMENT,
    Id_rezerwacja INT NOT NULL,
    Id_pracownik INT NOT NULL,
    Czy_ucieknieto BOOLEAN NOT NULL DEFAULT TRUE,
    Czas_gry TIME NOT NULL,
    Liczba_podpowiedzi INT NOT NULL DEFAULT 0,

    FOREIGN KEY (Id_rezerwacja) REFERENCES Rezerwacja(Id_rezerwacja),
    FOREIGN KEY (Id_pracownik) REFERENCES Pracownik(Id_pracownik),

    CHECK (Czas_gry <= '01:30:00')
);
