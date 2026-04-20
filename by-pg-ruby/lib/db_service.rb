# frozen_string_literal: true

require 'pg'

# PostgreSQL-Service für test2view und buchpos (wie by-pg-grid).
module DbService
  HOST     = '192.168.207.160'
  PORT     = 5432
  DBNAME   = 'RK2'
  USER     = 'postgres'
  PASSWORD = 'Ole1brumm'

  def self.conn
    PG.connect(
      host: HOST,
      port: PORT,
      dbname: DBNAME,
      user: USER,
      password: PASSWORD
    )
  end

  # Lädt alle Zeilen aus public.test2view.
  # Rückgabe: Array von Hashes (Spaltenname => Wert)
  def self.load_test2view
    c = self.conn
    result = c.exec('SELECT * FROM public.test2view')
    cols = result.fields
    rows = result.values.map { |vals| cols.zip(vals).to_h }
    c.close
    rows
  rescue PG::Error => e
    raise "LoadTest2View Fehler: #{e.message}"
  end

  # UPDATE public.buchpos für eine Zeile (wie save row / update row).
  def self.update_buchpos_row(pk1:, bvh:, test:, betrag:, art:, gewerk:)
    c = self.conn
    c.exec_params(
      'UPDATE public.buchpos SET bvh=$1, test=$2, betrag=$3, art=$4, gewerk=$5 WHERE pk1=$6',
      [bvh.to_s, test.to_s, betrag.to_f, art.to_s, gewerk.to_s, pk1.to_i]
    )
    c.close
  rescue PG::Error => e
    raise "UpdateBuchposRow Fehler: #{e.message}"
  end
end
