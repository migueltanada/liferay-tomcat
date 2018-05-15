FROM centos:7


LABEL JAVA_INSTALLER=jdk-8u172-linux-x64.tar.gz \
      JDK_VERSION=1.8.0_172 \
      TOMCAT_VERSION=8.0.32 \
      LIFERAY_BUNDLE=liferay-dxp-digital-enterprise-tomcat-7.0-sp7-20180307180151313.zip

RUN  mkdir -p /templates
COPY Resources/conf/ROOT.xml.template /templates
COPY Resources/conf/com.liferay.portal.search.elasticsearch.configuration.ElasticsearchConfiguration.config.template /templates
COPY Resources/installers/jdk-8u172-linux-x64.tar.gz /tmp
COPY Resources/installers/liferay-dxp-digital-enterprise-7.0-sp7.zip /tmp


ENV JAVA_HOME=/opt/jdk1.8.0_172 \
    LIFERAY_HOME=/opt/liferay
ENV CATALINA_HOME=${LIFERAY_HOME}/tomcat-8.0.32 \
    CATALINA_BASE=${LIFERAY_HOME}/tomcat-8.0.32 

ENV PATH=${PATH}:${JAVA_HOME}/bin:${CATALINA_HOME}/bin:${CATALINA_HOME}/scripts

ENV TOKEN_dbconf_name="jdbc/LiferayPool" \
    TOKEN_dbconf_auth="Container" \
    TOKEN_dbconf_type="javax.sql.DataSource" \
    TOKEN_dbconf_driverClassName="com.mysql.jdbc.Driver" \
    TOKEN_dbconf_url="jdbc:mysql://liferay-mysql:3306/lportal?useUnicode=true&amp;characterEncoding=UTF-8" \
    TOKEN_dbconf_username="liferay" \
    TOKEN_dbconf_password="liferay" \
    TOKEN_dbconf_maxActive="100" \
    TOKEN_dbconf_maxIdle="30" \ 
    TOKEN_dbconf_maxWait="10000" \
    TOKEN_es_operationMode="REMOTE" \
    TOKEN_es_transportAddresses_ip="liferay-es" \
    TOKEN_es_transportAddresses_port="9300" \
    TOKEN_es_logExceptionsOnly="false"

ENV REMOTE_ES_ENABLE="false" \ 
    REMOTE_DB_ENABLE="false"

	
RUN yum install -y unzip && \
    tar xf /tmp/jdk-8u172-linux-x64.tar.gz -C /opt && \
    rm -rf /tmp/jdk-8u172-linux-x64.tar.gz && \
    unzip /tmp/liferay-dxp-digital-enterprise-7.0-sp7.zip -d /tmp && \
    rm -rf /tmp/liferay-dxp-digital-enterprise-7.0-sp7.zip && \
    mv /tmp/liferay-dxp-digital-enterprise-7.0-sp7 ${LIFERAY_HOME} && \
    groupadd liferay && \
    useradd -s /bin/nologin -g liferay -d ${LIFERAY_HOME} liferay && \
    chown -R liferay:liferay ${LIFERAY_HOME}

VOLUME ["/opt/liferay"]

COPY Resources/scripts/entrypoint.sh /opt
COPY Resources/scripts/wait-for-it.sh /opt

RUN  chmod +x /opt/entrypoint.sh && \
     chmod +x /opt/wait-for-it.sh && \
     chown -R liferay:liferay /opt/entrypoint.sh && \
     chown -R liferay:liferay /opt/wait-for-it.sh

USER liferay

WORKDIR ${LIFERAY_HOME}

ENTRYPOINT ["/opt/entrypoint.sh"]
