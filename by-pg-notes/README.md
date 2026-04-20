# by-pg-notes

LotusScript-Migration des Projekts **by-pg-grid**: PostgreSQL-Zugriff über ODBC aus HCL Notes/Domino – test2view laden, Datensätze mit gleicher Art anzeigen, Summe Betrag, Preview-Felder, Speichern/Update buchpos.

## Voraussetzungen

- HCL Notes (Client) oder Domino (Server) mit **LSX ODBC** (Standard in Notes)
- **PostgreSQL ODBC-Treiber** (z. B. „PostgreSQL Unicode“ oder „PostgreSQL ANSI“) auf dem Rechner/Server installiert
- **ODBC-Datenquelle (DSN)** oder Connection-String für die Datenbank RK2 (Host 192.168.207.160, Port 5432, User postgres, DB RK2)

## Einrichtung

1. **ODBC-DSN anlegen** (Windows: Systemsteuerung → Verwaltung → ODBC-Datenquellen; bei 32-Bit-Notes den 32-Bit-DSN in SysWOW64 verwenden):
   - Treiber: PostgreSQL Unicode (oder Ihr installierter Treiber)
   - Server: 192.168.207.160
   - Port: 5432
   - Datenbank: RK2
   - Benutzer/Kennwort: postgres / (Ihr Passwort)
   - DSN-Name z. B.: `PG_RK2`

2. **Notes-Datenbank anlegen**
   - Neue Datenbank erstellen (z. B. `bypgnotes.nsf`) oder eine bestehende nutzen.

3. **Script Library einbinden**
   - In der Datenbank: Erstellen → Design → Script-Bibliothek, Name z. B. `PGData`.
   - In der Bibliothek den Inhalt von `ScriptLib_PGData.lss` einfügen und speichern.

4. **Formular „MainPG“ anlegen**
   - Formular mit den unten beschriebenen Feldern und Buttons anlegen (siehe Abschnitt „Formular und Felder“).
   - Im Formular die Script-Bibliothek `PGData` einbinden (Eigenschaften des Formulars → Optionen → Script-Bibliotheken).

5. **Agenten anlegen**
   - Agent „LoadData“: Auslöser z. B. „Nach dem Öffnen eines Dokuments“ oder „Manuell“; Code aus `Agent_LoadData.lss`.
   - Agent „SaveRow“: Auslöser „Manuell“ oder Button; Code aus `Agent_SaveRow.lss`.
   - Beide Agenten: Option „LotusScript ausführen“ und Script-Bibliothek `PGData` einbinden (wenn die Agenten in der DB sind, Bibliothek in der DB verfügbar machen).

## Formular und Felder

- **GridData** (Mehrzeilig/Text oder Rich Text): Anzeige der geladenen test2view-Daten (z. B. als Tab-getrennte Zeilen, von LoadData gefüllt).
- **GridSameArt** (Mehrzeilig/Text): Anzeige „Datensätze mit gleicher Art“ (von LoadData gefüllt, gefiltert nach aktueller Zeile).
- **Summe** (Text, berechnet/lesbar): Summe der Spalte Betrag.
- **Preview t00 … t05** (bearbeitbare Textfelder): Werte der aktuell gewählten Zeile (pk1, Betrag, gewerk, bvh, art, test).
- **Event** (Text): Event-/Status-Text (z. B. „geladen“, „zelle geändert“).
- **Zeile**, **Spalte** (Text): aktuelle Zeile/Spalte (optional).
- **Buttons**: „Laden“ (ruft LoadData auf), „save row“ / „update row“ (ruft SaveRow auf).

Die genaue Anordnung (Tabelle, Abschnitte) können Sie im Formular-Design frei wählen. Die LotusScript-Routinen lesen/schreiben die Feldnamen wie oben.

## Ablauf

1. **Laden**: Agent „LoadData“ verbindet per ODBC mit PostgreSQL, führt `SELECT * FROM public.test2view` aus und schreibt die Ergebnismenge in die Felder (z. B. GridData als Tab-getrennte Tabelle, Summe, optional GridSameArt wenn eine Zeile vorausgewählt ist).
2. **Zeile wählen**: Über ein Dokument mit gesetzter „aktueller Zeile“ oder über ein Listfeld/Keyword wird die Zeile gewählt; Preview t00–t05 und GridSameArt werden entsprechend gesetzt/gefiltert.
3. **save row / update row**: Agent „SaveRow“ liest t00 (pk1), t01 (Betrag), t02 (gewerk), t03 (bvh), t04 (art), t05 (test) und führt `UPDATE public.buchpos SET … WHERE pk1 = ?` aus.

## Dateien im Projekt

| Datei | Inhalt |
|-------|--------|
| `ScriptLib_PGData.lss` | LotusScript-Bibliothek: ODBC-Verbindung, LoadTest2View, UpdateBuchposRow, Hilfsfunktionen |
| `Agent_LoadData.lss` | Agent „Laden“: test2view laden, GridData/Summe/GridSameArt füllen |
| `Agent_SaveRow.lss` | Agent „save row“: UPDATE buchpos aus Preview-Feldern |
| `Form_MainPG.txt` | Beschreibung der Felder und Buttons für das Formular |

## Konfiguration

- Connection-String bzw. DSN-Namen in `ScriptLib_PGData.lss` anpassen (Konstante `PG_DSN` oder Variable `connStr`).
- Feldnamen (GridData, Summe, t00–t05, Event, …) in den Agenten an Ihre tatsächlichen Formularfeldnamen anpassen.

## Hinweise

- Ohne konfigurierten ODBC-DSN und PostgreSQL-ODBC-Treiber schlagen die Verbindungen fehl; Fehler werden per `GetErrorMessage` bzw. Meldung ausgegeben.
- Auf 64-Bit-Windows: 32-Bit-Notes verwendet 32-Bit-ODBC (odbcad32 in SysWOW64).
