# Postgres Grid Editor (Ruby)

Kleine Ruby‑Webapp, die sich mit einer PostgreSQL‑Datenbank verbindet, eine Tabelle als Grid im Browser anzeigt und Inline‑Edits (Zellen bearbeiten) direkt zurück in die DB speichert.

## Voraussetzungen

- Ruby (z.B. RubyInstaller für Windows)
- Zugriff auf eine PostgreSQL‑DB

## Setup

Im Projektordner:

```bash
bundle install
```

## Konfiguration (ENV)

Du kannst entweder `DATABASE_URL` setzen **oder** die `PG*` Variablen.

### Variante A: DATABASE_URL (einfach)

PowerShell:

```powershell
$env:DATABASE_URL="postgres://USER:PASSWORD@HOST:5432/DBNAME"
```

### Variante B: PG* Variablen

```powershell
$env:PGHOST="127.0.0.1"
$env:PGPORT="5432"
$env:PGDATABASE="deine_db"
$env:PGUSER="dein_user"
$env:PGPASSWORD="dein_passwort"
```

### App‑Optionen

- `TABLE` (default: `people`) – welche Tabelle angezeigt/editiert wird
- `PRIMARY_KEY` (default: `id`) – Name der PK‑Spalte
- `LIMIT` (default: `200`) – wie viele Zeilen angezeigt werden
- `PORT` (default: `4567`) – Serverport
- `BIND` (default: `127.0.0.1`) – Bind‑Adresse

Beispiel:

```powershell
$env:TABLE="customers"
$env:PRIMARY_KEY="customer_id"
```

## Start

```bash
bundle exec ruby app.rb
```

Dann im Browser öffnen: `http://127.0.0.1:4567/`

## Bedienung

- Grid: Zelle anklicken → ändern → Fokus verlassen (oder Enter) → wird gespeichert
- Fallback: Pro Zeile gibt es einen „Edit“-Link (Formularansicht)

## Beispiel‑Tabelle (optional)

Wenn du eine Testtabelle brauchst:

```sql
create table if not exists people (
  id bigserial primary key,
  name text not null,
  email text,
  age integer,
  active boolean default true
);

insert into people (name, email, age, active)
values
  ('Ada', 'ada@example.com', 32, true),
  ('Linus', 'linus@example.com', 55, true)
on conflict do nothing;
```
