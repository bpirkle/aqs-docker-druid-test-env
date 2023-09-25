# AQS Druid Docker Test Environment

This is a Dockerized Druid test environment. It includes a small sample set of test data for AQS endpoints. 

# Build and Run for developing purposes

This is the way to create and run this test environment in the case you are working on developing any Druid-based AQS service and you need to run some request or your integration tests.

In this case you'll run a docker compose project with a Druid database with enough data to test properly any Druid-based service (some details are available in the `aqs-docker-druid-test-env-build` folder).

You will need:
- Make
- Docker Compose

How to run the project:

```bash
make startup
```

Wait until terminal chatter settles. You can then hit http://localhost:8888/ for the Druid web ui.

You can stop it running `make shutdown`

The message 'insufficient active servers. Cannot balance.' is normal and expected.

# Build and Run for QA purposes

This is the way to run this test environment in the case you want to run the AQS QA test suite against a Druid-based service.

In this case you'll run a docker compose project composed of:
- A Druid database with enough data to test properly any Druid-based service (some details are available in the `aqs-docker-druid-test-env-build` folder)
- Druid-based services (_editor-analytics_ and _edit-analytics_) according the `docker-compose-qa.yml` config file

You will need:
- Make
- Docker Compose
- editor-analytics docker image already built (running `make docker-qa` from the service project)
- edit-analytics docker image already built (running `make docker-qa` from the service project)

How to run the project:

```bash
make startup-qa
```

At the end of this process you will see a docker compose project, called `aqs-docker-druid-test-env-qa`, running the following containers:
- **editor-analytics-qa**: A container with the _editor-analytics_ service listening on your local port 8094
- **edit-analytics-qa**: A container with the _edit-analytics_ service listening on your local port 8095
- **druid-qa**: A Druid container with a web UI listening on the port 8888

You can stop it running `make shutdown-qa`

Wait until terminal chatter settles. You can then hit http://localhost:8888/ for the Druid web ui.

The message 'insufficient active servers. Cannot balance.' is normal and expected.

# Troubleshooting

Other applications may also use this port.