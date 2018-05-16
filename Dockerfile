FROM centos:7


LABEL JAVA_INSTALLER=jdk-8u172-linux-x64.tar.gz \
      JDK_VERSION=1.8.0_172 \
      TOMCAT_VERSION=8.0.32 \
      LIFERAY_BUNDLE=liferay-dxp-digital-enterprise-tomcat-7.0-sp7-20180307180151313.zip

COPY Resources/installers/jdk-8u172-linux-x64.tar.gz /tmp
COPY Resources/installers/liferay-dxp-digital-enterprise-7.0-sp7.zip /tmp

ENV JAVA_HOME=/opt/jdk1.8.0_172 \
    LIFERAY_HOME=/opt/liferay
ENV CATALINA_HOME=${LIFERAY_HOME}/tomcat-8.0.32 \
    CATALINA_BASE=${LIFERAY_HOME}/tomcat-8.0.32 

ENV PATH=${PATH}:${JAVA_HOME}/bin:${CATALINA_HOME}/bin:${CATALINA_HOME}/scripts

RUN yum install -y unzip && \
    tar xf /tmp/jdk-8u172-linux-x64.tar.gz -C /opt && \
    rm -rf /tmp/jdk-8u172-linux-x64.tar.gz && \
    unzip /tmp/liferay-dxp-digital-enterprise-7.0-sp7.zip -d /tmp && \
    rm -rf /tmp/liferay-dxp-digital-enterprise-7.0-sp7.zip && \
    mv /tmp/liferay-dxp-digital-enterprise-7.0-sp7 ${LIFERAY_HOME} && \
    groupadd liferay && \
    useradd -s /bin/nologin -g liferay -d ${LIFERAY_HOME} liferay && \
    chown -R liferay:liferay ${LIFERAY_HOME} 

RUN  mkdir -p /templates
COPY Resources/conf/. /templates/

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
    TOKEN_es_transportAddresses_ip="elasticsearch" \
    TOKEN_es_transportAddresses_port="9200" \
    TOKEN_es_logExceptionsOnly="false" \
    TOKEN_setup_admin_email_from_address="test@liferay.com" \
    TOKEN_setup_admin_email_from_name="Test Test" \
    TOKEN_setup_company_default_locale="en_US" \
    TOKEN_setup_company_default_web_id="liferay.com" \
    TOKEN_setup_default_admin_email_address_prefix="test" \
    TOKEN_setup_liferay_home="/opt/liferay" \
    TOKEN_setup_setup_wizard_enabled="false" 


ENV REMOTE_ES_ENABLE="false" \ 
    REMOTE_DB_ENABLE="false" \
    INITIAL_SETUP_ENABLE="false" \
    PORTAL_EXT_SETUP_ENABLE="false"

#VOLUME ["/opt/liferay"]

COPY Resources/scripts/entrypoint.sh /opt
COPY Resources/scripts/wait-for-it.sh /opt
COPY Resources/mysql.jar ${CATALINA_HOME}/lib/ext


RUN  chmod +x /opt/entrypoint.sh && \
     chmod +x /opt/wait-for-it.sh && \
     chmod +x ${CATALINA_HOME}/lib/ext/mysql.jar && \
     chown -R liferay:liferay /opt/entrypoint.sh && \
     chown -R liferay:liferay /opt/wait-for-it.sh && \
     chown -R liferay:liferay ${CATALINA_HOME}/common/lib/ext/mysql.jar

USER liferay

WORKDIR ${LIFERAY_HOME}

ENTRYPOINT ["/opt/entrypoint.sh"]


