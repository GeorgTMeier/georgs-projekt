package com.domino.xrechnung;

import lotus.domino.*;
import org.mustangproject.ZUGFeRD.ZUGFeRDExporterFromA1;
import org.mustangproject.Invoice;
import org.mustangproject.TradeParty;
import org.mustangproject.Item;
import org.mustangproject.Product;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Date;
import java.util.Vector;

/**
 * HCL Domino Java-Klasse zur Erstellung von X-Rechnung mit Mustang-Bibliothek
 * 
 * Diese Klasse kann als Domino-Agent oder als Standalone-Programm verwendet werden.
 */
public class XRechnungGenerator {
    
    private Session session;
    private Database database;
    
    /**
     * Konstruktor für Domino-Umgebung
     */
    public XRechnungGenerator(Session session, Database database) {
        this.session = session;
        this.database = database;
    }
    
    /**
     * Konstruktor für Standalone-Verwendung
     */
    public XRechnungGenerator() {
        this.session = null;
        this.database = null;
    }
    
    /**
     * Erstellt eine X-Rechnung aus Rechnungsdaten
     * 
     * @param invoiceData Rechnungsdaten
     * @param outputPath Pfad für die Ausgabedatei (XML-Datei für X-Rechnung)
     * @return true wenn erfolgreich
     * @throws Exception bei Fehlern
     */
    public boolean createXRechnung(InvoiceData invoiceData, String outputPath) throws Exception {
        try {
            // Invoice-Objekt erstellen
            Invoice invoice = new Invoice();
            
            // Basis-Informationen
            invoice.setIssueDate(invoiceData.getInvoiceDate());
            invoice.setNumber(invoiceData.getInvoiceNumber());
            invoice.setCurrency(invoiceData.getCurrency());
            
            // Fälligkeitsdatum (optional, falls vorhanden)
            if (invoiceData.getDueDate() != null) {
                invoice.setDueDate(invoiceData.getDueDate());
            }
            
            // Verkäufer (Sender)
            TradeParty seller = new TradeParty(
                invoiceData.getSellerName(),
                invoiceData.getSellerStreet(),
                invoiceData.getSellerZip(),
                invoiceData.getSellerCity(),
                invoiceData.getSellerCountry()
            );
            
            if (invoiceData.getSellerVATID() != null && !invoiceData.getSellerVATID().isEmpty()) {
                seller.addVATID(invoiceData.getSellerVATID());
            }
            
            if (invoiceData.getSellerTaxNumber() != null && !invoiceData.getSellerTaxNumber().isEmpty()) {
                seller.addTaxID(invoiceData.getSellerTaxNumber());
            }
            
            invoice.setSender(seller);
            
            // Käufer (Recipient)
            TradeParty buyer = new TradeParty(
                invoiceData.getBuyerName(),
                invoiceData.getBuyerStreet(),
                invoiceData.getBuyerZip(),
                invoiceData.getBuyerCity(),
                invoiceData.getBuyerCountry()
            );
            
            if (invoiceData.getBuyerVATID() != null && !invoiceData.getBuyerVATID().isEmpty()) {
                buyer.addVATID(invoiceData.getBuyerVATID());
            }
            
            invoice.setRecipient(buyer);
            
            // Rechnungspositionen hinzufügen
            for (InvoiceLineItem lineItem : invoiceData.getLineItems()) {
                Product product = new Product(
                    lineItem.getDescription(),
                    "", // Beschreibung (optional)
                    lineItem.getUnit(), // Einheit (z.B. "C62" für Stück)
                    lineItem.getTaxPercent() // Steuersatz
                );
                
                Item item = new Item(
                    product,
                    lineItem.getUnitPrice(), // Einzelpreis
                    lineItem.getQuantity()   // Menge
                );
                
                invoice.addItem(item);
            }
            
            // Für X-Rechnung: XML-Export verwenden
            // Mustang unterstützt direkten XML-Export für X-Rechnung
            File outputFile = new File(outputPath);
            
            // X-Rechnung als XML exportieren
            // Mustang kann X-Rechnung direkt als XML exportieren
            // Verwende den XRechnungExporter für reine XML-Ausgabe
            try {
                // Methode 1: Direkter XML-Export (falls verfügbar)
                org.mustangproject.XRechnung.XRechnungExporter xrechnungExporter = 
                    new org.mustangproject.XRechnung.XRechnungExporter();
                
                xrechnungExporter.setTransaction(invoice);
                xrechnungExporter.export(outputFile.getAbsolutePath());
                
            } catch (NoClassDefFoundError | ClassNotFoundException e) {
                // Fallback: Verwende ZUGFeRDExporter und konvertiere zu XML
                // Oder verwende die Invoice.toXML() Methode falls verfügbar
                throw new Exception("XRechnungExporter nicht gefunden. " +
                    "Bitte stellen Sie sicher, dass die Mustang-Bibliothek vollständig im Classpath ist.", e);
            }
            
            return true;
            
        } catch (Exception e) {
            throw new Exception("Fehler beim Erstellen der X-Rechnung: " + e.getMessage(), e);
        }
    }
    
    /**
     * Erstellt eine X-Rechnung aus Domino-Dokument
     * 
     * @param invoiceDoc Domino-Dokument mit Rechnungsdaten
     * @param outputPath Pfad für die Ausgabedatei
     * @return true wenn erfolgreich
     * @throws Exception bei Fehlern
     */
    public boolean createXRechnungFromDocument(Document invoiceDoc, String outputPath) throws Exception {
        try {
            InvoiceData invoiceData = extractInvoiceDataFromDocument(invoiceDoc);
            return createXRechnung(invoiceData, outputPath);
        } catch (Exception e) {
            throw new Exception("Fehler beim Erstellen der X-Rechnung aus Dokument: " + e.getMessage(), e);
        }
    }
    
    /**
     * Extrahiert Rechnungsdaten aus einem Domino-Dokument
     */
    private InvoiceData extractInvoiceDataFromDocument(Document doc) throws NotesException {
        InvoiceData data = new InvoiceData();
        
        // Basis-Informationen
        data.setInvoiceNumber(getFieldValue(doc, "InvoiceNumber"));
        data.setInvoiceDate((Date) doc.getItemValueDateTime("InvoiceDate").toJavaDate());
        
        // Verkäufer
        data.setSellerName(getFieldValue(doc, "SellerName"));
        data.setSellerStreet(getFieldValue(doc, "SellerStreet"));
        data.setSellerZip(getFieldValue(doc, "SellerZip"));
        data.setSellerCity(getFieldValue(doc, "SellerCity"));
        data.setSellerCountry(getFieldValue(doc, "SellerCountry", "DE"));
        data.setSellerVATID(getFieldValue(doc, "SellerVATID"));
        data.setSellerTaxNumber(getFieldValue(doc, "SellerTaxNumber"));
        
        // Käufer
        data.setBuyerName(getFieldValue(doc, "BuyerName"));
        data.setBuyerStreet(getFieldValue(doc, "BuyerStreet"));
        data.setBuyerZip(getFieldValue(doc, "BuyerZip"));
        data.setBuyerCity(getFieldValue(doc, "BuyerCity"));
        data.setBuyerCountry(getFieldValue(doc, "BuyerCountry", "DE"));
        data.setBuyerVATID(getFieldValue(doc, "BuyerVATID"));
        
        // Beträge
        data.setTotalNetAmount(getBigDecimalValue(doc, "TotalNetAmount"));
        data.setTotalTaxAmount(getBigDecimalValue(doc, "TotalTaxAmount"));
        data.setTotalAmount(getBigDecimalValue(doc, "TotalAmount"));
        data.setCurrency(getFieldValue(doc, "Currency", "EUR"));
        
        // Rechnungspositionen
        Vector<?> lineItems = doc.getItemValue("LineItems");
        if (lineItems != null && !lineItems.isEmpty()) {
            // Hier müsste die Struktur der LineItems angepasst werden
            // je nachdem wie die Daten im Domino-Dokument gespeichert sind
        }
        
        return data;
    }
    
    private String getFieldValue(Document doc, String fieldName) throws NotesException {
        Vector<?> values = doc.getItemValue(fieldName);
        if (values != null && !values.isEmpty()) {
            Object value = values.elementAt(0);
            return value != null ? value.toString() : "";
        }
        return "";
    }
    
    private String getFieldValue(Document doc, String fieldName, String defaultValue) throws NotesException {
        String value = getFieldValue(doc, fieldName);
        return value.isEmpty() ? defaultValue : value;
    }
    
    private BigDecimal getBigDecimalValue(Document doc, String fieldName) throws NotesException {
        String value = getFieldValue(doc, fieldName);
        if (value == null || value.isEmpty()) {
            return BigDecimal.ZERO;
        }
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }
    
    /**
     * Cleanup für Domino-Objekte
     */
    public void recycle() {
        if (database != null) {
            try {
                database.recycle();
            } catch (NotesException e) {
                // Ignorieren
            }
        }
        if (session != null) {
            try {
                session.recycle();
            } catch (NotesException e) {
                // Ignorieren
            }
        }
    }
}
