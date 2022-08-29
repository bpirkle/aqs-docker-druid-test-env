### DockerHub
[`bpirkle/aqs-docker-druid-test-env`](https://hub.docker.com/repository/docker/bpirkle/aqs-docker-druid-test-env)

### Credits and links

This was inspired by https://github.com/metabase/druid-docker

Parts of this are direct copies of that repository (including parts of this README file)

The ingestion spec is based on https://github.com/wikimedia/analytics-refinery/blob/master/oozie/mediawiki/history/reduced/load_mediawiki_history_reduced.json.template

Test data is obtained from https://wikitech.wikimedia.org/wiki/Analytics/Systems/Cluster/Spark

### Build It

```bash
docker build -t bpirkle/aqs-docker-druid-test-env .
```

The build logic ingests the data in `aqs_druid_test_data.cvs` by executing the ingestion spec task `aqs_druid_test_spec.json`. This is done in the script `ingest.sh`.

Why ingest data as part of the build process? In some cases ingestion and indexing can take 10 minutes, on top of
using an obnoxious amount of memory. Better to do it during build so we can use the image right out of the box.

### Use It

```bash
docker run -p 8081:8081 -p 8082:8082 -p 8888:8888 -it bpirkle/aqs-docker-druid-test-env
```
You can then hit http://localhost:8888/ for the Druid web ui

#### Env Vars

For running Metabase tests you shouldn't need to change any of these.

*  `CLUSTER_SIZE` -- Druid config to use. Currently one of `nano-quickstart`, `micro-quickstart`, `small`, `medium`, `large`, or `xlarge`. Default: `nano-quickstart`
*  `START_MIDDLE_MANAGER` -- whether to start the middle manager process. Default `false`, because the middle manager is only needed for ingesting rows. Set to `true` if you plan to ingest more data.
*  `ENABLE_JAVASCRIPT` -- whether to enable javascript on the Druid cluster. Defaults to `true`. Set it to something besides `true` to disable it.
*  `LOG4J_PROPERTIES_FILE` -- Log4j2 config. By default, `/druid/apache-druid-0.20.2/log4j2.properties`, copied when building the Docker image, but you can mount a directory and supply a different file if you want different logging levels.

### Push It

```bash
docker push bpirkle/aqs-docker-druid-test-env
```

### TO-DOs

The naming of all this is speculative. Should we include the Druid version number in the name? Are the various other names to long/short/unclear?

Test data is currently .csv, but Spark can also generate .json data. Which do we prefer for this?

The injest.sh script waits a hard-coded 10 minutes for ingestion tasks to complete. Is there anything we can do to actually know when everything is done rather than assuming a time? And if not, can we make the countdown prettier?

The ingest.sh script in general doesn't do a lot of error handling. It is only needed at build time, so maybe that's okay. But could/should it do more? 

