#!/bin/bash


replacer() {
    replacement=$(env | grep $token | awk -F= '{print $2}')
    if [[ $(cat $FILE | grep "####$token####" | wc -l) -gt 0 ]]; then
        echo "Template=$TEMPLATE, $File=$FILE, Token=####${token}####, Replacement=${replacement}"
        sed -i "s+####$token####+$replacement+g" $FILE
    fi
}

if [[ ! -f "/opt/vars.lock" ]]; then

    if [ $REMOTE_DB_ENABLE ]; then    
        /opt/wait-for-it.sh $(echo "$TOKEN_dbconf_url" | cut -f3 -d'/') --timeout=2000 --strict  -- echo "Database is ready for use!"
        mkdir -p ${LIFERAY_HOME}/osgi/configs
        TEMPLATE="/templates/ROOT.xml.template"
        FILE="${CATALINA_HOME}/conf/Catalina/localhost/ROOT.xml"
        cp $TEMPLATE $FILE
        declare -a TOKEN_dbconf=$(env | grep ^"TOKEN_dbconf_" | awk -F= '{print $1}')
        for token in ${TOKEN_dbconf[@]}
        do
            replacer
        done
    fi
    if [ $REMOTE_ES_ENABLE ]; then
        /opt/wait-for-it.sh $TOKEN_es_transportAddresses_ip:$TOKEN_es_transportAddresses_port --timeout=2000 --strict  -- echo "Elastic Search is ready for use!"
        mkdir -p ${CATALINA_HOME}/conf/Catalina/localhost
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



catalina.sh run

#exec "$@"
