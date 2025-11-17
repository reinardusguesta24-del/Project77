<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>PG Streaming Replication — File untuk GitHub</title>
  <style>
    body{font-family:system-ui,-apple-system,Segoe UI,Roboto,"Helvetica Neue",Arial;margin:24px;color:#111}
    h1{font-size:20px;margin-bottom:6px}
    p.lead{margin-top:0;color:#444}
    .file{border:1px solid #e3e3e3;border-radius:8px;padding:12px;margin:14px 0;background:#fafafa}
    pre{background:#1e1e1e;color:#dcdcdc;padding:12px;border-radius:6px;overflow:auto}
    .meta{display:flex;gap:8px;align-items:center;margin-bottom:8px}
    button{padding:6px 10px;border-radius:6px;border:1px solid #bbb;background:#fff;cursor:pointer}
    button.copy{background:#0b74de;color:#fff;border:0}
    button.download{background:#2b9348;color:#fff;border:0}
    small{color:#666}
    .hint{background:#fff7cc;padding:10px;border-radius:6px;border:1px solid #ffe58a}
  </style>
</head>
<body>
  <h1>PG Streaming Replication — File siap untuk di-copy ke GitHub</h1>
  <p class="lead">Klik <strong>Copy</strong> untuk menyalin isi file ke clipboard atau <strong>Download</strong> untuk mengunduh file. Setelah itu buat repositori Git dan push file seperti biasa.</p>

  <div class="hint"><strong>Langkah singkat:</strong> 1) Buat folder sesuai struktur di repo Anda (primary/initdb, replica). 2) Copy & paste isi file di bawah ke file dengan nama yang sama. 3) Commit & push ke GitHub. 4) Jalankan <code>docker compose up -d</code> di mesin yang memiliki Docker.</div>

  <!-- docker-compose.yml -->
  <div class="file">
    <div class="meta">
      <strong>docker-compose.yml</strong>
      <button class="copy" data-target="compose">Copy</button>
      <button class="download" data-target="compose" data-fname="docker-compose.yml">Download</button>
    </div>
    <pre id="compose">version: "3.8"

services:
  primary:
    image: postgres:15
    container_name: pg-primary
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: example
      POSTGRES_DB: maindb
    volumes:
      - primary_data:/var/lib/postgresql/data
      - ./primary/initdb:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    networks:
      - pgnet

  replica:
    build:
      context: ./replica
    container_name: pg-replica
    environment:
      POSTGRES_PASSWORD: example
      PGPASSWORD: replicatorpass
    depends_on:
      - primary
    volumes:
      - replica_data:/var/lib/postgresql/data
    ports:
      - "5433:5432"
    networks:
      - pgnet

networks:
  pgnet:

volumes:
  primary_data:
  replica_data:
</pre>
  </div>

  <!-- primary/initdb/01-init.sql -->
  <div class="file">
    <div class="meta">
      <strong>primary/initdb/01-init.sql</strong>
      <button class="copy" data-target="initsql">Copy</button>
      <button class="download" data-target="initsql" data-fname="primary/initdb/01-init.sql">Download</button>
    </div>
    <pre id="initsql">-- Membuat user khusus untuk replication
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicatorpass';

-- Mengatur parameter penting
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET max_wal_senders = '10';
ALTER SYSTEM SET wal_keep_size = '64MB';
ALTER SYSTEM SET hot_standby = 'on';

-- Buat database contoh
CREATE DATABASE demo;
\c demo

CREATE TABLE items (
  id serial PRIMARY KEY,
  data text,
  created_at timestamptz DEFAULT now()
);

INSERT INTO items (data) VALUES ('row pertama dari primary');
</pre>
  </div>

  <!-- replica/Dockerfile -->
  <div class="file">
    <div class="meta">
      <strong>replica/Dockerfile</strong>
      <button class="copy" data-target="df">Copy</button>
      <button class="download" data-target="df" data-fname="replica/Dockerfile">Download</button>
    </div>
    <pre id="df">FROM postgres:15

RUN apt-get update && apt-get install -y netcat-traditional

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["postgres"]
</pre>
  </div>

  <!-- replica/entrypoint.sh -->
  <div class="file">
    <div class="meta">
      <strong>replica/entrypoint.sh</strong>
      <button class="copy" data-target="entry">Copy</button>
      <button class="download" data-target="entry" data-fname="replica/entrypoint.sh">Download</button>
    </div>
    <pre id="entry">#!/bin/bash
set -e

PGDATA="/var/lib/postgresql/data"
PRIMARY_HOST="primary"
PRIMARY_PORT="5432"
REPL_USER="replicator"
REPL_PASSWORD="replicatorpass"

echo "Menunggu primary siap..."
until nc -z $PRIMARY_HOST $PRIMARY_PORT; do
  sleep 1
done

if [ -z "$(ls -A $PGDATA)" ]; then
  echo "Melakukan pg_basebackup dari primary..."

  echo "$PRIMARY_HOST:$PRIMARY_PORT:*:$REPL_USER:$REPL_PASSWORD" > /tmp/.pgpass
  chmod 600 /tmp/.pgpass
  export PGPASSFILE=/tmp/.pgpass

  pg_basebackup \
    -h $PRIMARY_HOST \
    -p $PRIMARY_PORT \
    -U $REPL_USER \
    -D $PGDATA \
    -Fp -Xs -P

  touch "$PGDATA/standby.signal"

  echo "primary_conninfo = 'host=$PRIMARY_HOST port=$PRIMARY_PORT user=$REPL_USER password=$REPL_PASSWORD'" \
    >> $PGDATA/postgresql.auto.conf
fi

exec docker-entrypoint.sh "$@"
</pre>
  </div>

  <p><small>Tips: bila Anda mengunduh file dan browser tidak menyimpan folder secara otomatis, buat folder lokal sesuai struktur dan pindahkan file yang diunduh ke folder yang sesuai sebelum melakukan <code>git add</code>.</small></p>

  <script>
    // Copy handler
    document.querySelectorAll('button.copy').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        const id = btn.getAttribute('data-target');
        const text = document.getElementById(id).textContent;
        try{
          await navigator.clipboard.writeText(text);
          btn.textContent = 'Copied ✓';
          setTimeout(() => btn.textContent = 'Copy', 1500);
        }catch(err){
          alert('Gagal menyalin. Anda dapat memilih manual teks di bawah dan Ctrl+C.');
        }
      });
    });

    // Download handler
    document.querySelectorAll('button.download').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const id = btn.getAttribute('data-target');
        const fname = btn.getAttribute('data-fname') || 'file.txt';
        const text = document.getElementById(id).textContent;
        const blob = new Blob([text], {type: 'text/plain;charset=utf-8'});
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = fname;
        document.body.appendChild(a);
        a.click();
        a.remove();
        URL.revokeObjectURL(url);
      });
    });
  </script>
</body>
</html>
