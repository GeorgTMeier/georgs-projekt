# Grid Editor (Ruby) – Postgres oder REST

Kleine Ruby‑Webapp, die Daten als Grid im Browser anzeigt und Inline‑Edits (Zellen bearbeiten) speichern kann.

- **Postgres‑Modus**: direkte DB‑Verbindung (`app.rb`)
- **REST‑Modus**: Daten via REST‑API laden & zurückschreiben (`rest_app.rb`)

## Voraussetzungen

- Ruby (z.B. RubyInstaller für Windows)
- Zugriff auf eine PostgreSQL‑DB

## Setup

Im Projektordner:

```bash
bundle install
```

## Postgres‑Modus (app.rb) – Konfiguration (ENV)

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

## REST‑Modus (rest_app.rb)

Der REST‑Modus lädt Zeilen per `GET` von einer API und speichert Edits per `PATCH` oder `PUT` zurück zur API.

### Konfiguration (ENV)

- `API_BASE_URL` (**required**) z.B. `https://api.example.com/`
- `LIST_PATH` (default: `/items`) – `GET` Liste
- `UPDATE_PATH` (default: `/items/%{id}`) – Update‑Endpoint (Template)
- `SHOW_PATH` (default: `UPDATE_PATH`) – `GET` Single‑Row (für Formularansicht)
- `UPDATE_METHOD` (default: `PATCH`) – `PATCH` oder `PUT`
- `PRIMARY_KEY` (default: `id`) – Feldname der ID
- `LIMIT` (default: `200`) – wird als `?limit=` angehängt, falls `LIST_PATH` noch kein `?` hat
- Auth optional:
  - `API_TOKEN` → `Authorization: Bearer <token>`
  - `API_KEY` + `API_KEY_HEADER` (default Header: `X-API-Key`)

Optional:

- `COLUMNS` – Spaltenliste (CSV), z.B. `id,name,email`

### Start

```bash
bundle exec ruby rest_app.rb
```

Beispiel PowerShell:

```powershell
$env:API_BASE_URL="https://api.example.com/"
$env:LIST_PATH="/users"
$env:UPDATE_PATH="/users/%{id}"
$env:PRIMARY_KEY="id"
$env:UPDATE_METHOD="PATCH"
$env:API_TOKEN="..."
bundle exec ruby rest_app.rb
```

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
