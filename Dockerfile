# e4Cash DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Middleware Wildfly
# 
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run: 
#      $ docker build -t e4cash/middleware:12.0.0.Final . 
#
# password del openAM = Admin1234
#
# Pull base image
# ---------------
FROM ubuntu:16.04

# Maintainer
# ----------
LABEL maintainer="jose.schmucke@ab4cus.com"
MAINTAINER Jose A. Schmucke <jose.schmucke@ab4cus.com>
LABEL vendor=Ab4cus\ Tecnologia \
      net.ab4cus.is-beta="true" \
      net.ab4cus.is-production="false" \
      net.ab4cus.version="0.0.1-beta" \
      net.ab4cus.release-date="2018-06-08"

ENV TOMCAT_VERSION 8.5.31

# Fix sh
#RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install dependencies
RUN apt-get update && \
apt-get install -y git build-essential curl wget vim locales software-properties-common

# Set locales
RUN locale-gen en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LC_CTYPE en_GB.UTF-8

# Install JDK 8
RUN \
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
add-apt-repository -y ppa:webupd8team/java && \
apt-get update && \
apt-get install -y oracle-java8-installer wget unzip tar && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Get Tomcat
RUN wget --quiet --no-cookies http://apache.rediris.es/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz && \
tar xzvf /tmp/tomcat.tgz -C /opt && \
mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
rm /tmp/tomcat.tgz && \
rm -rf /opt/tomcat/webapps/examples && \
rm -rf /opt/tomcat/webapps/docs

# Add admin/admin user
#ADD tomcat-users.xml /opt/tomcat/conf/

ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

# verify Tomcat Native is working properly
RUN set -e \
	&& nativeLines="$(catalina.sh configtest 2>&1)" \
	&& nativeLines="$(echo "$nativeLines" | grep 'Apache Tomcat Native')" \
	&& nativeLines="$(echo "$nativeLines" | sort -u)" \
	&& if ! echo "$nativeLines" | grep 'INFO: Loaded APR based Apache Tomcat Native library' >&2; then \
		echo >&2 "$nativeLines"; \
		exit 1; \
	fi

#Set Log file retention to 15 days
RUN echo "" >> $CATALINA_HOME/conf/logging.properties \
    && echo "############################################################" >> $CATALINA_HOME/conf/logging.properties \
    && echo "# Log file retention to 15 days" >> $CATALINA_HOME/conf/logging.properties \
    && echo "############################################################" >> $CATALINA_HOME/conf/logging.properties \
    && echo "" >> $CATALINA_HOME/conf/logging.properties \
    && echo "1catalina.org.apache.juli.AsyncFileHandler.maxDays = 15" >> $CATALINA_HOME/conf/logging.properties \
    && echo "2localhost.org.apache.juli.AsyncFileHandler.maxDays = 15" >> $CATALINA_HOME/conf/logging.properties \
    && echo "3manager.org.apache.juli.AsyncFileHandler.maxDays = 15" >> $CATALINA_HOME/conf/logging.properties \
    && echo "4host-manager.org.apache.juli.AsyncFileHandler.maxDays = 15" >> $CATALINA_HOME/conf/logging.properties \
    && echo "" >> $CATALINA_HOME/conf/logging.properties \
# Clear webapps folder
#    && rm -rf $CATALINA_HOME/webapps/* \
# Disable autodeploy	
#	&& sed -i "s|autoDeploy=\"true\"|autoDeploy=\"false\"|g" $CATALINA_HOME/conf/server.xml

# Set Voluen storage
VOLUME "/opt/tomcat/webapps"

# Directory to working
WORKDIR /opt/tomcat

# Add automatic openAM 11
#ADD OpenAM-11.0.3.war /opt/tomcat/webapps

# Expose ports
EXPOSE 8080

# Set the default command to run on boot
CMD ["/opt/tomcat/bin/catalina.sh", "run"]

ENTRYPOINT ["/opt/tomcat/bin/catalina.sh"]
