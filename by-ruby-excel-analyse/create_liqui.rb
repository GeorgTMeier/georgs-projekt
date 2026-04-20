#!/usr/bin/env ruby
# encoding: utf-8
#
# Erstellt liqui.xlsx aus einnahmen.xlsx:
# - einnahmen.xlsx: Spalte 1 = Betrag, Spalte 2 = Datum
# - liqui.xlsx: Spalte 1 = Datum (jedes nur einmal), Spalte 2 = aufsummierter Betrag (SUMMEWENN)
#

require "date"
require "roo"
require "write_xlsx"

EINNAHMEN_FILE = "einnahmen.xlsx"
LIQUI_FILE    = "liqui.xlsx"
EINNAHMEN_SHEET = "Einnahmen"
LIQUI_SHEET   = "Liqui"

def read_einnahmen(path)
  path = File.expand_path(path)
  unless File.file?(path)
    raise ArgumentError, "Datei nicht gefunden: #{path}"
  end

  sheet = Roo::Spreadsheet.open(path).sheet(0)
  rows = []
  sheet.each_row do |row|
    # Spalte A = Betrag, Spalte B = Datum
    betrag = row[0]   # 0-basiert: Spalte 1
    datum  = row[1]   # 0-basiert: Spalte 2
    next if betrag.nil? && datum.nil?
    # Datum normalisieren (Roo liefert oft Date oder String)
    datum = datum.to_date if datum.respond_to?(:to_date)
    datum = Date.parse(datum.to_s) if datum.is_a?(String) && datum.to_s.strip != ""
    rows << { betrag: betrag.to_f rescue 0, datum: datum }
  end
  rows
end

def unique_dates(rows)
  rows.map { |r| r[:datum] }.compact.uniq.sort
end

def create_liqui_from_einnahmen(einnahmen_path, liqui_path)
  dir = File.dirname(einnahmen_path)
  liqui_path = File.join(dir, LIQUI_FILE) if File.dirname(liqui_path) == "."
  rows = read_einnahmen(einnahmen_path)
  dates = unique_dates(rows)

  workbook = WriteXLSX.new(liqui_path)
  # Blatt 1: Einnahmen (Kopie der Quelldaten für die Formel-Referenz)
  ws_ein = workbook.add_worksheet(EINNAHMEN_SHEET)
  ws_ein.write(0, 0, "Betrag")
  ws_ein.write(0, 1, "Datum")
  rows.each_with_index do |r, i|
    ws_ein.write(i + 1, 0, r[:betrag])
    ws_ein.write(i + 1, 1, r[:datum])
  end

  # Blatt 2: Liqui – eindeutige Datumszeilen, Betrag per SUMMEWENN
  ws_liq = workbook.add_worksheet(LIQUI_SHEET)
  ws_liq.write(0, 0, "Datum")
  ws_liq.write(0, 1, "Betrag")
  dates.each_with_index do |datum, i|
    excel_row = i + 2   # Zeile 2-based für Formel (Zeile 1 = Header)
    ws_liq.write(i + 1, 0, datum)
    # SUMMEWENN: Kriterienbereich Datum (Einnahmen Spalte B), Kriterium = Datum dieser Zeile,
    # Summenbereich = Betrag (Einnahmen Spalte A)
    # In xlsx: SUMIF (Excel zeigt je nach Sprache SUMMEWENN)
    formula = "=SUMIF('#{EINNAHMEN_SHEET}'!$B:$B,$A#{excel_row},'#{EINNAHMEN_SHEET}'!$A:$A)"
    ws_liq.write_formula(i + 1, 1, formula)
  end
  workbook.close

  puts "Erstellt: #{liqui_path}"
  puts "  Blatt \"#{LIQUI_SHEET}\": Spalte 1 = Datum, Spalte 2 = Betrag (SUMMEWENN über Blatt \"#{EINNAHMEN_SHEET}\")"
end

def create_sample_einnahmen(path)
  workbook = WriteXLSX.new(path)
  ws = workbook.add_worksheet(EINNAHMEN_SHEET)
  ws.write(0, 0, "Betrag")
  ws.write(0, 1, "Datum")
  # Einige Beispieldaten (gleiches Datum mehrfach für Aufsummierung)
  [
    [100.50, "2025-01-15"],
    [50.00,  "2025-01-15"],
    [200.00, "2025-01-20"],
    [75.25,  "2025-01-20"],
    [120.00, "2025-02-01"],
  ].each_with_index do |(betrag, datum), i|
    ws.write(i + 1, 0, betrag)
    ws.write(i + 1, 1, datum)
  end
  workbook.close
  puts "Beispieldatei erstellt: #{path}"
end

def main
  base = File.dirname(__FILE__)
  einnahmen_path = File.join(base, EINNAHMEN_FILE)
  liqui_path     = File.join(base, LIQUI_FILE)

  unless File.file?(einnahmen_path)
    puts "einnahmen.xlsx nicht gefunden. Erstelle Beispieldatei."
    create_sample_einnahmen(einnahmen_path)
  end

  create_liqui_from_einnahmen(einnahmen_path, liqui_path)
end

main if __FILE__ == $PROGRAM_NAME
