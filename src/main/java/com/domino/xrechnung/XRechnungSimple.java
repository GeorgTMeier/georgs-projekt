package com.domino.xrechnung;

import lotus.domino.*;
import org.mustangproject.Invoice;
import org.mustangproject.TradeParty;
import org.mustangproject.Item;
import org.mustangproject.Product;
import org.mustangproject.XRechnung.XRechnungExporter;

import java.io.File;
import java.math.BigDecimal;
import java.util.Date;

/**
 * Vereinfachte Version zur Erstellung von X-Rechnung
 * Direkte Verwendung der Mustang-API
 */
public class XRechnungSimple {
    
    /**
     * Erstellt eine X-Rechnung mit minimalen Parametern
     * 
     * @param invoiceNumber Rechnungsnummer
     * @param invoiceDate Rechnungsdatum
     * @param sellerName Verkäufer-Name
     * @param sellerStreet Verkäufer-Straße
     * @param sellerZip Verkäufer-PLZ
     * @param sellerCity Verkäufer-Stadt
     * @param sellerCountry Verkäufer-Land (z.B. "DE")
     * @param sellerVATID Verkäufer-USt-IdNr. (z.B. "DE123456789")
     * @param buyerName Käufer-Name
     * @param buyerStreet Käufer-Straße
     * @param buyerZip Käufer-PLZ
     * @param buyerCity Käufer-Stadt
     * @param buyerCountry Käufer-Land
     * @param buyerVATID Käufer-USt-IdNr.
     * @param outputPath Ausgabepfad für die XML-Datei
     * @return true wenn erfolgreich
     * @throws Exception bei Fehlern
     */
    public static boolean createSimpleXRechnung(
            String invoiceNumber,
            Date invoiceDate,
            String sellerName, String sellerStreet, String sellerZip, 
            String sellerCity, String sellerCountry, String sellerVATID,
            String buyerName, String buyerStreet, String buyerZip,
            String buyerCity, String buyerCountry, String buyerVATID,
            String outputPath) throws Exception {
        
        try {
            // Invoice-Objekt erstellen
            Invoice invoice = new Invoice();
            invoice.setIssueDate(invoiceDate);
            invoice.setNumber(invoiceNumber);
            invoice.setCurrency("EUR");
            
            // Verkäufer
            TradeParty seller = new TradeParty(
                sellerName, sellerStreet, sellerZip, sellerCity, sellerCountry
            );
            if (sellerVATID != null && !sellerVATID.isEmpty()) {
                seller.addVATID(sellerVATID);
            }
            invoice.setSender(seller);
            
            // Käufer
            TradeParty buyer = new TradeParty(
                buyerName, buyerStreet, buyerZip, buyerCity, buyerCountry
            );
            if (buyerVATID != null && !buyerVATID.isEmpty()) {
                buyer.addVATID(buyerVATID);
            }
            invoice.setRecipient(buyer);
            
            // Beispiel-Position hinzufügen (kann später erweitert werden)
            Product product = new Product("Dienstleistung", "", "C62", new BigDecimal("19.00"));
            Item item = new Item(product, new BigDecimal("100.00"), new BigDecimal("1.00"));
            invoice.addItem(item);
            
            // X-Rechnung exportieren
            XRechnungExporter exporter = new XRechnungExporter();
            exporter.setTransaction(invoice);
            exporter.export(outputPath);
            
            return true;
            
        } catch (Exception e) {
            throw new Exception("Fehler beim Erstellen der X-Rechnung: " + e.getMessage(), e);
        }
    }
    
    /**
     * Domino-Agent-Version: Erstellt X-Rechnung aus Domino-Dokument
     */
    public static void createFromDominoDocument(Document doc, String outputPath) 
            throws NotesException, Exception {
        
        // Daten aus Dokument extrahieren
        String invoiceNumber = getFieldValue(doc, "InvoiceNumber");
        Date invoiceDate = (Date) doc.getItemValueDateTime("InvoiceDate").toJavaDate();
        
        String sellerName = getFieldValue(doc, "SellerName");
        String sellerStreet = getFieldValue(doc, "SellerStreet");
        String sellerZip = getFieldValue(doc, "SellerZip");
        String sellerCity = getFieldValue(doc, "SellerCity");
        String sellerCountry = getFieldValue(doc, "SellerCountry", "DE");
        String sellerVATID = getFieldValue(doc, "SellerVATID");
        
        String buyerName = getFieldValue(doc, "BuyerName");
        String buyerStreet = getFieldValue(doc, "BuyerStreet");
        String buyerZip = getFieldValue(doc, "BuyerZip");
        String buyerCity = getFieldValue(doc, "BuyerCity");
        String buyerCountry = getFieldValue(doc, "BuyerCountry", "DE");
        String buyerVATID = getFieldValue(doc, "BuyerVATID");
        
        // X-Rechnung erstellen
        createSimpleXRechnung(
            invoiceNumber, invoiceDate,
            sellerName, sellerStreet, sellerZip, sellerCity, sellerCountry, sellerVATID,
            buyerName, buyerStreet, buyerZip, buyerCity, buyerCountry, buyerVATID,
            outputPath
        );
    }
    
    private static String getFieldValue(Document doc, String fieldName) throws NotesException {
        Vector<?> values = doc.getItemValue(fieldName);
        if (values != null && !values.isEmpty()) {
            Object value = values.elementAt(0);
            return value != null ? value.toString() : "";
        }
        return "";
    }
    
    private static String getFieldValue(Document doc, String fieldName, String defaultValue) 
            throws NotesException {
        String value = getFieldValue(doc, fieldName);
        return value.isEmpty() ? defaultValue : value;
    }
}
