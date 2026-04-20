# NamesNsf – Notes Personendatenbank-Viewer

C# Windows Forms-Anwendung, die Personendatensätze aus einer IBM Notes/Domino-Datenbank (`names.nsf`) liest und in einem DataGrid anzeigt.

## Anforderungen

- **Visual Studio 2019 oder 2022** (mit .NET Desktop-Entwicklung)
- **.NET Framework 4.8**
- **Lotus Notes Client** oder **HCL Domino Server** auf dem Rechner, auf dem die Anwendung ausgeführt wird (für die COM-Interop-API)

## Projekt öffnen

1. `NamesNsf.sln` in Visual Studio öffnen
2. Projekt bauen (Strg+Shift+B)

## COM-Referenz (falls nötig)

Die Projektdatei enthält eine COM-Referenz auf die Domino Objects. Wenn beim Build Fehler zu fehlenden Domino-Referenzen auftreten:

1. Rechtsklick auf das Projekt → **Hinzufügen** → **COM-Verweis**
2. „Lotus Domino Objects“ oder „IBM Notes Domino Objects“ auswählen
3. Bestätigen

## Verwendung

1. Anwendung starten (F5)
2. Servername ist standardmäßig **Hektor** (änderbar)
3. Optional: Notes-Passwort eingeben (bei Single-Sign-On ggf. leer lassen)
4. Auf **Laden** klicken

Die Personendatensätze aus der `$People`-View werden geladen und in der Tabelle angezeigt.

## Anzeige-Felder

- Vollständiger Name  
- Vorname  
- Nachname  
- Kurzname  
- Mail-Datei  
- Internet-Adresse  
- Bürotelefon  
- Ort  

## Server und Datenbank

- **Server:** Hektor (im Toolbar-Feld änderbar)  
- **Datenbank:** `names.nsf` (Domino Directory auf dem Server)

## Hinweise

- Die Notes-COM-API muss auf dem Rechner verfügbar sein (Lotus Notes Client installiert).
- Netzwerkzugriff auf den Domino-Server (z. B. Hektor) erforderlich.
- ACL-Rechte: Das Notes-Client-Konto muss Lesezugriff auf die Server-`names.nsf` haben.
