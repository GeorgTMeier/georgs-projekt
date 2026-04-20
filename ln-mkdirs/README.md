# ln-mkdirs

LotusScript-Klasse zum Exportieren einer CMD-Textdatei, die unter Windows Verzeichnisse per `mkdir` anlegt und/oder per `xcopy` kopiert.

## Klasse: MkdirCmd

**Script-Bibliothek:** `MkdirCmdLS.lss`

### Methoden

| Methode | Beschreibung |
|--------|----------------|
| `Init` | Initialisiert die Listen (mkdir und xcopy). Wird automatisch im Konstruktor aufgerufen. |
| `AppendDir(path)` | Fügt einen Verzeichnispfad hinzu (für `mkdir`). |
| `AppendXcopy(sourceDir, destDir)` | Fügt einen Kopierauftrag hinzu: Quellverzeichnis → Zielverzeichnis (`xcopy`). |
| `WriteCmdFile(filePath)` | Schreibt eine CMD-Datei mit allen `mkdir`- und `xcopy`-Befehlen. |

### Verwendung in Notes/Domino

1. Design → Script-Bibliothek anlegen (z. B. Name „MkdirCmdLS“).
2. Inhalt von `MkdirCmdLS.lss` einfügen und speichern.
3. In Agent oder Formular die Bibliothek einbinden und z. B.:

```lotusscript
Dim m As New MkdirCmd
Call m.Init
Call m.AppendDir("C:\Projekt\Ordner1")
Call m.AppendDir("C:\Projekt\Ordner2\Unterordner")
Call m.AppendXcopy("C:\Quelle\Daten", "D:\Ziel\Daten")
Call m.WriteCmdFile("C:\Temp\erzeuge_verzeichnisse.cmd")
```

Die erzeugte CMD-Datei kann unter Windows ausgeführt werden. `mkdir` legt bei Bedarf übergeordnete Ordner an. `xcopy` wird mit den Optionen `/E /I /Y` ausgegeben (Unterverzeichnisse inkl. leere, Ziel = Verzeichnis, Überschreiben ohne Nachfrage). Quell- und Zielpfade werden wie bei `AppendDir` normalisiert (doppelte/abschließende Backslashes entfernt).
