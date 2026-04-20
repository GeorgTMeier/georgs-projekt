# frozen_string_literal: true

require 'tk'
require 'tkextlib/tile'
require_relative 'db_service'

# Hauptfenster: Haupt-Grid (test2view), Grid „gleiche Art“, Preview, Buttons, Summe, Debug.
class MainWindow
  def initialize
    @root = TkRoot.new { title 'GTM: Turbo DataGrid (Ruby/Tk)'; geometry '1200x800' }
    @rows = []
    @columns = []
    @selected_row_index = nil
    @event_text = '-'
    build_ui
    load_data
  end

  def run
    Tk.mainloop
  end

  private

  def build_ui
    # Linke Seite: Grids + Buttons + Debug
    left = TkFrame.new(@root) { pack side: :left, fill: :both, expand: true, padx: 5, pady: 5 }

    # Haupt-Grid (Treeview)
    grid_frame = TkFrame.new(left) { pack fill: :both, expand: true }
    TkLabel.new(grid_frame) { text 'Haupt-Grid (test2view)'; pack anchor: :w }.pack(anchor: :w)
    tree_frame = TkFrame.new(grid_frame) { pack fill: :both, expand: true }
    @tree = Tk::Tile::Treeview.new(tree_frame) do
      pack side: :left, fill: :both, expand: true
      height 12
    end
    tree_scroll_y = TkScrollbar.new(tree_frame) { pack side: :right, fill: :y }
    tree_scroll_x = TkScrollbar.new(tree_frame) { orient :horizontal; pack side: :bottom, fill: :x }
    @tree.yscrollcommand tree_scroll_y.set
    @tree.xscrollcommand tree_scroll_x.set
    tree_scroll_y.command { |*a| @tree.yview(*a) }
    tree_scroll_x.command { |*a| @tree.xview(*a) }
    @tree.bind('<<TreeviewSelect>>') { on_tree_select }

    # Summe
    @sum_label = TkLabel.new(left) { text 'Summe: 0,00'; pack anchor: :w; font TkFont.new(weight: 'bold') }
    @sum_label.pack(anchor: :w)

    # Grid „Datensätze mit gleicher Art“
    TkLabel.new(left) { text 'Datensätze mit gleicher Art:'; pack anchor: :w; font TkFont.new(weight: 'bold') }.pack(anchor: :w)
    same_frame = TkFrame.new(left) { pack fill: :both, expand: false }
    @tree_same = Tk::Tile::Treeview.new(same_frame) do
      pack side: :left, fill: :both, expand: true
      height 6
    end
    same_scroll_y = TkScrollbar.new(same_frame) { pack side: :right, fill: :y }
    same_scroll_x = TkScrollbar.new(same_frame) { orient :horizontal; pack side: :bottom, fill: :x }
    @tree_same.yscrollcommand same_scroll_y.set
    @tree_same.xscrollcommand same_scroll_x.set
    same_scroll_y.command { |*a| @tree_same.yview(*a) }
    same_scroll_x.command { |*a| @tree_same.xview(*a) }
    same_frame.pack(fill: :x)

    # Buttons
    btn_frame = TkFrame.new(left) { pack fill: :x, pady: 5 }
    TkButton.new(btn_frame) { text 'Laden'; command { load_data }; pack side: :left, padx: 3 }.pack(side: :left, padx: 3)
    TkButton.new(btn_frame) { text 'Speichern'; command { Tk.messageBox type: 'info', message: 'Speichern (Adapter) – ggf. manuell' }; pack side: :left, padx: 3 }.pack(side: :left, padx: 3)
    TkButton.new(btn_frame) { text 'Bt1. gtm'; command { Tk.messageBox type: 'info', message: 'Bt1. gtm' }; pack side: :left, padx: 3 }.pack(side: :left, padx: 3)
    TkButton.new(btn_frame) { text 'update row'; command { save_row }; pack side: :left, padx: 3 }.pack(side: :left, padx: 3)

    # Debug
    debug_frame = TkFrame.new(left) { pack fill: :x }
    @debug_row = TkLabel.new(debug_frame) { text 'Zeile: -'; pack side: :left, padx: 5 }
    @debug_col = TkLabel.new(debug_frame) { text 'Spalte: -'; pack side: :left, padx: 5 }
    @debug_event = TkLabel.new(debug_frame) { text 'Event: -'; pack side: :left, padx: 5 }

    # Rechte Seite: Preview
    right = TkFrame.new(@root) { pack side: :right, fill: :y, padx: 5, pady: 5 }
    TkLabel.new(right) { text 'Preview'; font TkFont.new(weight: 'bold'); pack anchor: :w }.pack(anchor: :w)
    @preview_entries = 6.times.map do |i|
      f = TkFrame.new(right) { pack fill: :x }
      TkLabel.new(f) { text "t0#{i}"; width 4; pack side: :left }
      e = TkEntry.new(f) { width 14; pack side: :left, padx: 2 }
      e.pack(side: :left, padx: 2)
      e
    end
    TkButton.new(right) { text 'save row'; command { save_row }; pack pady: 5 }.pack(pady: 5)
  end

  def on_tree_select
    sel = @tree.selection
    return if sel.empty?
    item = sel.first
    kids = @tree.children('')
    idx = kids.index(item)
    return unless idx
    @selected_row_index = idx
    @event_text = 'neue Zelle'
    update_debug
    update_preview
    update_same_art_grid
  end

  def update_debug
    @debug_row.configure text: "Zeile: #{@selected_row_index.nil? ? '-' : @selected_row_index}"
    @debug_event.configure text: "Event: #{@event_text}"
  end

  def update_preview
    return if @selected_row_index.nil? || @rows.empty? || @selected_row_index >= @rows.size
    row = @rows[@selected_row_index]
    @columns.each_with_index do |col, i|
      next if i >= @preview_entries.size
      val = row[col] || row[col.to_s.downcase] || ''
      @preview_entries[i].set(val.to_s)
    end
  end

  def same_art_rows
    return [] if @selected_row_index.nil? || @rows.empty? || @selected_row_index >= @rows.size
    art_key = @columns.find { |c| c.to_s.downcase == 'art' } || 'art'
    art_val = (@rows[@selected_row_index][art_key] || @rows[@selected_row_index][art_key.to_s])&.to_s
    return [] if art_val.nil? || art_val.empty?
    @rows.select { |r| (r[art_key] || r[art_key.to_s])&.to_s == art_val }
  end

  def summe
    betrag_key = @columns.find { |c| c.to_s.downcase == 'betrag' } || 'betrag'
    @rows.reduce(0.0) do |s, r|
      v = r[betrag_key] || r[betrag_key.to_s]
      s + (v.nil? ? 0.0 : v.to_s.gsub(',', '.').to_f)
    end
  end

  def update_same_art_grid
    clear_tree(@tree_same)
    return if @columns.empty?
    configure_tree_columns(@tree_same, @columns)
    same_art_rows.each do |row|
      vals = @columns.map { |c| (row[c] || row[c.to_s]).to_s }
      @tree_same.insert('', 'end', text: vals[0], values: vals[1..])
    end
  end

  def load_data
    @event_text = 'Laden...'
    update_debug
    @root.update
    @rows = DbService.load_test2view
    # PG::Result rows: Hash mit Symbol- oder String-Keys
    @rows = @rows.map { |r| r.transform_keys(&:to_s) } if @rows.any? && @rows.first.keys.any? { |k| k.is_a?(Symbol) }
    @columns = @rows.empty? ? [] : @rows.first.keys
    fill_main_tree
    update_same_art_grid
    @sum_label.configure text: "Summe: #{format('%.2f', summe)}"
    @event_text = 'geladen'
    update_debug
    update_preview
  rescue StandardError => e
    @event_text = "Fehler: #{e.message}"
    update_debug
    Tk.messageBox type: 'ok', icon: 'error', message: e.message
  end

  def fill_main_tree
    clear_tree(@tree)
    return if @columns.empty?
    configure_tree_columns(@tree, @columns)
    @rows.each do |row|
      vals = @columns.map { |c| (row[c] || row[c.to_s]).to_s }
      @tree.insert('', 'end', text: vals[0], values: vals[1..])
    end
  end

  def configure_tree_columns(tree, cols)
    tree['columns'] = cols[1..] || []
    tree['show'] = 'headings'
    tree.column('#0', width: 80, minwidth: 60)
    tree.heading('#0', text: cols[0].to_s)
    cols[1..]&.each_with_index do |col, i|
      tree.column(col, width: 90, minwidth: 60)
      tree.heading(col, text: col.to_s)
    end
  end

  def clear_tree(tree)
    tree.children('').each { |id| tree.delete(id) }
  end

  def save_row
    return if @preview_entries.empty?
    pk1 = @preview_entries[0].get.to_s.strip.to_i
    betrag_s = @preview_entries[1].get.to_s.gsub(',', '.')
    betrag = betrag_s.to_f
    if pk1.zero? && @preview_entries[0].get.to_s.strip != '0'
      Tk.messageBox type: 'ok', icon: 'warning', message: 't00 (pk1) muss eine Zahl sein.'
      return
    end
    gewerk = @preview_entries[2].get.to_s
    bvh    = @preview_entries[3].get.to_s
    art    = @preview_entries[4].get.to_s
    test   = @preview_entries[5].get.to_s
    DbService.update_buchpos_row(pk1: pk1, bvh: bvh, test: test, betrag: betrag, art: art, gewerk: gewerk)
    @event_text = 'zelle geändert'
    update_debug
    Tk.messageBox type: 'ok', message: 'Zeile gespeichert.'
  rescue StandardError => e
    Tk.messageBox type: 'ok', icon: 'error', message: "Fehler: #{e.message}"
  end
end
