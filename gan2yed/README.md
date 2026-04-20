# gan2yed

Konvertiert **GanttProject**-Projektdateien (`.gan`) in **yEd**-Diagramme (`.graphml`).

- Jeder **Task** wird zu einem **Knoten** (mit Namen als Beschriftung).
- Jede **Abhängigkeit** (Vorgänger → Nachfolger) wird zu einer **gerichteten Kante**.

Es gibt zwei Implementierungen mit gleicher Funktionalität:

| Datei        | Sprache | Voraussetzung              |
|---------------|---------|----------------------------|
| `gan2yed.py`  | Python  | Python 3.6+ (Standardbibliothek) |
| `gan2yed.rb`  | Ruby    | Ruby (REXML in Standardbibliothek) |

## Verwendung

**Python:**

```text
python gan2yed.py <eingabe.gan> [ausgabe.graphml]
```

**Ruby:**

```text
ruby gan2yed.rb <eingabe.gan> [ausgabe.graphml]
```

- **eingabe.gan** – GanttProject-Datei (XML).
- **ausgabe.graphml** – optional. Ohne Angabe wird die Ausgabe neben der Eingabe mit der Endung `.graphml` gespeichert.

Beispiele:

```text
python gan2yed.py projekt.gan
ruby gan2yed.rb projekt.gan
# Beide erzeugen projekt.graphml

ruby gan2yed.rb C:\Projekte\haus.gan C:\Ausgabe\haus.graphml
```

## Ausgabe

Die erzeugte `.graphml`-Datei kann in **yEd** geöffnet werden. Die Knoten zeigen die Task-Namen; die Kanten entsprechen den Vorgänger-Nachfolger-Beziehungen. Das Layout kann in yEd über **Layout → Hierarchisch** (oder andere Algorithmen) angepasst werden.
