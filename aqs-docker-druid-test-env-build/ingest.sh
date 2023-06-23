#! /usr/bin/env bash

# If this is never successful, this waits forever.
# A max timeout with an error message might be preferable.
wait_for_datasource() {
    datasources="$(curl -s http://localhost:8888/druid/v2/datasources)"

    if [ "$datasources" != '["aqs_test"]' ]; then
        sleep 10
        wait_for_datasource
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