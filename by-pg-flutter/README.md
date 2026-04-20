# by-pg-flutter

Flutter-Migration des C# WinForms-Projekts **by-pg-grid**: PostgreSQL DataGrid mit View test2view, zweites Grid gefiltert nach gleicher **Art**, Preview-Panel, Summen und Speichern.

## Voraussetzungen

- Flutter SDK (z. B. 3.x)
- PostgreSQL erreichbar (Connection-String in `lib/services/db_service.dart` anpassen)

## Start

```bash
cd by-pg-flutter
flutter pub get
# Falls noch keine Plattform vorhanden ist (z. B. windows/):
flutter create . --platforms=windows
flutter run -d windows
```

## Funktionen (wie C#-Version)

- **Haupt-Grid**: Daten aus `public.test2view` laden und anzeigen
- **Grid „Datensätze mit gleicher Art“**: Zeigt nur Zeilen mit derselben Art wie die aktuell gewählte Zeile
- **Preview-Panel**: Zeigt Felder der aktuellen Zeile (t00–t10), „save row“ schreibt in `buchpos`
- **Buttons**: Laden, Speichern, Bt1. gtm, update row
- **Summe**: Summe der Spalte Betrag
- **Debug**: Zeile/Spalte und Event-Text

## Konfiguration

Connection-String in `lib/services/db_service.dart`:

```dart
static const String connString = 'Host=192.168.207.160;Port=5432;...';
```

(Optional: Umgebungsvariable oder Konfigurationsdatei nutzen.)
