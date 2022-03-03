FROM openjdk:8-jre

ENV SMX_VERSION_MAJOR=7
ENV SMX_VERSION_MINOR=0
ENV SMX_VERSION_PATCH=1
ENV SMX_VERSION=${SMX_VERSION_MAJOR}.${SMX_VERSION_MINOR}.${SMX_VERSION_PATCH}
ENV SMX=apache-servicemix-$SMX_VERSION
ENV SMX_WEB="8181"
ENV SMX_ADMIN="8101"
ENV SMX_SHA1="4854243f6b1aaf3c9ff7c08183c769ab6878b285"
ENV SMX_HOME="/opt/apache-servicemix"

ENV JACKSON_VERSION=2.12.4
ENV LOG4J_VERSION=2.17.3

# Most of the install are for debugging purpose only, for production remove all apt-get
RUN apt-get update && \
    apt-get install -y vim && \
    apt-get install -y nmap && \
    apt-get install -y netcat && \
    apt-get install -y net-tools && \
    apt-get install -y iputils-ping && \
    apt-get install -y telnet && \
    apt-get install -y ssh && \
    apt-get install -y procps && \
    curl -k "https://archive.apache.org/dist/servicemix/servicemix-${SMX_VERSION_MAJOR}/$SMX_VERSION/$SMX.zip" -o $SMX.zip

# Validate checksum
RUN if [ "$SMX_SHA1" != "$(sha1sum $SMX.zip | awk '{print($1)}')" ];\
    then \
        echo "sha1 values doesn't match! exiting."  && \
        exit 1; \
    fi;

RUN unzip $SMX.zip -d /opt && \
    ln -s $SMX $SMX_HOME && \
    useradd -r -M -d $SMX_HOME smx && \
    mkdir -p /var/opt/servicemix/local

# Docker supports COPY only as root
COPY ./linux/bash_aliases.txt /tmp/.bash_aliases
COPY ./smx/system/jackson-core-${JACKSON_VERSION}.jar $SMX_HOME/system/com/fasterxml/jackson/core/jackson-core/${JACKSON_VERSION}/jackson-core-${JACKSON_VERSION}.jar
COPY ./smx/system/jackson-annotations-${JACKSON_VERSION}.jar $SMX_HOME/system/com/fasterxml/jackson/core/jackson-annotations/${JACKSON_VERSION}/jackson-annotations-${JACKSON_VERSION}.jar
COPY ./smx/system/jackson-databind-${JACKSON_VERSION}.jar $SMX_HOME/system/com/fasterxml/jackson/core/jackson-databind/${JACKSON_VERSION}/jackson-databind-${JACKSON_VERSION}.jar
COPY ./smx/system/slf4j-api-1.7.25.jar $SMX_HOME/system/org/slf4j/slf4j-api/1.7.25/slf4j-api-1.7.25.jar
COPY ./smx/system/log4j-core-${LOG4J_VERSION}.jar $SMX_HOME/system/org/apache/logging/log4j/log4j-core/${LOG4J_VERSION}/log4j-core-${LOG4J_VERSION}.jar
COPY ./smx/system/log4j-api-${LOG4J_VERSION}.jar $SMX_HOME/system/org/apache/logging/log4j/log4j-api/${LOG4J_VERSION}/log4j-api-${LOG4J_VERSION}.jar
COPY ./smx/system/log4j-slf4j-impl-${LOG4J_VERSION}.jar $SMX_HOME/system/org/apache/logging/log4j/log4j-slf4j-impl/${LOG4J_VERSION}/log4j-slf4j-impl-${LOG4J_VERSION}.jar
COPY ./smx/system/log4j-layout-template-json-${LOG4J_VERSION}.jar $SMX_HOME/system/org/apache/logging/log4j/log4j-layout-template-json/${LOG4J_VERSION}/log4j-layout-template-json-${LOG4J_VERSION}.jar

# change ownership and permissions after COPY
RUN chown -R smx:smx /opt/$SMX && \
    chown -h smx:smx $SMX_HOME && \
    chmod 644 $SMX_HOME/system/com/fasterxml/jackson/core/jackson-core/${JACKSON_VERSION}/jackson-core-${JACKSON_VERSION}.jar && \
    chmod 644 $SMX_HOME/system/com/fasterxml/jackson/core/jackson-annotations/${JACKSON_VERSION}/jackson-annotations-${JACKSON_VERSION}.jar && \
    chmod 644 $SMX_HOME/system/com/fasterxml/jackson/core/jackson-databind/${JACKSON_VERSION}/jackson-databind-${JACKSON_VERSION}.jar && \
    chmod 644 $SMX_HOME/system/org/slf4j/slf4j-api/1.7.25/slf4j-api-1.7.25.jar && \
    chmod 644 $SMX_HOME/system/org/apache/logging/log4j/log4j-core/${LOG4J_VERSION}/log4j-core-${LOG4J_VERSION}.jar && \
    chmod 644 $SMX_HOME/system/org/apache/logging/log4j/log4j-api/${LOG4J_VERSION}/log4j-api-${LOG4J_VERSION}.jar && \
    chmod 644 $SMX_HOME/system/org/apache/logging/log4j/log4j-slf4j-impl/${LOG4J_VERSION}/log4j-slf4j-impl-${LOG4J_VERSION}.jar && \
    chmod 644 $SMX_HOME/system/org/apache/logging/log4j/log4j-layout-template-json/${LOG4J_VERSION}/log4j-layout-template-json-${LOG4J_VERSION}.jar

USER smx

WORKDIR $SMX_HOME/bin

ENV JAVA_HOME="/usr/local/openjdk-8" \
#    JAVA_OPTS="$JAVA_OPTS  -Dyour.java.opts.here=value" \
    KARAF_HOME="$SMX_HOME" \
    KARAF_DATA="$SMX_HOME/data" \
    KARAF_ETC="$SMX_HOME/etc" \
    KARAF_NOROOT="true" \
    KARAF_OPTS="-Dkaraf.instances=$SMX_HOME/instances" \
    MAVEN_HOME="/opt/maven" \
    MAVEN_REPO="/var/opt/servicemix/local" \
    PATH="$PATH:/opt/maven/bin:/opt/servicemix/bin" \
    KARAF_DEBUG="true"

EXPOSE $SMX_WEB $SMX_ADMIN

# this is for debugging purpose, not for production
RUN cp /tmp/.bash_aliases ~ && \
    echo "\nif [ -f ~/.bash_aliases ]; then \n\t. ~/.bash_aliases\nfi" >> ~/.bashrc

CMD ["/bin/sh", "-c", "./servicemix"]

