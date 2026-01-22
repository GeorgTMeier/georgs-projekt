package com.domino.xrechnung;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Datenklasse für Rechnungsinformationen
 */
public class InvoiceData {
    
    // Basis-Informationen
    private String invoiceNumber;
    private Date invoiceDate;
    private Date dueDate;
    private String currency = "EUR";
    
    // Verkäufer (Seller)
    private String sellerName;
    private String sellerStreet;
    private String sellerZip;
    private String sellerCity;
    private String sellerCountry = "DE";
    private String sellerVATID;
    private String sellerTaxNumber;
    
    // Käufer (Buyer)
    private String buyerName;
    private String buyerStreet;
    private String buyerZip;
    private String buyerCity;
    private String buyerCountry = "DE";
    private String buyerVATID;
    
    // Beträge
    private BigDecimal totalNetAmount = BigDecimal.ZERO;
    private BigDecimal totalTaxAmount = BigDecimal.ZERO;
    private BigDecimal totalAmount = BigDecimal.ZERO;
    
    // Rechnungspositionen
    private List<InvoiceLineItem> lineItems = new ArrayList<>();
    
    // Zahlungsbedingungen
    private String paymentTerms;
    
    // Getter und Setter
    public String getInvoiceNumber() {
        return invoiceNumber;
    }
    
    public void setInvoiceNumber(String invoiceNumber) {
        this.invoiceNumber = invoiceNumber;
    }
    
    public Date getInvoiceDate() {
        return invoiceDate;
    }
    
    public void setInvoiceDate(Date invoiceDate) {
        this.invoiceDate = invoiceDate;
    }
    
    public Date getDueDate() {
        return dueDate;
    }
    
    public void setDueDate(Date dueDate) {
        this.dueDate = dueDate;
    }
    
    public String getCurrency() {
        return currency;
    }
    
    public void setCurrency(String currency) {
        this.currency = currency;
    }
    
    public String getSellerName() {
        return sellerName;
    }
    
    public void setSellerName(String sellerName) {
        this.sellerName = sellerName;
    }
    
    public String getSellerStreet() {
        return sellerStreet;
    }
    
    public void setSellerStreet(String sellerStreet) {
        this.sellerStreet = sellerStreet;
    }
    
    public String getSellerZip() {
        return sellerZip;
    }
    
    public void setSellerZip(String sellerZip) {
        this.sellerZip = sellerZip;
    }
    
    public String getSellerCity() {
        return sellerCity;
    }
    
    public void setSellerCity(String sellerCity) {
        this.sellerCity = sellerCity;
    }
    
    public String getSellerCountry() {
        return sellerCountry;
    }
    
    public void setSellerCountry(String sellerCountry) {
        this.sellerCountry = sellerCountry;
    }
    
    public String getSellerVATID() {
        return sellerVATID;
    }
    
    public void setSellerVATID(String sellerVATID) {
        this.sellerVATID = sellerVATID;
    }
    
    public String getSellerTaxNumber() {
        return sellerTaxNumber;
    }
    
    public void setSellerTaxNumber(String sellerTaxNumber) {
        this.sellerTaxNumber = sellerTaxNumber;
    }
    
    public String getBuyerName() {
        return buyerName;
    }
    
    public void setBuyerName(String buyerName) {
        this.buyerName = buyerName;
    }
    
    public String getBuyerStreet() {
        return buyerStreet;
    }
    
    public void setBuyerStreet(String buyerStreet) {
        this.buyerStreet = buyerStreet;
    }
    
    public String getBuyerZip() {
        return buyerZip;
    }
    
    public void setBuyerZip(String buyerZip) {
        this.buyerZip = buyerZip;
    }
    
    public String getBuyerCity() {
        return buyerCity;
    }
    
    public void setBuyerCity(String buyerCity) {
        this.buyerCity = buyerCity;
    }
    
    public String getBuyerCountry() {
        return buyerCountry;
    }
    
    public void setBuyerCountry(String buyerCountry) {
        this.buyerCountry = buyerCountry;
    }
    
    public String getBuyerVATID() {
        return buyerVATID;
    }
    
    public void setBuyerVATID(String buyerVATID) {
        this.buyerVATID = buyerVATID;
    }
    
    public BigDecimal getTotalNetAmount() {
        return totalNetAmount;
    }
    
    public void setTotalNetAmount(BigDecimal totalNetAmount) {
        this.totalNetAmount = totalNetAmount;
    }
    
    public BigDecimal getTotalTaxAmount() {
        return totalTaxAmount;
    }
    
    public void setTotalTaxAmount(BigDecimal totalTaxAmount) {
        this.totalTaxAmount = totalTaxAmount;
    }
    
    public BigDecimal getTotalAmount() {
        return totalAmount;
    }
    
    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }
    
    public List<InvoiceLineItem> getLineItems() {
        return lineItems;
    }
    
    public void setLineItems(List<InvoiceLineItem> lineItems) {
        this.lineItems = lineItems;
    }
    
    public void addLineItem(InvoiceLineItem item) {
        this.lineItems.add(item);
    }
    
    public String getPaymentTerms() {
        return paymentTerms;
    }
    
    public void setPaymentTerms(String paymentTerms) {
        this.paymentTerms = paymentTerms;
    }
}
