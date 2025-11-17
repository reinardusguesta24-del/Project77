#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD 'replica123';
EOSQL
echo "host replication replicator 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
echo "wal_level = replica" >> "$PGDATA/postgresql.conf"
echo "max_wal_senders = 10" >> "$PGDATA/postgresql.conf"
echo "wal_keep_size = 64" >> "$PGDATA/postgresql.conf"
