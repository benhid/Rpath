FROM openanalytics/r-base

MAINTAINER Antonio Benitez "antonio.benitez@lcc.uma.es"

# install wget and gnupg
RUN apt-get update && apt-get install -my wget gnupg  && apt-get install libxml2-dev
RUN echo "Y" | apt-get install libcurl4-openssl-dev libssl-dev

# install oracle java 8
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
    && echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list \
    && echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 \
    && apt-get update \
    && apt-get install oracle-java8-installer -y \
    && apt install oracle-java8-set-default \
    && apt-get install r-cran-rjava

# clean local repository
RUN apt-get clean

# set up JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# basic shiny functionality
RUN R -e "install.packages(c('shiny', 'shinyjs'), repos='https://cloud.r-project.org/')"

# RPath specific packages
RUN R -e "install.packages(c('DT', 'plyr', 'SPARQL', 'stringr', 'XML', 'igraph', 'visNetwork', 'rlist'), repos='https://cloud.r-project.org/')"
RUN R -e "source('http://bioconductor.org/biocLite.R'); biocLite('paxtoolsr')"

# copy the app to the image
RUN mkdir /root/rpath
COPY R /root/rpath

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/rpath')"]
