# Build-Anleitung für X-Rechnung Generator

## Schnellstart

### 1. Maven Build

```bash
mvn clean compile
mvn package
```

Dies erstellt eine JAR-Datei im `target/` Verzeichnis.

### 2. Dependencies

Die Mustang-Bibliothek wird automatisch von Maven heruntergeladen. Für Domino müssen Sie die Notes.jar manuell zum Classpath hinzufügen.

### 3. Installation in Domino

1. **JAR-Dateien kopieren:**
   ```
   target/xrechnung-generator-1.0.0.jar → Domino Server/lib/
   Mustang-Bibliothek (aus Maven Repository) → Domino Server/lib/
   ```

2. **In Domino Designer:**
   - Agent-Eigenschaften öffnen
   - Java → Classpath
   - Beide JAR-Dateien hinzufügen

## Klassen-Übersicht

- **XRechnungGenerator**: Hauptklasse für vollständige Rechnungserstellung
- **XRechnungSimple**: Vereinfachte Version für schnelle Implementierung
- **XRechnungAgent**: Domino-Agent-Beispiel
- **XRechnungStandalone**: Standalone-Testprogramm
- **InvoiceData**: Datenklasse für Rechnungsinformationen
- **InvoiceLineItem**: Datenklasse für Rechnungspositionen

## Wichtige Hinweise

1. **Mustang-Version**: Aktuell konfiguriert für Version 2.16.4. Neuere Versionen können andere APIs haben.

2. **XRechnungExporter**: Die Klasse `org.mustangproject.XRechnung.XRechnungExporter` muss in der verwendeten Mustang-Version verfügbar sein. Falls nicht, kann alternativ der `ZUGFeRDExporter` verwendet werden.

3. **Domino-Notes.jar**: Diese muss lokal verfügbar sein. Sie ist normalerweise im Domino-Installationsverzeichnis unter `jvm/lib/ext/Notes.jar` zu finden.

## Test

```bash
# Standalone-Test ausführen
java -cp "target/xrechnung-generator-1.0.0.jar:target/dependency/*" \
     com.domino.xrechnung.XRechnungStandalone
```

## Troubleshooting

### ClassNotFoundException für XRechnungExporter

Falls die Klasse nicht gefunden wird, prüfen Sie:
- Mustang-Version (sollte 2.16.4 oder höher sein)
- Vollständiger Classpath
- Alternative: Verwenden Sie `ZUGFeRDExporter` und exportieren Sie als XML

### NotesException

- Stellen Sie sicher, dass Notes.jar im Classpath ist
- Überprüfen Sie die Domino-Session-Initialisierung
