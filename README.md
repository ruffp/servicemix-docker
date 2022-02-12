# Apache ServiceMix Docker image

# Content

Note: This docker compose execute a servicemix without the ActiveMQ part.
It uses pax-logging-log4j2 with extras (necessary for jsonlayout).


## Docker 

For starting the container, just execute

`docker compose up`

or stared as daemon:

`docker compose up -d`


and for rebuilding image: 

`docker compose up -d --build --force-recreate`

# Future improvements

* Make the Log4j JsonTemplateLayout to work properly
  https://issues.apache.org/jira/browse/LOG4J2-3356 
  The current version of the lib is a snapshot where the above bug is fixed but the json log is not a json.
  
  
* Add ActiveMQ (or Artemis, or RabbitMQ, or zeroMQ) as a separate docker image but in the compose

* 
