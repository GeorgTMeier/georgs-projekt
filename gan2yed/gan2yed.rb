#!/usr/bin/env ruby
# encoding: utf-8
#
# Konvertiert eine GanttProject-Datei (.gan) in eine yEd-GraphML-Datei (.graphml).
#
# .gan ist XML: Tasks unter <tasks><task id="..." name="...">, Abhängigkeiten
# unter <depend id="predecessor_id" .../> (Vorgänger -> aktueller Task = Kante).
#
# Verwendung:
#   ruby gan2yed.rb <eingabe.gan> [ausgabe.graphml]
#   Ohne ausgabe.graphml wird die Ausgabe neben der Eingabe mit Suffix .graphml geschrieben.
#

require 'rexml/document'
require 'rexml/formatters/pretty'

GRAPHML_NS = 'http://graphml.graphdrawing.org/xmlns'
YED_NS     = 'http://www.yworks.com/xml/schema/graphml/1.1/yed'

def find_tasks_and_edges(doc)
  tasks = {}
  edges = []
  doc.elements.each('//task') do |task|
    tid = task.attributes['id']
    next unless tid
    name = (task.attributes['name'] || '').strip
    tasks[tid] = name.empty? ? "Task #{tid}" : name
    task.elements.each('depend') do |dep|
      dep_id = dep.attributes['id']
      edges << [dep_id, tid] if dep_id
    end
  end
  [tasks, edges]
end

def write_graphml(tasks, edges, out_path)
  doc = REXML::Document.new
  doc << REXML::XMLDecl.new('1.0', 'UTF-8')

  root = REXML::Element.new('graphml')
  root.add_attribute('xmlns', GRAPHML_NS)
  root.add_attribute('xmlns:y', YED_NS)
  doc.add_element(root)

  key = REXML::Element.new('key')
  key.add_namespace(GRAPHML_NS)
  key.add_attribute('id', 'd0')
  key.add_attribute('for', 'node')
  key.add_attribute('yfiles.type', 'nodegraphics')
  root.add_element(key)

  graph = REXML::Element.new('graph')
  graph.add_namespace(GRAPHML_NS)
  graph.add_attribute('id', 'G')
  graph.add_attribute('edgedefault', 'directed')
  root.add_element(graph)

  tasks.each do |nid, name|
    node = REXML::Element.new('node')
    node.add_namespace(GRAPHML_NS)
    node.add_attribute('id', nid.to_s)
    graph.add_element(node)

    data = REXML::Element.new('data')
    data.add_namespace(GRAPHML_NS)
    data.add_attribute('key', 'd0')
    node.add_element(data)

    shape = REXML::Element.new('ShapeNode')
    shape.add_namespace('y', YED_NS)
    data.add_element(shape)

    nlabel = REXML::Element.new('NodeLabel')
    nlabel.add_namespace('y', YED_NS)
    nlabel.text = name
    shape.add_element(nlabel)
  end

  edges.each_with_index do |(src, tgt), i|
    next unless tasks[src] && tasks[tgt]
    edge = REXML::Element.new('edge')
    edge.add_namespace(GRAPHML_NS)
    edge.add_attribute('id', "e#{i}")
    edge.add_attribute('source', src.to_s)
    edge.add_attribute('target', tgt.to_s)
    graph.add_element(edge)
  end

  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  File.open(out_path, 'w:UTF-8') { |f| formatter.write(doc, f) }
end

def main
  if ARGV.empty?
    warn 'Konvertiert eine GanttProject-Datei (.gan) in eine yEd-GraphML-Datei (.graphml).'
    warn 'Verwendung: ruby gan2yed.rb <eingabe.gan> [ausgabe.graphml]'
    exit 1
  end

  in_path = ARGV[0]
  unless File.file?(in_path)
    warn "Datei nicht gefunden: #{in_path}"
    exit 2
  end

  out_path = ARGV[1] || in_path.sub(/\.gan\z/i, '.graphml')

  begin
    doc = REXML::Document.new(File.read(in_path))
  rescue REXML::ParseException => e
    warn "XML-Fehler in #{in_path}: #{e.message}"
    exit 3
  end

  tasks, edges = find_tasks_and_edges(doc)
  if tasks.empty?
    warn 'Keine Tasks in der GanttProject-Datei gefunden.'
    exit 4
  end

  write_graphml(tasks, edges, out_path)
  puts "Geschrieben: #{out_path} (#{tasks.size} Knoten, #{edges.size} Kanten)"
end

main if __FILE__ == $PROGRAM_NAME
