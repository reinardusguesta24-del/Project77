#!/bin/bash
set -e
pg_basebackup -h primary -D "$PGDATA" -U replicator -Fp -Xs -P -R
