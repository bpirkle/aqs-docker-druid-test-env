# AQS Druid Docker Test Environment

This is a Dockerized Druid test environment. It includes a small sample set of test data for AQS endpoints. 

# Build and Run

You will need:
-Make
-Docker Compose


```sh-session
make startup
```

Wait until terminal chatter settles. You can then hit http://localhost:8888/ for the Druid web ui.

The message 'insufficient active servers. Cannot balance.' is normal and expected.

# Troubleshooting

Other applications may also use this port.
