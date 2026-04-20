#!/usr/bin/env ruby
# encoding: utf-8
#
# Listet alle externen Links (Verweise auf andere Excel-Dateien) in einer XLSX-Datei auf.
# XLSX ist ein ZIP-Archiv; externe Workbook-Referenzen stehen in workbook.xml und
# in den Relationship-Dateien der External-Link-Teile.
#

require 'zip'
require 'rexml/document'


def parse_rels(zip_file, rels_path)
  entry = zip_file.find_entry(rels_path)
  return {} unless entry

  xml = zip_file.get_input_stream(entry)&.read
  return {} unless xml

  doc = REXML::Document.new(xml)
  result = {}
  doc.root.each_element('//Relationship') do |rel|
    id = rel.attributes['Id']
    target = rel.attributes['Target']
    type = rel.attributes['Type'] || ''
    result[id] = { target: target, type: type }
  end
  result
end

# Vorkommen: { worksheet: String, cell: String, formula: String, link_path: String }
def external_links_from_xlsx(path)
  path = File.expand_path(path)
  unless File.file?(path)
    raise ArgumentError, "Datei nicht gefunden: #{path}"
  end

  link_paths = []   # geordnete Liste der externen Dateipfade ([1], [2], ...)
  occurrences = []  # { worksheet:, cell:, formula:, link_path: }

  Zip::File.open(path) do |zip|
    wb_entry = zip.find_entry('xl/workbook.xml')
    return { paths: [], occurrences: [] } unless wb_entry

    wb_xml = zip.get_input_stream(wb_entry)&.read
    return { paths: [], occurrences: [] } unless wb_xml

    wb_doc = REXML::Document.new(wb_xml)
    ref_ids = []
    REXML::XPath.each(wb_doc, '//*[local-name()="externalReference"]') do |el|
      rid = el.attributes['r:id'] || el.attributes['id']
      ref_ids << rid if rid
    end

    wb_rels = parse_rels(zip, 'xl/_rels/workbook.xml.rels')

    # Externe Link-Pfade in gleicher Reihenfolge wie ref_ids (für [1], [2], ...)
    ref_ids.each do |rid|
      next unless wb_rels[rid]
      part_target = wb_rels[rid][:target]
      type = wb_rels[rid][:type]
      next unless type.to_s.include?('externalLink')

      part_path = part_target.start_with?('xl/') ? part_target : "xl/#{part_target}"
      rels_path = "#{File.dirname(part_path)}/_rels/#{File.basename(part_path)}.rels"
      part_rels = parse_rels(zip, rels_path)
      part_rels.each do |_id, data|
        target_path = data[:target]
        rel_type = data[:type].to_s
        if target_path && (rel_type.include?('externalLinkPath') || rel_type.include?('externalReference'))
          link_paths << target_path
          break
        end
      end
    end

    return { paths: link_paths.uniq, occurrences: [] } if link_paths.empty?

    # Sheet-Namen und -Pfade: <sheet name="..." r:id="rId1"/> -> worksheets/sheet1.xml
    sheets = []
    REXML::XPath.each(wb_doc, '//*[local-name()="sheet"]') do |el|
      name = el.attributes['name']
      rid = el.attributes['r:id'] || el.attributes['id']
      next unless name && rid && wb_rels[rid]
      target = wb_rels[rid][:target]
      sheet_path = target.start_with?('xl/') ? target : "xl/#{target}"
      sheets << { name: name, path: sheet_path }
    end

    # In jedem Worksheet Zellen mit Formeln durchsuchen; externe Ref = [1], [2] oder [Dateiname.xlsx]
    sheets.each do |sheet|
      entry = zip.find_entry(sheet[:path])
      next unless entry
      sheet_xml = zip.get_input_stream(entry)&.read
      next unless sheet_xml

      sheet_doc = REXML::Document.new(sheet_xml)
      REXML::XPath.each(sheet_doc, '//*[local-name()="c"]') do |cell_el|
        cell_ref = cell_el.attributes['r']
        next unless cell_ref
        f_el = cell_el.elements['*[local-name()="f"]']
        next unless f_el
        formula = f_el.text.to_s.strip
        next if formula.empty?

        # Externe Referenz: [1], [2], ... (Index) oder [Dateiname.xlsx]...
        external_index = formula.match(/\A\[(\d+)\]/)
        external_name = formula.match(/\A\[([^\]]+\.xlsx?)\]/i)

        link_path = nil
        if external_index
          idx = external_index[1].to_i
          link_path = link_paths[idx - 1] if idx >= 1 && idx <= link_paths.size
        elsif external_name
          # Formel enthält Dateinamen; mit gespeichertem Pfad abgleichen (Dateiname am Ende)
          fn = external_name[1]
          link_path = link_paths.find { |p| File.basename(p).downcase == fn.downcase } || fn
        end

        if link_path
          occurrences << { worksheet: sheet[:name], cell: cell_ref, formula: formula, link_path: link_path }
        end
      end
    end
  end

  { paths: link_paths.uniq, occurrences: occurrences }
end

def main
  xlsx_path = ARGV[0] || 'beispiel.xlsx'
  xlsx_path = File.join(File.dirname(__FILE__), xlsx_path) unless File.exist?(xlsx_path)

  unless File.file?(xlsx_path)
    $stderr.puts "Fehler: Datei nicht gefunden: #{xlsx_path}"
    $stderr.puts "Verwendung: ruby list_external_links.rb [datei.xlsx]"
    exit 1
  end

  puts "Datei: #{xlsx_path}"
  puts 'Externe Links (andere Excel-Dateien) und Vorkommen:'
  puts '–' * 50

  data = external_links_from_xlsx(xlsx_path)
  paths = data[:paths]
  occurrences = data[:occurrences]

  if paths.empty? && occurrences.empty?
    puts '(keine externen Workbook-Links gefunden)'
  else
    by_link = occurrences.group_by { |o| o[:link_path] }
    all_links = paths.uniq | by_link.keys
    all_links.each do |link_path|
      occs = by_link[link_path] || []
      puts "  ► #{link_path}"
      if occs.empty?
        puts "      (nur in Metadaten, keine Zellformel gefunden)"
      else
        occs.each do |o|
          puts "      Worksheet \"#{o[:worksheet]}\", Zelle #{o[:cell]}: =#{o[:formula]}"
        end
      end
      puts
    end
  end
end

main if __FILE__ == $PROGRAM_NAME
