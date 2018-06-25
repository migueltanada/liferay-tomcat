FROM layer2

RUN  mkdir -p /opt/liferay/templates
COPY resources/conf/. /opt/liferay/templates

# Tokens
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

# Enable templating
ENV REMOTE_ES_ENABLE="false" \ 
    REMOTE_DB_ENABLE="false" \
    INITIAL_SETUP_ENABLE="false" \
    PORTAL_EXT_SETUP_ENABLE="false"

USER root


# Copy jars
RUN mkdir -p ${CATALINA_HOME}/lib/ext/

COPY resources/jars/. ${CATALINA_HOME}/lib/ext/

RUN chmod +x ${CATALINA_HOME}/lib/ext/*.jar && \
    chown -R liferay:liferay ${CATALINA_HOME}/lib/ext/*.jar


# Copy scripts
COPY resources/scripts/. /opt

RUN chmod +x /opt/entrypoint.sh && \
    chmod +x /opt/wait-for-it.sh && \
    chown -R liferay:liferay /opt/entrypoint.sh && \
    chown -R liferay:liferay /opt/wait-for-it.sh

USER liferay


