#! /usr/bin/env bash

# If this is never successful, this waits forever.
# A max timeout with an error message might be preferable.
wait_for_datasource() {
    # echo "Task status:"
    # curl -s "http://localhost:88888/druid/indexer/v1/task/$task/status"

    datasources="$(curl -s http://localhost:8888/druid/v2/datasources)"

    # echo "Loaded datasources: $datasources"

    if [ "$datasources" != '["aqs_test"]' ]; then
        sleep 10
        wait_for_datasource
    fi
}

# If this is never successful, this waits forever.
# A max timeout with an error message might be preferable.
wait_for_all_rows() {
    # query the row count from the database, then extract the numerical portion of the json result
    QUERY='{"query":"SELECT count(*) AS \"count\" FROM \"aqs_test\""}'
    count=$(curl -s -X POST -H 'Content-Type: application/json' --data "$QUERY" http://localhost:8888/druid/v2/sql)
    count=${count//[!0-9]/}

    echo "Rows loaded: $count"
    if [ $count < $1 ]; then
        echo -ne "$count of $1 rows ingested"
        sleep 10
        wait_for_all_rows
    fi
}

check_health() {
    nc -z localhost 8091|| {
        echo "Port 8091 is not open."
        return -1
    }

    if [ "$(curl -s http://localhost:8091/status/health)" != "true" ]; then
        echo "Health check for router did not return true"
        return -1
    fi
}

set -eou pipefail

cd $(dirname "$0")

echo 'Starting Druid cluster...'
./run.sh &

while ! check_health; do
    sleep 5;
done

echo 'Ingesting data...'
curl -s -X POST \
     -H 'Content-Type: application/json' \
     --data '@/data/test-data_spec.json' \
     http://localhost:8888/druid/indexer/v1/task

echo -e "\nWaiting for ingestion to finish. Please be patient, this may take up a while..."
echo "Waiting for datasource to be available . . ."
wait_for_datasource
echo "Datasource loaded, loading rows"
total=$(sed -n '$=' /data/test-data.csv)
wait_for_all_rows $total
