# DriverLocation

The `Driver Location` service is a microservice that consumes drivers' location messages published by the `Gateway` service and stores them in a Redis database.

It also provides an internal endpoint that allows other services to retrieve the drivers' locations, filtered and sorted by their addition date.

## Getting started

You can use `make run` to build and start a interactive shell with everything running.

## Test it!

To perform the tests you can run `make test`.

Enjoy!
