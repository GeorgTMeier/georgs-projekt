#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Konvertiert eine GanttProject-Datei (.gan) in eine yEd-GraphML-Datei (.graphml).

.gan ist XML: Tasks unter <tasks><task id="..." name="...">, Abhängigkeiten
unter <depend id="predecessor_id" .../> (Vorgänger -> aktueller Task = Kante).

Verwendung:
  python gan2yed.py <eingabe.gan> [ausgabe.graphml]
  Ohne ausgabe.graphml wird die Ausgabe neben der Eingabe mit Suffix .graphml geschrieben.
"""

import sys
import xml.etree.ElementTree as ET
from pathlib import Path

# GraphML-/yEd-Namespaces
GRAPHML_NS = "http://graphml.graphdrawing.org/xmlns"
YED_NS = "http://www.yworks.com/xml/schema/graphml/1.1/yed"
NS = {"g": GRAPHML_NS, "y": YED_NS}


def _register_namespaces():
    ET.register_namespace("", GRAPHML_NS)
    ET.register_namespace("y", YED_NS)


def _find_tasks_and_edges(project_root):
    """Sammelt alle Tasks (id, name) und Kanten (predecessor_id -> task_id)."""
    tasks = {}   # id -> name
    edges = []   # (source_id, target_id)

    def walk(parent_elem, parent_path=""):
        for task in parent_elem.findall("task"):
            tid = task.get("id")
            name = task.get("name") or ""
            if tid is not None:
                tasks[tid] = (name.strip() or f"Task {tid}")
            for depend in task.findall("depend"):
                dep_id = depend.get("id")
                if dep_id is not None and tid is not None:
                    edges.append((dep_id, tid))
            walk(task, parent_path + "/" + str(tid) if parent_path else str(tid))

    tasks_elem = project_root.find("tasks")
    if tasks_elem is not None:
        walk(tasks_elem)

    return tasks, edges


def _escape(s):
    if s is None:
        return ""
    return (
        str(s)
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )


def write_graphml(tasks, edges, out_path):
    """Schreibt eine yEd-kompatible GraphML-Datei."""
    _register_namespaces()
    root = ET.Element(
        "{" + GRAPHML_NS + "}graphml",
        attrib={
            "xmlns": GRAPHML_NS,
            "xmlns:y": YED_NS,
        },
    )
    # Key für Knotengrafik (yEd: Label + Form)
    key_nodegraphics = ET.SubElement(
        root,
        "{" + GRAPHML_NS + "}key",
        attrib={
            "id": "d0",
            "for": "node",
            "yfiles.type": "nodegraphics",
        },
    )
    graph = ET.SubElement(
        root,
        "{" + GRAPHML_NS + "}graph",
        attrib={"id": "G", "edgedefault": "directed"},
    )

    for nid, name in tasks.items():
        node = ET.SubElement(graph, "{" + GRAPHML_NS + "}node", attrib={"id": str(nid)})
        data = ET.SubElement(node, "{" + GRAPHML_NS + "}data", attrib={"key": "d0"})
        shape = ET.SubElement(data, "{" + YED_NS + "}ShapeNode")
        nlabel = ET.SubElement(shape, "{" + YED_NS + "}NodeLabel")
        nlabel.text = name

    for i, (src, tgt) in enumerate(edges):
        if src in tasks and tgt in tasks:
            ET.SubElement(
                graph,
                "{" + GRAPHML_NS + "}edge",
                attrib={"id": f"e{i}", "source": str(src), "target": str(tgt)},
            )

    tree = ET.ElementTree(root)
    ET.indent(tree, space="  ")
    with open(out_path, "wb") as f:
        tree.write(
            f,
            encoding="utf-8",
            xml_declaration=True,
            default_namespace=GRAPHML_NS,
            method="xml",
        )


def main():
    if len(sys.argv) < 2:
        print(__doc__.strip().split("\n\n")[0], file=sys.stderr)
        print("Verwendung: python gan2yed.py <eingabe.gan> [ausgabe.graphml]", file=sys.stderr)
        sys.exit(1)

    in_path = Path(sys.argv[1])
    if not in_path.exists():
        print(f"Datei nicht gefunden: {in_path}", file=sys.stderr)
        sys.exit(2)

    out_path = Path(sys.argv[2]) if len(sys.argv) > 2 else in_path.with_suffix(".graphml")

    try:
        tree = ET.parse(in_path)
        root = tree.getroot()
    except ET.ParseError as e:
        print(f"XML-Fehler in {in_path}: {e}", file=sys.stderr)
        sys.exit(3)

    tasks, edges = _find_tasks_and_edges(root)
    if not tasks:
        print("Keine Tasks in der GanttProject-Datei gefunden.", file=sys.stderr)
        sys.exit(4)

    write_graphml(tasks, edges, out_path)
    print(f"Geschrieben: {out_path} ({len(tasks)} Knoten, {len(edges)} Kanten)")


if __name__ == "__main__":
    main()
