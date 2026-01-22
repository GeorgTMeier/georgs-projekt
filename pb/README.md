# PostgreSQL Grid Editor (PureBasic)

Ein PureBasic-Programm zum Bearbeiten von PostgreSQL-Datenbanken in einem Grid-Format.

## Voraussetzungen

- PureBasic (Version 5.70 oder höher empfohlen)
- PostgreSQL-Datenbank mit Zugriff
- PostgreSQL-Bibliothek in PureBasic aktiviert

## Kompilierung

1. Öffnen Sie die Datei `PostgresGridEditor.pb` in PureBasic
2. Stellen Sie sicher, dass die PostgreSQL-Bibliothek aktiviert ist (Compiler → Bibliotheken → Database)
3. Kompilieren Sie das Programm (F5 oder Compiler → Kompilieren)

## Verwendung

1. Starten Sie das Programm
2. Im Verbindungsdialog geben Sie ein:
   - **Host**: PostgreSQL-Server-Adresse (Standard: 127.0.0.1)
   - **Port**: PostgreSQL-Port (Standard: 5432)
   - **Datenbank**: Name der Datenbank
   - **Benutzer**: PostgreSQL-Benutzername
   - **Passwort**: Passwort für den Benutzer
3. Klicken Sie auf "Verbinden"
4. Wählen Sie eine Tabelle aus dem Dropdown-Menü aus
5. Die Daten werden automatisch im Grid angezeigt

## Funktionen

- **Verbinden**: Neue Datenbankverbindung herstellen
- **Aktualisieren**: Daten aus der aktuellen Tabelle neu laden
- **Neu**: Neue leere Zeile zum Grid hinzufügen
- **Löschen**: Ausgewählte Zeile aus der Datenbank löschen
- **Speichern**: Änderungen an der ausgewählten Zeile speichern

## Bearbeitung

- **Zellen bearbeiten**: Doppelklicken Sie auf eine Zelle oder wählen Sie sie aus und drücken Sie Enter
- **Zeile speichern**: Nach der Bearbeitung auf "Speichern" klicken
- **Neue Zeile**: Klicken Sie auf "Neu", füllen Sie die Felder aus und speichern Sie

## Hinweise

- Die erste Spalte wird als Primary Key verwendet
- Es werden maximal 1000 Zeilen geladen
- Änderungen werden sofort in die Datenbank geschrieben
- Löschvorgänge erfordern eine Bestätigung

## Fehlerbehebung

- **Verbindungsfehler**: Überprüfen Sie Host, Port, Datenbankname, Benutzer und Passwort
- **Tabellen nicht sichtbar**: Stellen Sie sicher, dass die Tabelle im Schema "public" liegt
- **Speichern fehlgeschlagen**: Überprüfen Sie die Datentypen und Constraints der Tabelle
