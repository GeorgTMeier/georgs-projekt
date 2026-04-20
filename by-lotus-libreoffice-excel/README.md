# by-lotus-libreoffice-excel

Kleines LotusScript-Programm, das **LibreOffice per COM** steuert, um eine Excel-Datei zu erzeugen:

- **Inhalt:** Die ersten 5 Zeilen und die ersten 5 Spalten (A1:E5) werden mit der Zahl **1** belegt.
- **Filter:** Auf dem Bereich A1:E5 wird ein **AutoFilter** angelegt (Dropdowns in allen Spalten, u. a. für Spalte B und D).

Die Ausgabe wird als **.xlsx** (Microsoft Excel 2007 XML) gespeichert.

## Voraussetzungen

- **IBM Notes/Domino** (LotusScript läuft in Notes)
- **LibreOffice** unter Windows installiert (damit die COM-Brücke „com.sun.star.ServiceManager“ verfügbar ist)
- Optional: Portable LibreOffice kann COM-Unterstützung haben, ggf. mit Anpassung/Registrierung

## Verwendung in Notes

1. Design → Script-Bibliothek anlegen (z. B. Name **CreateExcelViaLibreOffice**).
2. Inhalt der Datei `CreateExcelViaLibreOffice.lss` in die Bibliothek einfügen und speichern.
3. Einen Agent anlegen (z. B. „Erzeuge Excel“), die Bibliothek einbinden und z. B.:

```lotusscript
Sub Initialize
    Dim g As New CreateExcelViaLibreOffice
    Call g.Run("C:\Temp\Ausgabe.xlsx")
End Sub
```

Der Pfad `C:\Temp\Ausgabe.xlsx` kann beliebig angepasst werden.

## Klasse: CreateExcelViaLibreOffice

| Methode | Beschreibung |
|--------|----------------|
| `Run(outputPath)` | Erzeugt die Excel-Datei: Verbindung zu LibreOffice, Befüllen A1:E5 mit 1, AutoFilter setzen, als .xlsx speichern. |

Intern verwendet die Klasse COM (`CreateObject("com.sun.star.ServiceManager")`), lädt ein neues Calc-Dokument, arbeitet mit dem ersten Blatt und speichert mit dem Filter „Calc MS Excel 2007 XML“.

## Hinweise

- Unter COM muss auf Blätter mit `getSheets().getByIndex(0)` zugegriffen werden, nicht mit `Sheets(0)`.
- Wenn die Speicherung als .xlsx fehlschlägt, kann der Filtername je nach LibreOffice-Version abweichen (z. B. „MS Excel 2007 XML“). Dann in der Methode `SaveAsExcel` die Zeile mit `FilterName` anpassen.
- Die `file:///`-URL wird aus dem Windows-Pfad automatisch erzeugt.
