# Excel externe Links auflisten (Ruby)

Dieses Programm öffnet eine XLSX-Datei und listet alle **externen Links** zu anderen Excel-Dateien auf.

## liqui.xlsx aus einnahmen.xlsx erzeugen

Das Skript `create_liqui.rb` erstellt **liqui.xlsx** aus **einnahmen.xlsx**:

- **einnahmen.xlsx**: Spalte 1 = Betrag, Spalte 2 = Datum (beliebig viele Zeilen, Datum kann wiederholt vorkommen).
- **liqui.xlsx**: Enthält zwei Blätter:
  - **Einnahmen**: Kopie der Quelldaten.
  - **Liqui**: Spalte 1 = jedes Datum **nur einmal**, Spalte 2 = **aufsummierter Betrag** für dieses Datum (Formel **SUMMEWENN** / `SUMIF`).

Ohne vorhandene `einnahmen.xlsx` wird eine Beispieldatei angelegt und daraus `liqui.xlsx` erzeugt.

```bash
bundle exec ruby create_liqui.rb
```

Die Dateien entstehen im gleichen Ordner wie das Skript.

## Abhängigkeiten

- Ruby (2.6+)
- Gems: `rubyzip`, `roo`, `write_xlsx`

## Installation

```bash
cd by-ruby-excel-analyse
bundle install
```

## Verwendung

```bash
bundle exec ruby list_external_links.rb [datei.xlsx]
```

- Ohne Argument wird `beispiel.xlsx` im gleichen Verzeichnis verwendet.
- Mit Argument: Pfad zur XLSX-Datei.

Beispiel:

```bash
bundle exec ruby list_external_links.rb beispiel.xlsx
bundle exec ruby list_external_links.rb C:\Daten\Bericht.xlsx
```

## Ausgabe

Für jede extern referenzierte Excel-Datei werden angezeigt:
- der Pfad zur externen Datei,
- in welchem **Worksheet** und in welcher **Zelle** der Link vorkommt,
- die zugehörige Formel (z. B. `=[1]Sheet1!A1`).

## Technik

XLSX ist ein ZIP-Archiv. Externe Workbook-Referenzen stehen in:

- `xl/workbook.xml` → `<externalReferences>` mit `r:id`
- `xl/_rels/workbook.xml.rels` → Zuordnung zu `externalLinks/externalLinkN.xml`
- `xl/externalLinks/_rels/externalLinkN.xml.rels` → Ziel-Pfad der externen Datei

Das Skript liest diese XML-Teile und sammelt die Ziel-Pfade.
