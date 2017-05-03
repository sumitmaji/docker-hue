FROM sumit/jdk1.7:latest
MAINTAINER Sumit Kumar Maji

RUN apt-get update && apt-get install -yq openssh-server
RUN apt-get install -yq openssh-server
RUN apt-get install -yq openssh-client

RUN apt-get install -yq ant gcc g++ libkrb5-dev libffi-dev libmysqlclient-dev libssl-dev libsasl2-dev libsasl2-modules-gssapi-mit libsqlite3-dev libtidy-0.99-0 libxml2-dev libxslt-dev make libldap2-dev maven python-dev python-setuptools libgmp3-dev

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# passwordless ssh
RUN ssh-keygen -qy -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -qy -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN mkdir /root/.ssh
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN addgroup hadoop 
RUN adduser --ingroup hadoop hduser
RUN adduser hduser sudo

RUN su - hduser -c "ssh-keygen -t rsa -P \"\" -f /home/hduser/.ssh/id_rsa"
RUN su - hduser -c "cp /home/hduser/.ssh/id_rsa.pub /home/hduser/.ssh/authorized_keys"

ADD ssh_config /home/hduser/.ssh/config
RUN chmod 600 /home/hduser/.ssh/config
RUN chown hduser:hadoop /home/hduser/.ssh/config

RUN echo 'hduser:hadoop' | chpasswd



RUN su - hduser -c "echo 'export JAVA_HOME=/usr/local/jdk1.7' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /home/hduser/.bashrc"

RUN java -version

#Install Hue
COPY hue-all-installed.tar.gz /usr/local/hue-all-installed.tar.gz
RUN tar -xzvf /usr/local/hue-all-installed.tar.gz -C /usr/local/
RUN rm -rf /usr/local/hue.tar.gz
RUN chown -R hduser:hadoop /usr/local/hue


###################################################################
###################################################################
###################################################################
#######################DONT GO ABOVE THIS##########################
###################################################################
###################################################################
###################################################################


COPY pseudo-distributed.ini /usr/local/hue/desktop/conf/pseudo-distributed.ini
COPY webhdfs.py /usr/local/hue/desktop/libs/hadoop/src/hadoop/fs/webhdfs.py
RUN chown hduser:hadoop /usr/local/hue/desktop/libs/hadoop/src/hadoop/fs/webhdfs.py
RUN chown hduser:hadoop /usr/local/hue/desktop/conf/pseudo-distributed.ini


RUN echo 'cd /usr/local/hue/build/env/bin' >> /home/hduser/.bashrc
RUN echo 'echo "1. Run => ./hue runserver master:8000"' >> /home/hduser/.bashrc

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown hduser:hadoop /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh
RUN su - hduser -c "echo 'export BOOTSTRAP=/etc/bootstrap.sh' >> /home/hduser/.bashrc"

#Expose Hue port 8000
EXPOSE 8000

#Expose other ports
EXPOSE 49707 22 2122
CMD /usr/sbin/sshd -D

