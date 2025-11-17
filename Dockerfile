FROM postgres:15
COPY replica.sh /docker-entrypoint-initdb.d/replica.sh