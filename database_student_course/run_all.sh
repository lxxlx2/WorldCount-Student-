#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
MYSQL=(mysql -uroot --default-character-set=utf8mb4 --table)
"${MYSQL[@]}" < sql/01_schema.sql
"${MYSQL[@]}" < sql/02_seed.sql
"${MYSQL[@]}" < sql/03_operations_and_queries.sql
"${MYSQL[@]}" < sql/04_verification.sql
