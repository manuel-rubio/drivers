# Gateway

The `Gateway` service is a _public facing service_.
HTTP requests hitting this service are either transformed into [NSQ](https://github.com/nsqio/nsq) messages or forwarded via HTTP to specific services.

The service must be configurable dynamically by loading the provided `gateway/config.yaml` file to register endpoints during its initialization.

## Getting started

You can use `make` to build and start a interactive shell with everything running.

## Test it!

To perform the tests you can run `make test`.

Enjoy!
