#! /usr/bin/env bash

set -eou pipefail

cd $(dirname "$0")

echo 'Starting Druid cluster...'
./run.sh &

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

while ! check_health; do
    sleep 5;
done

echo 'Ingesting data...'
curl -s -X POST \
     -H 'Content-Type: application/json' \
     --data '@/data/aqs_druid_test_spec.json' \
     http://localhost:8888/druid/indexer/v1/task

# If this is never successful, this waits forever.
# A max timeout with an error message might be preferable.
wait_for_datasource() {
    # echo "Task status:"
    # curl -s "http://localhost:88888/druid/indexer/v1/task/$task/status"

    datasources="$(curl -s http://localhost:8888/druid/v2/datasources)"

    # echo "Loaded datasources: $datasources"

    if [ "$datasources" != '["aqs_test"]' ]; then
        sleep 1
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

    # count number of lines in test data file, then subtract one for headers
    total=$(sed -n '$=' /data/aqs_druid_test_data.csv)
    total=$((total-1))

    echo "Rows loaded: $count"
    if [ $count != $total ]; then
        echo -ne "$count of $total rows ingested"
        sleep 10
        wait_for_all_rows
    fi

}

echo -e "\nWaiting for ingestion to finish. Please be patient, this may take up to 10 minutes..."
wait_for_datasource
echo "Datasource loaded, loading rows"
wait_for_all_rows

# Waiting a fixed time seems silly. It might not be enough in some situations,
# but it also might be ridiculously too long in others.
# Is there something we could query to actively detect completion?
echo "Now wait a while for the ingestion tasks to finish up"
secs=$((10 * 60))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done
