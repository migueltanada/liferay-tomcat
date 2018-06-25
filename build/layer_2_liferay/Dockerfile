FROM layer:1

LABEL TOMCAT_VERSION=8.0.32 \
      LIFERAY_BUNDLE=liferay-dxp-digital-enterprise-tomcat-7.0-sp7-20180307180151313.zip

COPY resources/liferay-dxp-digital-enterprise-tomcat-7.0-sp7-20180307180151313.zip /tmp

ENV LIFERAY_HOME=/opt/liferay
ENV CATALINA_HOME=${LIFERAY_HOME}/tomcat-8.0.32 \
    CATALINA_BASE=${LIFERAY_HOME}/tomcat-8.0.32 
ENV PATH=${PATH}:${CATALINA_HOME}/bin:${CATALINA_HOME}/scripts

# Install Liferay
RUN unzip /tmp/liferay-dxp-digital-enterprise-tomcat-7.0-sp7-20180307180151313.zip -d /tmp && \
    rm -rf /tmp/liferay-dxp-digital-enterprise-tomcat-7.0-sp7-20180307180151313.zip && \
    mv /tmp/liferay-dxp-digital-enterprise-7.0-sp7 ${LIFERAY_HOME} && \
    groupadd liferay && \
    useradd -s /bin/nologin -g liferay -d ${LIFERAY_HOME} liferay && \
    chown -R liferay:liferay ${LIFERAY_HOME}

COPY resources/entrypoint.sh /opt

RUN chmod +x /opt/entrypoint.sh && \
    chown -R liferay:liferay /opt/entrypoint.sh

VOLUME ["/opt/liferay"]

USER liferay

WORKDIR ${LIFERAY_HOME}

EXPOSE 8080

ENTRYPOINT ["/opt/entrypoint.sh"]

