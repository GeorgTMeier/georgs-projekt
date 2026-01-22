package com.domino.xrechnung;

import java.math.BigDecimal;

/**
 * Datenklasse für eine Rechnungsposition
 */
public class InvoiceLineItem {
    
    private String description;
    private BigDecimal quantity = BigDecimal.ONE;
    private String unit = "C62"; // Stück (Standard)
    private BigDecimal unitPrice = BigDecimal.ZERO;
    private BigDecimal taxPercent = BigDecimal.valueOf(19.0); // Standard 19% MwSt
    private String taxCategoryCode = "S"; // Standardsteuersatz
    private BigDecimal grossPrice = BigDecimal.ZERO;
    
    public InvoiceLineItem() {
    }
    
    public InvoiceLineItem(String description, BigDecimal quantity, BigDecimal unitPrice, BigDecimal taxPercent) {
        this.description = description;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.taxPercent = taxPercent;
        this.grossPrice = unitPrice.multiply(quantity).multiply(
            BigDecimal.ONE.add(taxPercent.divide(BigDecimal.valueOf(100)))
        );
    }
    
    // Getter und Setter
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public BigDecimal getQuantity() {
        return quantity;
    }
    
    public void setQuantity(BigDecimal quantity) {
        this.quantity = quantity;
    }
    
    public String getUnit() {
        return unit;
    }
    
    public void setUnit(String unit) {
        this.unit = unit;
    }
    
    public BigDecimal getUnitPrice() {
        return unitPrice;
    }
    
    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }
    
    public BigDecimal getTaxPercent() {
        return taxPercent;
    }
    
    public void setTaxPercent(BigDecimal taxPercent) {
        this.taxPercent = taxPercent;
    }
    
    public String getTaxCategoryCode() {
        return taxCategoryCode;
    }
    
    public void setTaxCategoryCode(String taxCategoryCode) {
        this.taxCategoryCode = taxCategoryCode;
    }
    
    public BigDecimal getGrossPrice() {
        return grossPrice;
    }
    
    public void setGrossPrice(BigDecimal grossPrice) {
        this.grossPrice = grossPrice;
    }
}
