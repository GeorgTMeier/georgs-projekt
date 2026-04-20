import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/db_service.dart';

/// Hauptbildschirm: Haupt-Grid (test2view), Grid „gleiche Art“, Preview, Buttons, Summe, Debug.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> _rows = [];
  int? _selectedRowIndex;
  String _eventText = '-';
  String _summeText = '';
  bool _loading = false;
  String? _error;

  final _previewControllers = List.generate(6, (_) => TextEditingController());

  static String _cellStr(Map<String, dynamic> row, String key) {
    final k = row.containsKey(key) ? key : key.toLowerCase();
    final v = row[k];
    if (v == null) return '';
    return v.toString();
  }

  static dynamic _cell(Map<String, dynamic> row, String key) {
    final k = row.containsKey(key) ? key : key.toLowerCase();
    return row[k];
  }

  List<Map<String, dynamic>> get _sameArtRows {
    if (_selectedRowIndex == null || _selectedRowIndex! < 0 || _selectedRowIndex! >= _rows.length) {
      return [];
    }
    final art = _cellStr(_rows[_selectedRowIndex!], 'art');
    if (art.isEmpty) return [];
    return _rows.where((r) => _cellStr(r, 'art') == art).toList();
  }

  double get _summe {
    final betragKey = _rows.isNotEmpty && _rows.first.containsKey('Betrag') ? 'Betrag' : 'betrag';
    double sum = 0;
    for (final row in _rows) {
      final v = _cell(row, betragKey);
      if (v != null) {
        if (v is num) sum += v.toDouble();
        else sum += double.tryParse(v.toString()) ?? 0;
      }
    }
    return sum;
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
      _eventText = 'Laden...';
    });
    try {
      final data = await DbService.loadTest2View();
      setState(() {
        _rows = data;
        _loading = false;
        _eventText = 'geladen';
        _summeText = 'Summe: ${NumberFormat.decimalPattern('de-DE').format(_summe)}';
        _updatePreview();
      });
    } catch (e, st) {
      setState(() {
        _loading = false;
        _error = e.toString();
        _eventText = 'Fehler';
      });
    }
  }

  void _updatePreview() {
    if (_selectedRowIndex == null || _selectedRowIndex! >= _rows.length || _rows.isEmpty) return;
    final row = _rows[_selectedRowIndex!];
    final keys = _rows.first.keys.toList();
    for (var i = 0; i < 6 && i < keys.length && i < _previewControllers.length; i++) {
      final k = keys[i].toString();
      final v = row[k] ?? row[k.toLowerCase()];
      _previewControllers[i].text = v?.toString() ?? '';
    }
  }

  void _onSelectRow(int index) {
    setState(() {
      _selectedRowIndex = index;
      _eventText = 'neue Zelle';
      _updatePreview();
    });
  }

  Future<void> _saveRowFromPreview() async {
    if (_selectedRowIndex == null || _selectedRowIndex! >= _rows.length) return;
    final pk1 = int.tryParse(_previewControllers[0].text);
    if (pk1 == null) {
      _showSnack('Ungültige ID (pk1)');
      return;
    }
    final betrag = double.tryParse(_previewControllers[1].text.replaceFirst(',', '.'));
    if (betrag == null) {
      _showSnack('Ungültiger Betrag');
      return;
    }
    setState(() => _eventText = 'Speichere...');
    try {
      await DbService.updateBuchposRow(
        pk1: pk1,
        bvh: _previewControllers[3].text.isEmpty ? null : _previewControllers[3].text,
        test: _previewControllers[5].text.isEmpty ? null : _previewControllers[5].text,
        betrag: betrag,
        art: _previewControllers[4].text.isEmpty ? null : _previewControllers[4].text,
        gewerk: _previewControllers[2].text.isEmpty ? null : _previewControllers[2].text,
      );
      _showSnack('Zeile gespeichert');
      setState(() => _eventText = 'zelle geändert');
    } catch (e) {
      _showSnack('Fehler: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    for (final c in _previewControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final columns = _rows.isEmpty ? <String>[] : _rows.first.keys.map((e) => e.toString()).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('GTM: Turbo DataGrid (Flutter)'),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Fehler: $_error', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadData, child: const Text('Erneut laden')),
                  ],
                ),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Haupt-Grid
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.blue.shade50,
                          ),
                          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 800),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _buildDataTable(_rows, columns, onSelectRow: _onSelectRow, selectedIndex: _selectedRowIndex),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Summe
                        Text(
                          _summeText.isEmpty ? 'Summe: 0,00' : _summeText,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // Grid „Datensätze mit gleicher Art“
                        const Text(
                          'Datensätze mit gleicher Art:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.yellow.shade100,
                          ),
                          constraints: const BoxConstraints(maxHeight: 180, maxWidth: 800),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _buildDataTable(_sameArtRows, columns.isEmpty ? <String>[] : columns),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Buttons
                        Wrap(
                          spacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: _loading ? null : _loadData,
                              child: const Text('Laden'),
                            ),
                            ElevatedButton(
                              onPressed: _loading ? null : () => _showSnack('Speichern (Adapter-Update) – in Flutter ggf. manuell)'),
                              child: const Text('Speichern'),
                            ),
                            ElevatedButton(
                              onPressed: _loading ? null : () => _showSnack('Bt1. gtm'),
                              child: const Text('Bt1. gtm'),
                            ),
                            ElevatedButton(
                              onPressed: _loading ? null : () => _saveRowFromPreview(),
                              child: const Text('update row'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Debug
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Zeile: ${_selectedRowIndex ?? '-'}'),
                              Text('Spalte: -'),
                              Text('Event: $_eventText'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Preview-Panel rechts
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey.shade100,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...List.generate(6, (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(
                            controller: _previewControllers[i],
                            decoration: InputDecoration(
                              labelText: 't0$i',
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        )),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveRowFromPreview,
                          child: const Text('save row'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDataTable(
    List<Map<String, dynamic>> data,
    List<String> columns, {
    void Function(int index)? onSelectRow,
    int? selectedIndex,
  }) {
    if (columns.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Keine Spalten'),
      );
    }
    final nf = NumberFormat.currency(locale: 'de_DE', symbol: '€', decimalDigits: 2);
    return DataTable(
      headingRowColor: WidgetStateProperty.all(Colors.blue.shade900),
      headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
      rows: List.generate(data.length, (i) {
        final row = data[i];
        final isSelected = selectedIndex != null && selectedIndex == (onSelectRow != null ? _rows.indexOf(row) : i);
        return DataRow(
          selected: isSelected,
          onSelectChanged: onSelectRow != null ? (_) => onSelectRow(_rows.indexOf(row)) : null,
          cells: columns.map((col) {
            final key = row.containsKey(col) ? col : col.toLowerCase();
            var v = row[key];
            String text = v == null ? '' : v.toString();
            if (key.toLowerCase() == 'betrag' && v != null) {
              if (v is num) text = nf.format(v);
              else if (double.tryParse(v.toString()) != null) text = nf.format(double.parse(v.toString()));
            }
            return DataCell(Text(text));
          }).toList(),
        );
      }),
    );
  }
}
