package com.domino.xrechnung;

import lotus.domino.*;

/**
 * Domino-Agent zur Erstellung von X-Rechnung
 * 
 * Verwendung:
 * 1. In Domino Designer einen Agent erstellen
 * 2. Als Basis-Klasse "Java" wählen
 * 3. Diese Klasse als Hauptklasse verwenden
 * 4. Mustang-Bibliothek zum Classpath hinzufügen
 */
public class XRechnungAgent extends AgentBase {
    
    @Override
    public void NotesMain() {
        try {
            Session session = getSession();
            AgentContext agentContext = session.getAgentContext();
            Database database = agentContext.getCurrentDatabase();
            
            // Dokument aus dem Agent-Kontext holen (wenn Agent auf Dokument ausgeführt wird)
            DocumentCollection docCollection = agentContext.getUnprocessedDocuments();
            Document doc = docCollection.getFirstDocument();
            
            if (doc == null) {
                print("Kein Dokument gefunden. Bitte Agent auf einem Rechnungsdokument ausführen.");
                return;
            }
            
            // X-Rechnung Generator erstellen
            XRechnungGenerator generator = new XRechnungGenerator(session, database);
            
            // Beispiel: Rechnungsdaten manuell erstellen
            InvoiceData invoiceData = createSampleInvoiceData();
            
            // Alternativ: Daten aus Domino-Dokument extrahieren
            // InvoiceData invoiceData = generator.extractInvoiceDataFromDocument(doc);
            
            // Ausgabepfad bestimmen
            String outputPath = "C:\\temp\\xrechnung_" + invoiceData.getInvoiceNumber() + ".xml";
            
            // X-Rechnung erstellen
            boolean success = generator.createXRechnung(invoiceData, outputPath);
            
            if (success) {
                print("X-Rechnung erfolgreich erstellt: " + outputPath);
                
                // Optional: Datei als Attachment an Dokument anhängen
                // attachFileToDocument(doc, outputPath);
            } else {
                print("Fehler beim Erstellen der X-Rechnung");
            }
            
            // Cleanup
            generator.recycle();
            doc.recycle();
            docCollection.recycle();
            database.recycle();
            session.recycle();
            
        } catch (Exception e) {
            print("Fehler: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Erstellt Beispieldaten für eine Rechnung
     */
    private InvoiceData createSampleInvoiceData() {
        InvoiceData data = new InvoiceData();
        
        // Basis-Informationen
        data.setInvoiceNumber("RE-2024-001");
        data.setInvoiceDate(new java.util.Date());
        data.setCurrency("EUR");
        
        // Verkäufer
        data.setSellerName("Musterfirma GmbH");
        data.setSellerStreet("Musterstraße 123");
        data.setSellerZip("12345");
        data.setSellerCity("Musterstadt");
        data.setSellerCountry("DE");
        data.setSellerVATID("DE123456789");
        data.setSellerTaxNumber("12345/67890");
        
        // Käufer
        data.setBuyerName("Kundenfirma AG");
        data.setBuyerStreet("Kundenstraße 456");
        data.setBuyerZip("54321");
        data.setBuyerCity("Kundenstadt");
        data.setBuyerCountry("DE");
        data.setBuyerVATID("DE987654321");
        
        // Rechnungspositionen
        InvoiceLineItem item1 = new InvoiceLineItem(
            "Produkt A",
            new java.math.BigDecimal("10.00"),
            new java.math.BigDecimal("100.00"),
            new java.math.BigDecimal("19.00")
        );
        item1.setUnit("C62"); // Stück
        
        InvoiceLineItem item2 = new InvoiceLineItem(
            "Dienstleistung B",
            new java.math.BigDecimal("5.00"),
            new java.math.BigDecimal("200.00"),
            new java.math.BigDecimal("19.00")
        );
        item2.setUnit("C62"); // Stück
        
        data.addLineItem(item1);
        data.addLineItem(item2);
        
        // Beträge berechnen
        java.math.BigDecimal netAmount = new java.math.BigDecimal("2000.00");
        java.math.BigDecimal taxAmount = new java.math.BigDecimal("380.00");
        java.math.BigDecimal totalAmount = new java.math.BigDecimal("2380.00");
        
        data.setTotalNetAmount(netAmount);
        data.setTotalTaxAmount(taxAmount);
        data.setTotalAmount(totalAmount);
        
        // Zahlungsbedingungen
        data.setPaymentTerms("Zahlung innerhalb von 30 Tagen");
        
        return data;
    }
    
    /**
     * Hilfsmethode zum Ausgeben von Nachrichten
     */
    private void print(String message) {
        System.out.println(message);
    }
}
