package com.domino.xrechnung;

import org.mustangproject.Invoice;
import org.mustangproject.TradeParty;
import org.mustangproject.Item;
import org.mustangproject.Product;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Date;

/**
 * Standalone-Beispiel für die Erstellung einer X-Rechnung
 * Kann auch ohne Domino-Umgebung verwendet werden
 */
public class XRechnungStandalone {
    
    /**
     * Hauptmethode für Standalone-Test
     */
    public static void main(String[] args) {
        try {
            // Rechnungsdaten erstellen
            InvoiceData invoiceData = createSampleInvoiceData();
            
            // Generator erstellen (ohne Domino)
            XRechnungGenerator generator = new XRechnungGenerator();
            
            // X-Rechnung erstellen
            String outputPath = "xrechnung_" + invoiceData.getInvoiceNumber() + ".xml";
            boolean success = generator.createXRechnung(invoiceData, outputPath);
            
            if (success) {
                System.out.println("X-Rechnung erfolgreich erstellt: " + outputPath);
            } else {
                System.out.println("Fehler beim Erstellen der X-Rechnung");
            }
            
        } catch (Exception e) {
            System.err.println("Fehler: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Erstellt Beispieldaten für eine Rechnung
     */
    private static InvoiceData createSampleInvoiceData() {
        InvoiceData data = new InvoiceData();
        
        // Basis-Informationen
        data.setInvoiceNumber("RE-2024-001");
        data.setInvoiceDate(new Date());
        data.setDueDate(new Date(System.currentTimeMillis() + 30L * 24 * 60 * 60 * 1000)); // 30 Tage
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
            new BigDecimal("10.00"),
            new BigDecimal("100.00"),
            new BigDecimal("19.00")
        );
        item1.setUnit("C62"); // Stück
        
        InvoiceLineItem item2 = new InvoiceLineItem(
            "Dienstleistung B",
            new BigDecimal("5.00"),
            new BigDecimal("200.00"),
            new BigDecimal("19.00")
        );
        item2.setUnit("C62"); // Stück
        
        data.addLineItem(item1);
        data.addLineItem(item2);
        
        // Beträge berechnen
        BigDecimal netAmount = new BigDecimal("2000.00");
        BigDecimal taxAmount = new BigDecimal("380.00");
        BigDecimal totalAmount = new BigDecimal("2380.00");
        
        data.setTotalNetAmount(netAmount);
        data.setTotalTaxAmount(taxAmount);
        data.setTotalAmount(totalAmount);
        
        // Zahlungsbedingungen
        data.setPaymentTerms("Zahlung innerhalb von 30 Tagen");
        
        return data;
    }
}
