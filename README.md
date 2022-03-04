# Apache ServiceMix Docker image

# Content

Note: This docker compose execute a servicemix without the ActiveMQ part.
It uses pax-logging-log4j2.

## Note about branches

* Master branch -> contains a working solution with pax-logging-log4j2 and JsonTemplateLayout (legacy JSonLayout just kept for comparison).

* test/log4j2-without-pax -> branch to test the fix of LOG4J2-3356 but currently SMX is not starting.


## Docker 

For starting the container, just execute

`docker compose up`

or stared as daemon:

`docker compose up -d`


and for rebuilding image: 

`docker compose up -d --build --force-recreate`


# Current work
Make the Log4j JsonTemplateLayout to work properly
  * works without the log4j-layout-template-json but with the latest snapshot of the pax-logging-log4j2 lib

  * to test https://issues.apache.org/jira/browse/LOG4J2-3356 
   a new branch test/log4j2-without-pax has been created 
   The current version of the lib is a snapshot where the above bug is fixed but the servicemix does not start with only slf4j-api and log4j libs
  
# Future improvements

* Add ActiveMQ (or Artemis, or RabbitMQ, or zeroMQ) as a separate docker image but in the compose
* Add a pubSub broker (like solace docker) in a compose.
