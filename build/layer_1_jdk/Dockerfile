FROM centos:7

LABEL JAVA_INSTALLER=jdk-8u172-linux-x64.tar.gz \
      JDK_VERSION=1.8.0_172

COPY resources/jdk-8u172-linux-x64.tar.gz /tmp

RUN yum install -y unzip && \
    tar xf /tmp/jdk-8u172-linux-x64.tar.gz -C /opt && \
    rm -rf /tmp/jdk-8u172-linux-x64.tar.gz

ENV JAVA_HOME=/opt/jdk1.8.0_172 
ENV PATH=${PATH}:${JAVA_HOME}/bin

