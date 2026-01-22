# HCL Domino X-Rechnung Generator

Java-Programm für HCL Domino zur Erstellung von X-Rechnung (EN 16931) mit der Mustang-Bibliothek.

## Übersicht

Dieses Projekt enthält Java-Klassen für HCL Domino, die es ermöglichen, X-Rechnung-konforme elektronische Rechnungen zu erstellen. Die Implementierung nutzt die [Mustang-Bibliothek](https://www.mustangproject.org/), eine Open-Source-Java-Bibliothek für EN 16931-konforme elektronische Rechnungen.

## Voraussetzungen

- HCL Domino Server (Version 12 oder höher empfohlen)
- Java 8 oder höher
- Mustang-Bibliothek (Version 2.16.4 oder höher)
- Maven (für Build-Prozess)

## Projektstruktur

```
src/main/java/com/domino/xrechnung/
├── XRechnungGenerator.java    # Hauptklasse zur X-Rechnung-Erstellung
├── InvoiceData.java            # Datenklasse für Rechnungsinformationen
├── InvoiceLineItem.java        # Datenklasse für Rechnungspositionen
└── XRechnungAgent.java         # Domino-Agent-Beispiel
```

## Installation

### 1. Mustang-Bibliothek herunterladen

Die Mustang-Bibliothek kann über Maven Central bezogen werden:

```xml
<dependency>
    <groupId>org.mustangproject</groupId>
    <artifactId>library</artifactId>
    <version>2.16.4</version>
</dependency>
```

### 2. Build mit Maven

```bash
mvn clean compile
mvn package
```

### 3. Installation in Domino

1. **JAR-Dateien kopieren:**
   - Die kompilierte JAR-Datei und die Mustang-Bibliothek in das Domino-Programmverzeichnis kopieren
   - Oder in einen gemeinsamen Bibliotheksordner auf dem Domino-Server

2. **Classpath konfigurieren:**
   - In Domino Designer: Agent-Eigenschaften → Java → Classpath
   - Mustang-Bibliothek und eigene JAR-Datei hinzufügen

## Verwendung

### Als Domino-Agent

1. **Agent in Domino Designer erstellen:**
   - Neuen Agent erstellen
   - Basis-Klasse: "Java"
   - Hauptklasse: `com.domino.xrechnung.XRechnungAgent`

2. **Agent konfigurieren:**
   - Auslöser: "Manuell" oder "Wenn Dokument geändert/gespeichert wird"
   - Sicherheit: Agent mit entsprechenden Rechten ausführen
   - Classpath: Mustang-Bibliothek hinzufügen

3. **Agent ausführen:**
   - Auf einem Rechnungsdokument ausführen
   - Die X-Rechnung wird als XML-Datei erstellt

### Vereinfachte Verwendung

Für einfache Fälle können Sie auch die `XRechnungSimple`-Klasse verwenden:

```java
XRechnungSimple.createSimpleXRechnung(
    "RE-2024-001",
    new Date(),
    "Verkäufer GmbH", "Musterstraße 1", "12345", "Musterstadt", "DE", "DE123456789",
    "Käufer AG", "Kundenstraße 2", "54321", "Kundenstadt", "DE", "DE987654321",
    "C:\\temp\\xrechnung.xml"
);
```

### Programmgesteuert

```java
import com.domino.xrechnung.*;
import lotus.domino.*;

// Domino-Session initialisieren
Session session = NotesFactory.createSession();
Database database = session.getDatabase("", "database.nsf");

// Generator erstellen
XRechnungGenerator generator = new XRechnungGenerator(session, database);

// Rechnungsdaten vorbereiten
InvoiceData invoiceData = new InvoiceData();
invoiceData.setInvoiceNumber("RE-2024-001");
invoiceData.setInvoiceDate(new Date());
// ... weitere Daten setzen

// X-Rechnung erstellen
String outputPath = "C:\\temp\\xrechnung_001.xml";
generator.createXRechnung(invoiceData, outputPath);

// Cleanup
generator.recycle();
```

### Beispiel: Rechnung aus Domino-Dokument

```java
// Dokument öffnen
Document invoiceDoc = database.getDocumentByUNID("...");

// X-Rechnung aus Dokument erstellen
XRechnungGenerator generator = new XRechnungGenerator(session, database);
generator.createXRechnungFromDocument(invoiceDoc, "output.xml");
```

## Datenstruktur

### InvoiceData

Enthält alle Informationen für eine Rechnung:
- Basis-Informationen (Rechnungsnummer, Datum, Währung)
- Verkäufer-Daten (Name, Adresse, USt-IdNr., Steuernummer)
- Käufer-Daten (Name, Adresse, USt-IdNr.)
- Beträge (Netto, Steuer, Brutto)
- Rechnungspositionen (Liste von `InvoiceLineItem`)
- Zahlungsbedingungen

### InvoiceLineItem

Enthält Informationen für eine Rechnungsposition:
- Beschreibung
- Menge
- Einheit (z.B. "C62" für Stück)
- Einzelpreis
- Steuersatz
- Steuerkategorie
- Gesamtpreis

## Domino-Dokument-Felder

Wenn Sie Rechnungsdaten aus Domino-Dokumenten extrahieren möchten, sollten folgende Felder vorhanden sein:

**Basis:**
- `InvoiceNumber` (Text)
- `InvoiceDate` (Datum/Zeit)

**Verkäufer:**
- `SellerName`, `SellerStreet`, `SellerZip`, `SellerCity`, `SellerCountry`
- `SellerVATID`, `SellerTaxNumber`

**Käufer:**
- `BuyerName`, `BuyerStreet`, `BuyerZip`, `BuyerCity`, `BuyerCountry`
- `BuyerVATID`

**Beträge:**
- `TotalNetAmount`, `TotalTaxAmount`, `TotalAmount` (Zahl)
- `Currency` (Text, Standard: "EUR")

**Rechnungspositionen:**
- `LineItems` (kann als strukturiertes Feld oder als separate Dokumente implementiert werden)

## X-Rechnung Standard

X-Rechnung ist die deutsche CIUS (Core Invoice Usage Specification) basierend auf EN 16931. Die aktuelle Version ist 3.0.1.

Weitere Informationen:
- [Mustang Project](https://www.mustangproject.org/)
- [X-Rechnung Spezifikation](https://www.x-rechnung.org/)

## Fehlerbehebung

### ClassNotFoundException

- Stellen Sie sicher, dass die Mustang-Bibliothek im Classpath ist
- Überprüfen Sie die JAR-Datei-Pfade in Domino Designer

### NotesException

- Überprüfen Sie die Domino-Session und Datenbankverbindung
- Stellen Sie sicher, dass der Agent die notwendigen Rechte hat

### XML-Validierungsfehler

- Überprüfen Sie alle Pflichtfelder der Rechnung
- Stellen Sie sicher, dass USt-IdNr. im korrekten Format vorliegt (z.B. "DE123456789")

## Lizenz

Dieses Projekt verwendet die Mustang-Bibliothek, die unter der Apache License 2.0 lizenziert ist.

## Support

Bei Fragen oder Problemen:
- Mustang-Projekt: https://github.com/ZUGFeRD/mustangproject
- X-Rechnung: https://www.x-rechnung.org/
