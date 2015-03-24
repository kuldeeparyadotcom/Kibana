#We are using Ubuntu 14.04 as our base image
FROM ubuntu:14.04
MAINTAINER kd <kuldeeparyadotcom@gmail.com>

#Environment varialble for specific package installation i.e. kibana-3.1.2
ENV KB_PKG_NAME kibana-3.1.2
ENV KIBANA_HOST /var/www/html
ENV KIBANA_HOME $KIBANA_HOST/kibana
#https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz

#Updating apt-get, installing wget and apache2
RUN apt-get update && apt-get install -y wget apache2

#Create directory for apache2 lock file and run directory 
RUN mkdir -p /var/lock/apache2 /var/run/apache2

#Set required environment variables for Apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV LANG C

#Install kibana & deploy to apache2
RUN cd / && wget https://download.elasticsearch.org/kibana/kibana/$KB_PKG_NAME.tar.gz && tar xvzf $KB_PKG_NAME.tar.gz && rm -f $KB_PKG_NAME.tar.gz && mv /$KB_PKG_NAME $KIBANA_HOME 

#Volume for Kibana Configuration "config.js" i.e. /var/www/html/kibana/config.js
VOLUME ["/data"]

# Rename configuration file shipped with Kibana
#Create a symbolic link for our customzied Kibana Configuration "config.js" file
RUN mv $KIBANA_HOME/config.js $KIBANA_HOME/config.js.original &&  ln -s /data/config.js $KIBANA_HOME/config.js
#Define working directory
WORKDIR /data

#Define default command to run in foreground (with PID 1)
#Remeber that only PID 1 process would listen to signals we are going to send via docker kill -s <container> <signal> command
#For example to restart apache2 service within Docker container
#CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

#Epose port 80 to access web server apache2 
EXPOSE 80
