FROM ubuntu:latest
MAINTAINER Sumit Kumar Maji

RUN apt-get update \
	&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
	openssh-server \
	openssh-client \
	net-tools \
	iputils-ping \
	curl \
	python \
	ant \
	wget \
	gcc g++ \
	git vim python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN apt-get install -yq openssh-server
RUN apt-get install -yq openssh-client
RUN apt-get update
RUN apt-get install -yq ant gcc g++ libkrb5-dev libffi-dev libmysqlclient-dev libssl-dev libsasl2-dev libsasl2-modules-gssapi-mit libsqlite3-dev libtidy-0.99-0 libxml2-dev libxslt-dev make libldap2-dev maven python-dev python-setuptools libgmp3-dev

ADD . /container/
WORKDIR /usr/local/
ARG REPOSITORY_HOST
RUN /container/scripts/setup.sh


RUN su - hduser -c "echo 'export JAVA_HOME=/usr/local/jdk' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /home/hduser/.bashrc"
RUN echo 'export MVN_HOME=/usr/local/maven' >> /home/hduser/.bashrc
RUN echo 'export PATH=$PATH:$MVN_HOME/bin' >> /home/hduser/.bashrc
RUN echo 'export MAVEN_OPTS=\"-Xms256m -Xmx512m\"' >> /home/hduser/.bashrc

ENV JAVA_HOME="/usr/local/jdk"
ENV PATH="$PATH:$JAVA_HOME/bin"

RUN java -version




COPY pseudo-distributed.ini /usr/local/hue/desktop/conf/pseudo-distributed.ini
COPY webhdfs.py /usr/local/hue/desktop/libs/hadoop/src/hadoop/fs/webhdfs.py
RUN chown hduser:hadoop /usr/local/hue/desktop/libs/hadoop/src/hadoop/fs/webhdfs.py
RUN chown hduser:hadoop /usr/local/hue/desktop/conf/pseudo-distributed.ini


RUN echo 'cd /usr/local/hue/build/env/bin' >> /home/hduser/.bashrc
RUN echo 'echo "1. Run => ./hue runserver master:8000"' >> /home/hduser/.bashrc

#Expose Hue port 8000
EXPOSE 8000

#Expose other ports
EXPOSE 49707 22 2122
CMD /usr/sbin/sshd -D

