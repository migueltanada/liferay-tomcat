#!/bin/bash

# Check if remote db is running
if $REMOTE_DB_ENABLE; then    
    /opt/wait-for-it.sh $(echo "$TOKEN_dbconf_url" | cut -f3 -d'/') --timeout=2000 --strict  -- echo "Database is ready for use!"
    mkdir -p ${LIFERAY_HOME}/osgi/configs
fi

# Check if remote es is running
if $REMOTE_ES_ENABLE; then
    /opt/wait-for-it.sh $TOKEN_es_transportAddresses_ip:$TOKEN_es_transportAddresses_port --timeout=2000 --strict  -- echo "Elastic Search is ready for use!"
    mkdir -p ${CATALINA_HOME}/conf/Catalina/localhost
fi

# Replacer function
replacer() {
    replacement=$(env | grep $token | awk -F= '{print $2}')
    if [[ $(cat $FILE | grep "####$token####" | wc -l) -gt 0 ]]; then
        echo "Template=$TEMPLATE, $File=$FILE, Token=####${token}####, Replacement=${replacement}"
        sed -i "s+####$token####+$replacement+g" $FILE
    fi
}

# If lockfile exist dont use templates
if [[ ! -f "/opt/vars.lock" ]]; then

    # portal-setup-wizard.properties setup
    if $INITIAL_SETUP_ENABLE; then
        TEMPLATE="/templates/portal-setup-wizard.properties.template"
        FILE="${LIFERAY_HOME}/portal-setup-wizard.properties"
        cp $TEMPLATE $FILE
        declare -a TOKEN_setup=$(env | grep ^"TOKEN_setup_" | awk -F= '{print $1}')
        for token in ${TOKEN_setup[@]}
        do
            replacer
        done
    fi

    # portal-ext.properties setup
    if $PORTAL_EXT_SETUP_ENABLE; then
        TEMPLATE="/templates/portal-ext.properties.template"
        FILE="${LIFERAY_HOME}/portal-ext.properties"
        cp $TEMPLATE $FILE
        declare -a TOKEN_portal=$(env | grep ^"TOKEN_portal_" | awk -F= '{print $1}')
        for token in ${TOKEN_portal[@]}
        do
            replacer
        done
    fi

    # ROOT.xml setup
    if $REMOTE_DB_ENABLE; then    
        declare -a TOKEN_dbconf=$(env | grep ^"TOKEN_dbconf_" | awk -F= '{print $1}')

        TEMPLATE="/templates/server.xml.template"
        FILE="${CATALINA_HOME}/conf/server.xml"
        cp $TEMPLATE $FILE
        for token in ${TOKEN_dbconf[@]}
        do
            replacer
        done

        TEMPLATE="/templates/context.xml.template"
        FILE="${CATALINA_HOME}/conf/context.xml"
        cp $TEMPLATE $FILE
        for token in ${TOKEN_dbconf[@]}
        do
            replacer
        done

        TEMPLATE="/templates/portal-ext.properties.template"
        FILE="${LIFERAY_HOME}/portal-ext.properties"
        cp $TEMPLATE $FILE
        for token in ${TOKEN_dbconf[@]}
        do
            replacer
        done


    fi

    # com.liferay.portal.search.elasticsearch.configuration.ElasticsearchConfiguration.config setup
    if $REMOTE_ES_ENABLE; then
        TEMPLATE="/templates/com.liferay.portal.search.elasticsearch.configuration.ElasticsearchConfiguration.config.template"
        FILE="${LIFERAY_HOME}/osgi/configs/com.liferay.portal.search.elasticsearch.configuration.ElasticsearchConfiguration.config"
        cp $TEMPLATE $FILE
        declare -a TOKEN_es=$(env | grep ^"TOKEN_es_" | awk -F= '{print $1}')
        for token in ${TOKEN_es[@]}
        do
            replacer
        done
    fi
fi


if [[ $# -lt 1 ]]; then
  # Start Server
  catalina.sh run
fi

# Execute whatever argument was passed like `bash`
exec "$@"
