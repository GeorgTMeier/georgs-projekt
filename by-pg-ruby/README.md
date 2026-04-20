# by-pg-ruby

Ruby-Migration des Projekts **by-pg-grid**: PostgreSQL DataGrid mit **Tk-GUI** – test2view laden, zweites Grid „Datensätze mit gleicher Art“, Preview, Summe, Speichern/Update buchpos.

## Voraussetzungen

- Ruby (z. B. 3.x)
- **Tk** (für die GUI): unter Windows oft mit RubyInstaller dabei; unter Linux: `sudo apt install tk` bzw. Paket `ruby-tk`; unter macOS: Tcl/Tk (z. B. über Homebrew)
- PostgreSQL erreichbar (Connection in `lib/db_service.rb` anpassen)

## Installation

```bash
cd by-pg-ruby
bundle install
```

## Start

```bash
bundle exec ruby main.rb
```

## Funktionen (wie C#-Version)

- **Haupt-Grid**: Daten aus `public.test2view` laden und anzeigen (Tk Treeview)
- **Grid „Datensätze mit gleicher Art“**: nur Zeilen mit derselben Art wie die gewählte Zeile
- **Preview-Panel**: Felder t00–t05 der aktuellen Zeile, Button „save row“ schreibt in `buchpos`
- **Buttons**: Laden, Speichern, Bt1. gtm, update row
- **Summe**: Summe der Spalte Betrag
- **Debug**: Zeile, Spalte, Event-Text

## Konfiguration

Connection-Parameter in `lib/db_service.rb`:

```ruby
HOST = '192.168.207.160'
PORT = 5432
DBNAME = 'RK2'
USER = 'postgres'
PASSWORD = 'Ole1brumm'
```

## GUI

Es wird **Tk** (ttk Treeview) verwendet – läuft unter Windows, Linux und macOS und ist in Ruby-Umgebungen weit verbreitet.
